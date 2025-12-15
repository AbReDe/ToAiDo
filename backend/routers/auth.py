# backend/routers/auth.py

from fastapi import APIRouter, Depends, HTTPException, status
from fastapi.security import OAuth2PasswordRequestForm 
from sqlalchemy.orm import Session
import schemas, models, security
from dependencies import get_db # Dependencies'den çekiyoruz

# Router oluşturuyoruz
router = APIRouter(
    prefix="/auth", # Tüm url'ler /auth ile başlayacak
    tags=["Authentication"] # Swagger'da başlık
)

@router.post("/register", response_model=schemas.UserResponse)
def register_user(user: schemas.UserCreate, db: Session = Depends(get_db)):
    db_user = db.query(models.User).filter((models.User.email == user.email) | (models.User.username == user.username)).first()
    if db_user:
        raise HTTPException(status_code=400, detail="Kullanıcı zaten kayıtlı.")
    
    hashed_password = security.get_password_hash(user.password)
    new_user = models.User(username=user.username, email=user.email, full_name=user.full_name, password_hash=hashed_password)
    
    db.add(new_user)
    db.commit()
    db.refresh(new_user)
    return new_user



@router.post("/login", response_model=schemas.Token)
def login_user(form_data: OAuth2PasswordRequestForm = Depends(), db: Session = Depends(get_db)):
    # Artık 'user_credentials' yerine 'form_data' kullanıyoruz
    user = db.query(models.User).filter(models.User.username == form_data.username).first()
    
    if not user or not security.verify_password(form_data.password, user.password_hash):
        raise HTTPException(status_code=401, detail="Hatalı giriş bilgileri")
    
    access_token = security.create_access_token(data={"sub": user.username})
    return {"access_token": access_token, "token_type": "bearer"}