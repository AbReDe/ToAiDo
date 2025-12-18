from fastapi import APIRouter, Depends, Header
from sqlalchemy.orm import Session
from datetime import datetime, timedelta
import schemas, models
from dependencies import get_db, get_current_user
import requests
import json

router = APIRouter(
    prefix="/ai",
    tags=["Artificial Intelligence"]
)

# --- YARDIMCI FONKSİYON: HTTP İLE GEMINI (SENİN MODELLERİNLE) ---
def ask_gemini_http(api_key: str, prompt: str):
    # SENİN LİSTENDEN SEÇTİĞİMİZ EN İYİ MODELLER (Sırasıyla deneyecek)
    models_to_try = [
        "gemini-2.0-flash",       # Listende var! Çok hızlı.
        "gemini-2.5-flash",       # En yenisi!
        "gemini-flash-latest",    # Genel güncel flash
        "gemini-2.0-flash-exp",   # Deneysel
        "gemini-2.5-pro"          # Daha zeki (Kota dolarsa diğerine geçer)
    ]
    
    headers = {
        "Content-Type": "application/json"
    }
    
    data = {
        "contents": [{
            "parts": [{"text": prompt}]
        }]
    }

    last_error = ""

    # Modelleri sırayla dene
    for model in models_to_try:
        try:
            # URL Yapısı: .../models/MODEL_ADI:generateContent
            url = f"https://generativelanguage.googleapis.com/v1beta/models/{model}:generateContent?key={api_key}"
            
            # Timeout 30 saniye (Yapay zeka bazen düşünür)
            response = requests.post(url, headers=headers, json=data, timeout=30)
            
            # 200 OK geldiyse cevabı al ve çık
            if response.status_code == 200:
                result = response.json()
                try:
                    text = result['candidates'][0]['content']['parts'][0]['text']
                    print(f"✅ Başarılı Model: {model}")
                    return text
                except (KeyError, IndexError):
                    print(f"⚠️ Model '{model}' boş cevap döndürdü.")
                    continue # Diğer modele geç

            # Hata geldiyse
            else:
                print(f"⚠️ Model '{model}' Hatası: {response.status_code} - {response.text}")
                last_error = f"{model} Hatası: {response.status_code}"
                continue # Diğer modele geç

        except Exception as e:
            print(f"❌ Bağlantı Hatası ({model}): {e}")
            continue

    # Hiçbiri çalışmadıysa
    return f"Üzgünüm, şu an hiçbir modelden cevap alamadım. Lütfen API anahtarını kontrol et veya 1 dakika bekle. (Son Hata: {last_error})"

# 1. SOHBET ET
@router.post("/chat")
def chat_with_ai(
    request: schemas.AIChatRequest, 
    current_user: models.User = Depends(get_current_user),
    x_gemini_api_key: str | None = Header(default=None) 
):
    user_msg = request.message
    
    if x_gemini_api_key:
        system_prompt = f"Sen 'ToAiDo' asistanısın. Kullanıcı: {current_user.full_name}. Soru: {user_msg}"
        ai_response = ask_gemini_http(x_gemini_api_key, system_prompt)
        return {"response": ai_response}

    return {"response": "API Anahtarı girilmedi. (Mock Cevap)"}


# 2. GÖREV OLUŞTURUCU
@router.post("/generate", response_model=schemas.AIGenerateResponse)
def generate_tasks_from_ai(
    request: schemas.AIGenerateRequest, 
    db: Session = Depends(get_db), 
    current_user: models.User = Depends(get_current_user),
    x_gemini_api_key: str | None = Header(default=None)
):
    topic = request.topic
    
    if x_gemini_api_key:
        prompt = f"""
        Konu: '{topic}'.
        Bu konuyla ilgili yapılması gereken 5 somut görevi listele.
        SADECE JSON formatında string listesi döndür.
        Örnek: ["Görev 1", "Görev 2"]
        """
        
        ai_text = ask_gemini_http(x_gemini_api_key, prompt)
        
        if ai_text and "[" in ai_text:
            try:
                # Temizlik
                cleaned_text = ai_text.replace("```json", "").replace("```", "").strip()
                start = cleaned_text.find('[')
                end = cleaned_text.rfind(']') + 1
                if start != -1 and end != -1:
                    cleaned_text = cleaned_text[start:end]

                task_titles = json.loads(cleaned_text)
                
                new_tasks = []
                for i, title in enumerate(task_titles):
                    new_task = models.Task(
                        title=title,
                        description=f"AI ({topic})",
                        priority="medium",
                        status="Yapılacak",
                        due_date=datetime.now() + timedelta(days=i),
                        owner_id=current_user.id
                    )
                    db.add(new_task)
                    new_tasks.append(new_task)
                
                db.commit()
                return {
                    "message": f"Yapay Zeka, {len(new_tasks)} görev oluşturdu! 🚀",
                    "created_task_count": len(new_tasks)
                }
            except Exception as e:
                print(f"JSON Parse Hatası: {e}")

    return {
        "message": "Görev oluşturulamadı (API Key yok veya Hata).",
        "created_task_count": 0
    }