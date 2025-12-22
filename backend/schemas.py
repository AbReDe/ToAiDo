from pydantic import BaseModel, EmailStr
from typing import Optional, List
from datetime import datetime

# ===========================
# --- TEMEL YARDIMCI ŞEMALAR ---
# ===========================

# Bunu en başa koyduk ki diğerleri kullanabilsin
class UserBasicInfo(BaseModel):
    id: int
    username: str
    full_name: str
    avatar_url: Optional[str] = None
    class Config:
        from_attributes = True

# ===========================
# --- KULLANICI ŞEMALARI ---
# ===========================

class UserCreate(BaseModel):
    username: str
    email: EmailStr
    password: str
    full_name: str

class UserLogin(BaseModel):
    username: str
    password: str

class UserResponse(BaseModel):
    id: int
    username: str
    email: EmailStr
    full_name: str

    class Config:
        from_attributes = True

class Token(BaseModel):
    access_token: str
    token_type: str

class UserUpdate(BaseModel):
    full_name: Optional[str] = None
    email: Optional[EmailStr] = None
    gemini_api_key: Optional[str] = None

class UserProfile(BaseModel):
    id: int
    username: str
    email: EmailStr
    full_name: str
    avatar_url: Optional[str] = None
    total_tasks: int
    completed_tasks: int
    friends_count: int
    gemini_api_key: Optional[str] = None 
    

    class Config:
        from_attributes = True

# ===========================
# --- GÖREV (TASK) ŞEMALARI ---
# ===========================

class TaskCreate(BaseModel):
    title: str
    description: Optional[str] = None
    priority: str = "medium"
    status: Optional[str] = "Yapılacak"
    due_date: Optional[datetime] = None
    
    # --- YENİ ---
    repeat: Optional[str] = "none"
    tags: List[str] = [] 
    # ------------

# Görev güncellerken
class TaskUpdate(BaseModel):
    status: Optional[str] = None
    title: Optional[str] = None
    priority: Optional[str] = None
    # Güncelleme için de eklenebilir ama şimdilik gerek yok

# Frontend'e göndereceğimiz veri formatı
class TaskResponse(BaseModel):
    id: int
    title: str
    description: Optional[str]
    status: str
    priority: str
    due_date: Optional[datetime]
   
    
    # --- YENİ ---
    repeat: Optional[str] = "none"
    tags: List[str] = []
    # ------------
    completed_dates: List[str] = []
    owner_id: Optional[int] = None
    project_id: Optional[int] = None
    owner: Optional[UserBasicInfo] = None 
    created_at: datetime

    class Config:
        from_attributes = True


# ===========================
# --- PROJE (PROJECT) ŞEMALARI ---
# ===========================

class ProjectCreate(BaseModel):
    name: str
    description: Optional[str] = None

class ProjectResponse(BaseModel):
    id: int
    name: str
    description: Optional[str]
    owner_id: int
    created_at: datetime

    class Config:
        from_attributes = True

# ===========================
# --- ARKADAŞLIK (FRIEND) ŞEMALARI ---
# ===========================

class FriendResponse(BaseModel):
    id: int
    user_id: int
    username: str
    full_name: str
    avatar_url: Optional[str] = None

    class Config:
        from_attributes = True

# ===========================
# --- AI (YAPAY ZEKA) ŞEMALARI ---
# ===========================

class AIChatRequest(BaseModel):
    message: str

class AIGenerateRequest(BaseModel):
    topic: str

class AIGenerateResponse(BaseModel):
    message: str
    created_task_count: int



# --- PROJE DAVETİ ŞEMASI ---

class ProjectInvitationResponse(BaseModel):
    id: int
    project_id: int
    project_name: str  # Projenin adını direkt gönderelim
    sender_username: str # Gönderen kişinin adı
    status: str
    
    class Config:
        from_attributes = True



# --- AI (YAPAY ZEKA) ŞEMALARI ---
class AIChatRequest(BaseModel):
    message: str

class AIGenerateRequest(BaseModel):
    topic: str

class AIGenerateResponse(BaseModel):
    message: str
    created_task_count: int