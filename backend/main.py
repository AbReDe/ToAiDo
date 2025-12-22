# backend/main.py

from fastapi import FastAPI
import models, database
from routers import auth, tasks , users, projects, friends , ai
import os
from fastapi.staticfiles import StaticFiles

# Tabloları oluştur
models.Base.metadata.create_all(bind=database.engine)

app = FastAPI(
    title="ToAiDo API",
    description="ToAiDo Mobil Uygulaması için Profesyonel Backend",
    version="1.0.0"
)

if not os.path.exists("uploads"):
    os.makedirs("uploads")

models.Base.metadata.create_all(bind=database.engine)

app = FastAPI(title="ToAiDo API")

# --- 3. BU SATIRI EKLE (Resimleri dışarı açar) ---
app.mount("/uploads", StaticFiles(directory="uploads"), name="uploads")

# Routerları ana uygulamaya dahil et
app.include_router(auth.router)
app.include_router(tasks.router)
app.include_router(users.router) 
app.include_router(projects.router) 
app.include_router(friends.router) 
app.include_router(ai.router)

@app.get("/")
def root():
    return {"message": "ToAiDo Backend Sistemine Hoşgeldiniz! 🚀"}

