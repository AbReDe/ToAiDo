from fastapi import APIRouter, Depends, HTTPException, UploadFile, File # <-- File ve UploadFile eklendi
from sqlalchemy.orm import Session
from sqlalchemy import or_
import schemas, models
from dependencies import get_db, get_current_user
import shutil
import os
import time

router = APIRouter(
    prefix="/users",
    tags=["Users"]
)

# 1. PROFİL BİLGİLERİNİ GETİR
@router.get("/me", response_model=schemas.UserProfile)
def get_my_profile(
    db: Session = Depends(get_db),
    current_user: models.User = Depends(get_current_user)
):
    try:
        # İstatistikleri Hesapla
        total_count = db.query(models.Task).filter(models.Task.owner_id == current_user.id).count()
        
        completed_count = db.query(models.Task).filter(
            models.Task.owner_id == current_user.id,
            models.Task.status == "Tamamlandı"
        ).count()

        # Arkadaş Sayısı
        friends_count = db.query(models.Friendship).filter(
            or_(models.Friendship.sender_id == current_user.id, models.Friendship.receiver_id == current_user.id),
            models.Friendship.status == "accepted"
        ).count()

        print(f"🔍 DB'den Çekilen Key: {current_user.gemini_api_key}")

        return schemas.UserProfile(
            id=current_user.id,
            username=current_user.username,
            email=current_user.email,
            full_name=current_user.full_name if current_user.full_name else "",
            avatar_url=current_user.avatar_url, # <-- Avatar URL eklendi
            total_tasks=total_count,
            completed_tasks=completed_count,
            friends_count=friends_count,
            gemini_api_key=current_user.gemini_api_key 
        )
    except Exception as e:
        print(f"❌ Profil Getirme Hatası: {e}")
        raise HTTPException(status_code=500, detail="Profil bilgileri alınırken hata oluştu.")

# 2. PROFİL GÜNCELLE
@router.put("/me", response_model=schemas.UserResponse)
def update_my_profile(
    user_update: schemas.UserUpdate,
    db: Session = Depends(get_db),
    current_user: models.User = Depends(get_current_user)
):
    print("------------------------------------------------")
    print(f"📥 GÜNCELLEME İSTEĞİ: {user_update.dict(exclude_unset=True)}")

    # Email
    if user_update.email and user_update.email != current_user.email:
        check_email = db.query(models.User).filter(models.User.email == user_update.email).first()
        if check_email:
            raise HTTPException(status_code=400, detail="Bu e-posta kullanımda.")
        current_user.email = user_update.email

    # İsim
    if user_update.full_name:
        current_user.full_name = user_update.full_name
    
    # API Key
    if user_update.gemini_api_key is not None:
        current_user.gemini_api_key = user_update.gemini_api_key
        print(f"🔑 API Key Atandı: {user_update.gemini_api_key}")
    
    try:
        db.add(current_user)
        db.commit()
        db.refresh(current_user)
        print("💾 VERİTABANINA KAYDEDİLDİ.")
        return current_user
    except Exception as e:
        print(f"❌ Güncelleme Hatası: {e}")
        raise HTTPException(status_code=500, detail="Kaydedilemedi.")

# 3. PROFİL FOTOĞRAFI YÜKLE
@router.post("/me/avatar")
def upload_avatar(
    file: UploadFile = File(...),
    db: Session = Depends(get_db),
    current_user: models.User = Depends(get_current_user)
):
    try:
        # Klasör yoksa oluştur (Garanti olsun)
        if not os.path.exists("uploads"):
            os.makedirs("uploads")

        # Benzersiz dosya ismi oluştur
        timestamp = int(time.time())
        file_extension = file.filename.split(".")[-1]
        filename = f"user_{current_user.id}_{timestamp}.{file_extension}"
        file_location = f"uploads/{filename}"
        
        # Dosyayı kaydet
        with open(file_location, "wb") as buffer:
            shutil.copyfileobj(file.file, buffer)
            
        # Veritabanını güncelle
        url_path = f"/uploads/{filename}"
        current_user.avatar_url = url_path
        
        db.commit()
        db.refresh(current_user)
        
        return {"avatar_url": url_path}
    except Exception as e:
        print(f"❌ Fotoğraf Yükleme Hatası: {e}")
        raise HTTPException(status_code=500, detail="Fotoğraf yüklenemedi.")

# 4. KULLANICI ARA
@router.get("/search", response_model=list[schemas.UserBasicInfo])
def search_users(
    query: str, 
    db: Session = Depends(get_db), 
    current_user: models.User = Depends(get_current_user)
):
    if len(query) < 2:
        return []
        
    users = db.query(models.User).filter(
        models.User.id != current_user.id,
        or_(
            models.User.username.ilike(f"%{query}%"),
            models.User.full_name.ilike(f"%{query}%")
        )
    ).limit(10).all()
    
    return users