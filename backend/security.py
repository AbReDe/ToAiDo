# security.py
from passlib.context import CryptContext
from datetime import datetime, timedelta
from jose import jwt

# Şifreleme ayarları
pwd_context = CryptContext(schemes=["bcrypt"], deprecated="auto")

# JWT Ayarları (Bunu gerçek projede .env dosyasında saklamalısın)
SECRET_KEY = "cok_gizli_super_anahtar_buraya_yazilacak"
ALGORITHM = "HS256"
ACCESS_TOKEN_EXPIRE_MINUTES = 60 * 24 # 1 gün geçerli

# Şifreyi Hashle (Gizle)
def get_password_hash(password):
    return pwd_context.hash(password)

# Şifreyi Doğrula
def verify_password(plain_password, hashed_password):
    return pwd_context.verify(plain_password, hashed_password)

# Token Oluştur
def create_access_token(data: dict):
    to_encode = data.copy()
    expire = datetime.utcnow() + timedelta(minutes=ACCESS_TOKEN_EXPIRE_MINUTES)
    to_encode.update({"exp": expire})
    encoded_jwt = jwt.encode(to_encode, SECRET_KEY, algorithm=ALGORITHM)
    return encoded_jwt