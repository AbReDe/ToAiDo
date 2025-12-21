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

# --- YARDIMCI FONKSİYON: HTTP İLE GEMINI (AKILLI MODEL SEÇİCİ) ---
def ask_gemini_http(api_key: str, prompt: str):
    # Denenecek Modeller Listesi (En hızlı ve kotası bol olandan başlıyoruz)
    models_to_try = [
        "gemini-2.0-flash",       # Çok hızlı ve yeni
        "gemini-2.5-flash",       # En güncel sürüm
        "gemini-1.5-flash",       # Kararlı ve hızlı
        "gemini-flash-latest",    # Genel güncel flash
        "gemini-2.0-flash-exp",   # Deneysel
        "gemini-1.5-pro"          # Daha zeki ama yavaş olabilir
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
            # URL Yapısı
            url = f"https://generativelanguage.googleapis.com/v1beta/models/{model}:generateContent?key={api_key}"
            
            # Timeout 30 saniye
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

            # Hata geldiyse (429 Kota, 404 Bulunamadı vs.)
            else:
                print(f"⚠️ Model '{model}' Hatası: {response.status_code}")
                last_error = f"{model}: {response.text}"
                continue # Diğer modele geç

        except Exception as e:
            print(f"❌ Bağlantı Hatası ({model}): {e}")
            continue

    # Hiçbiri çalışmadıysa
    return f"Üzgünüm, şu an hiçbir yapay zeka modeline ulaşılamadı. Lütfen API anahtarını kontrol et veya kotan dolmuş olabilir. (Hata: {last_error})"

# 1. SOHBET ET
@router.post("/chat")
def chat_with_ai(
    request: schemas.AIChatRequest, 
    current_user: models.User = Depends(get_current_user),
    x_gemini_api_key: str | None = Header(default=None) 
):
    user_msg = request.message
    
    # 1. Önce Header'a bak, yoksa Veritabanına (User tablosuna) bak
    api_key_to_use = x_gemini_api_key or current_user.gemini_api_key
    
    if api_key_to_use:
        system_prompt = f"Sen 'ToAiDo' asistanısın. Kullanıcı: {current_user.full_name}. Soru: {user_msg}"
        ai_response = ask_gemini_http(api_key_to_use, system_prompt)
        return {"response": ai_response}

    return {"response": "API Anahtarı bulunamadı. Lütfen profil ayarlarından ekleyin."}


# 2. GÖREV OLUŞTURUCU
@router.post("/generate", response_model=schemas.AIGenerateResponse)
def generate_tasks_from_ai(
    request: schemas.AIGenerateRequest, 
    db: Session = Depends(get_db), 
    current_user: models.User = Depends(get_current_user),
    x_gemini_api_key: str | None = Header(default=None)
):
    topic = request.topic
    
    # 1. Önce Header'a bak, yoksa Veritabanına bak
    api_key_to_use = x_gemini_api_key or current_user.gemini_api_key
    
    if api_key_to_use:
        prompt = f"""
        Konu: '{topic}'.
        Bu konuyla ilgili yapılması gereken 5 somut görevi listele.
        SADECE JSON formatında string listesi döndür.
        Örnek: ["Görev 1", "Görev 2"]
        """
        
        ai_text = ask_gemini_http(api_key_to_use, prompt)
        
        if ai_text and "[" in ai_text:
            try:
                # Temizlik
                cleaned_text = ai_text.replace("```json", "").replace("```", "").strip()
                start = cleaned_text.find('[')
                end = cleaned_text.rfind(']') + 1
                if start != -1 and end != -1:
                    cleaned_text = cleaned_text[start:end]

                task_titles = json.loads(cleaned_text)
                
                new_task = models.Task(
                        title=title,
                        description=f"AI ({topic})",
                        priority="medium",
                        status="Yapılacak",
                        due_date=datetime.now() + timedelta(days=i),
                        owner_id=current_user.id,
                        
                   
                        repeat="none",
                        tags=["AI"] 
                       
                    )
                
                db.commit()
                return {
                    "message": f"Gemini, {len(new_tasks)} görev oluşturdu! 🚀",
                    "created_task_count": len(new_tasks)
                }
            except Exception as e:
                print(f"JSON Parse Hatası: {e}")

    return {
        "message": "Görev oluşturulamadı (API Key yok veya Hata).",
        "created_task_count": 0
    }