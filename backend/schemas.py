from pydantic import BaseModel, EmailStr
from typing import Optional
from datetime import datetime

# ===========================
# --- KULLANICI ŞEMALARI ---
# ===========================

# Kayıt olurken istenecek veriler
class UserCreate(BaseModel):
    username: str
    email: EmailStr
    password: str
    full_name: str

# Giriş yaparken istenecek veriler
class UserLogin(BaseModel):
    username: str
    password: str

# Kullanıcıya geri döndüreceğimiz veri (Şifre gizli)
class UserResponse(BaseModel):
    id: int
    username: str
    email: EmailStr
    full_name: str

    class Config:
        from_attributes = True

# Token Dönüş Modeli
class Token(BaseModel):
    access_token: str
    token_type: str


# ===========================
# --- GÖREV (TASK) ŞEMALARI ---
# ===========================

# Görev oluştururken Frontend'den gelecek veri
class TaskCreate(BaseModel):
    title: str
    description: Optional[str] = None
    priority: str = "medium"
    status: Optional[str] = "Yapılacak"
    due_date: Optional[datetime] = None

# Görev güncellerken (Tamamlandı/Yapılacak)
class TaskUpdate(BaseModel):
    status: Optional[str] = None
    title: Optional[str] = None
    priority: Optional[str] = None

# Frontend'e göndereceğimiz veri formatı
class TaskResponse(BaseModel):
    id: int
    title: str
    description: Optional[str]
    status: str
    priority: str
    due_date: Optional[datetime]
    
    # Proje görevlerinde sahibi atanmamış olabilir, o yüzden Optional yapıyoruz
    owner_id: Optional[int] = None 
    
    # Görevin ait olduğu proje (varsa)
    project_id: Optional[int] = None
    
    created_at: datetime

    class Config:
        from_attributes = True


# ===========================
# --- PROJE (PROJECT) ŞEMALARI ---
# ===========================

# Proje oluştururken istenecek veri
class ProjectCreate(BaseModel):
    name: str
    description: Optional[str] = None

# Proje listelerken Frontend'e döneceğimiz veri
class ProjectResponse(BaseModel):
    id: int
    name: str
    description: Optional[str]
    owner_id: int
    created_at: datetime

    class Config:
        from_attributes = True


# ===========================
# --- KULLANICI PROFİL İŞLEMLERİ ---
# ===========================

# Kullanıcı bilgilerini güncellerken gönderilecek veri (Hepsi opsiyonel)
class UserUpdate(BaseModel):
    full_name: Optional[str] = None
    email: Optional[EmailStr] = None

# Profil sayfasında gösterilecek veri (İstatistikler dahil)
class UserProfile(BaseModel):
    id: int
    username: str
    email: EmailStr
    full_name: str
    total_tasks: int      # Toplam Görev Sayısı
    completed_tasks: int  # Biten Görev Sayısı
    friends_count: int    # Arkadaş Sayısı

    class Config:
        from_attributes = True





        # --- ARKADAŞLIK ŞEMALARI ---

# Arkadaş Listesi Öğesi
class FriendResponse(BaseModel):
    id: int         # Arkadaşlık ID'si (Kabul/Red için lazım)
    user_id: int    # Arkadaşın User ID'si
    username: str
    full_name: str
    avatar_url: Optional[str] = None

    class Config:
        from_attributes = True