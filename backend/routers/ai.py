from fastapi import APIRouter, Depends, Header
from sqlalchemy.orm import Session
import schemas, models
from dependencies import get_db, get_current_user
import requests
import json

router = APIRouter(
    prefix="/ai",
    tags=["Artificial Intelligence"]
)

# --- YARDIMCI FONKSİYON: HTTP İLE GEMINI ---
def ask_gemini_http(api_key: str, prompt: str):
    # Denenecek modeller (En hızlı ve güncel olanlar başta)
    models_to_try = [
        "gemini-2.0-flash", 
        "gemini-2.5-flash", 
        "gemini-1.5-flash",
        "gemini-flash-latest", 
        "gemini-2.0-flash-exp", 
        "gemini-1.5-pro"
    ]
    
    headers = {"Content-Type": "application/json"}
    data = {"contents": [{"parts": [{"text": prompt}]}]}

    for model in models_to_try:
        try:
            url = f"https://generativelanguage.googleapis.com/v1beta/models/{model}:generateContent?key={api_key}"
            response = requests.post(url, headers=headers, json=data, timeout=30)
            
            if response.status_code == 200:
                result = response.json()
                try:
                    return result['candidates'][0]['content']['parts'][0]['text']
                except (KeyError, IndexError):
                    continue
            else:
                # 429 (Kota) veya 404 (Model yok) hatalarında diğer modele geç
                continue
        except Exception:
            continue

    return None # Hiçbiri çalışmazsa

# 1. SOHBET
@router.post("/chat")
def chat_with_ai(
    request: schemas.AIChatRequest, 
    current_user: models.User = Depends(get_current_user),
    x_gemini_api_key: str | None = Header(default=None) 
):
    user_msg = request.message
    api_key_to_use = x_gemini_api_key or current_user.gemini_api_key
    
    if api_key_to_use:
        system_prompt = f"Sen 'ToAiDo' asistanısın. Kullanıcı: {current_user.full_name}. Soru: {user_msg}"
        ai_response = ask_gemini_http(api_key_to_use, system_prompt)
        if ai_response:
            return {"response": ai_response}

    return {"response": "API Anahtarı yok veya AI cevap vermedi."}

# 2. GÖREV OLUŞTURUCU
@router.post("/generate", response_model=schemas.AIGenerateResponse)
def generate_tasks_from_ai(
    request: schemas.AIGenerateRequest, 
    db: Session = Depends(get_db), 
    current_user: models.User = Depends(get_current_user),
    x_gemini_api_key: str | None = Header(default=None)
):
    topic = request.topic
    api_key_to_use = x_gemini_api_key or current_user.gemini_api_key
    
    if api_key_to_use:
        prompt = f"""
        Konu: '{topic}'.
        Bu hedef için 5-10 tane somut, kısa görev başlığı listele.
        SADECE JSON string listesi döndür. Markdown yok.
        Örnek: ["Görev 1", "Görev 2"]
        """
        
        ai_text = ask_gemini_http(api_key_to_use, prompt)
        
        if ai_text:
            try:
                # Markdown temizliği (```json ... ```)
                cleaned_text = ai_text.replace("```json", "").replace("```", "").strip()
                
                # Sadece köşeli parantez [...] arasını al
                start = cleaned_text.find('[')
                end = cleaned_text.rfind(']') + 1
                if start != -1 and end != -1:
                    cleaned_text = cleaned_text[start:end]

                task_titles = json.loads(cleaned_text)
                
                # Listeyi dön (Kaydetme işlemi yok, sadece öneri)
                return {
                    "message": "AI önerilerini hazırladı.",
                    "suggestions": task_titles
                }
            except Exception as e:
                print(f"JSON Parse Hatası: {e}")

    # Hata durumunda boş liste dön
    return {
        "message": "AI cevap veremedi veya API Key eksik.",
        "suggestions": []
    }