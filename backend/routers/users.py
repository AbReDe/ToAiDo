from fastapi import APIRouter, Depends, HTTPException
from sqlalchemy.orm import Session
from sqlalchemy import or_ # <-- İŞTE BU SATIR EKSİKTİ, EKLENDİ!
import schemas, models
from dependencies import get_db, get_current_user

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

        # Arkadaş Sayısı (or_ kullanıldığı için import gerekiyordu)
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