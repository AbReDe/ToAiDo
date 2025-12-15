# backend/main.py

from fastapi import FastAPI
import models, database
from routers import auth, tasks , users, projects 

# Tabloları oluştur
models.Base.metadata.create_all(bind=database.engine)

app = FastAPI(
    title="ToAiDo API",
    description="ToAiDo Mobil Uygulaması için Profesyonel Backend",
    version="1.0.0"
)

# Routerları ana uygulamaya dahil et
app.include_router(auth.router)
app.include_router(tasks.router)
app.include_router(users.router) 
app.include_router(projects.router) 

@app.get("/")
def root():
    return {"message": "ToAiDo Backend Sistemine Hoşgeldiniz! 🚀"}

