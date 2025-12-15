# backend/routers/users.py (YENİ DOSYA)

from fastapi import APIRouter, Depends, HTTPException
from sqlalchemy.orm import Session
import schemas, models
from dependencies import get_db, get_current_user

router = APIRouter(
    prefix="/users",
    tags=["Users"]
)

# 1. PROFİL BİLGİLERİNİ VE İSTATİSTİKLERİ GETİR (/users/me)
@router.get("/me", response_model=schemas.UserProfile)
def get_my_profile(
    db: Session = Depends(get_db),
    current_user: models.User = Depends(get_current_user)
):
    # İstatistikleri Hesapla
    # 1. Toplam Görev Sayısı (Bu kullanıcının)
    total_count = db.query(models.Task).filter(models.Task.owner_id == current_user.id).count()
    
    # 2. Tamamlanan Görev Sayısı
    completed_count = db.query(models.Task).filter(
        models.Task.owner_id == current_user.id,
        models.Task.status == "Tamamlandı" # Flutter'da "Tamamlandı" olarak kaydetmiştik
    ).count()

    # 3. Arkadaş Sayısı (İleride Team tablosu gelince oradan çekeceğiz, şimdilik 0)
    friends_count = 0 

    # Response Modelini Doldur
    return schemas.UserProfile(
        id=current_user.id,
        username=current_user.username,
        email=current_user.email,
        full_name=current_user.full_name,
        total_tasks=total_count,
        completed_tasks=completed_count,
        friends_count=friends_count
    )

# 2. PROFİL GÜNCELLE (/users/me)
@router.put("/me", response_model=schemas.UserResponse)
def update_my_profile(
    user_update: schemas.UserUpdate,
    db: Session = Depends(get_db),
    current_user: models.User = Depends(get_current_user)
):
    # Email değişiyorsa, başkasında var mı diye kontrol et
    if user_update.email and user_update.email != current_user.email:
        check_email = db.query(models.User).filter(models.User.email == user_update.email).first()
        if check_email:
            raise HTTPException(status_code=400, detail="Bu e-posta adresi zaten kullanımda.")
        current_user.email = user_update.email

    # İsim güncelle
    if user_update.full_name:
        current_user.full_name = user_update.full_name
    
    db.commit()
    db.refresh(current_user)
    return current_user