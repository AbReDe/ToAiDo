# backend/routers/tasks.py

from fastapi import APIRouter, Depends, HTTPException
from sqlalchemy.orm import Session
from typing import List
import schemas, models
from dependencies import get_db, get_current_user # Ortak fonksiyonlar

router = APIRouter(
    prefix="/tasks",
    tags=["Tasks"]
)

# 1. Görevleri Getir
@router.get("/", response_model=List[schemas.TaskResponse])
def get_tasks(db: Session = Depends(get_db), current_user: models.User = Depends(get_current_user)):
    return db.query(models.Task).filter(models.Task.owner_id == current_user.id).order_by(models.Task.due_date).all()

# 2. Görev Ekle
@router.post("/", response_model=schemas.TaskResponse)
def create_task(
    task: schemas.TaskCreate, 
    db: Session = Depends(get_db), 
    current_user: models.User = Depends(get_current_user)
):
    new_task = models.Task(
        title=task.title,
        description=task.description,
        priority=task.priority,
        due_date=task.due_date,
        status="Yapılacak",
        owner_id=current_user.id,
        
        # --- YENİ ALANLARI KAYDET ---
        repeat=task.repeat,
        tags=task.tags
        # ----------------------------
    )
    db.add(new_task)
    db.commit()
    db.refresh(new_task)
    return new_task


# 3. Görev Sil
@router.delete("/{task_id}")
def delete_task(task_id: int, db: Session = Depends(get_db), current_user: models.User = Depends(get_current_user)):
    task = db.query(models.Task).filter(models.Task.id == task_id, models.Task.owner_id == current_user.id).first()
    if not task:
        raise HTTPException(status_code=404, detail="Görev bulunamadı")
    
    db.delete(task)
    db.commit()
    return {"message": "Görev silindi"}

# 4. Görev Güncelle
@router.put("/{task_id}", response_model=schemas.TaskResponse)
def update_task(task_id: int, task_update: schemas.TaskUpdate, db: Session = Depends(get_db), current_user: models.User = Depends(get_current_user)):
    task = db.query(models.Task).filter(models.Task.id == task_id, models.Task.owner_id == current_user.id).first()
    if not task:
        raise HTTPException(status_code=404, detail="Görev bulunamadı")
        
    if task_update.status: task.status = task_update.status
    if task_update.title: task.title = task_update.title
    if task_update.priority: task.priority = task_update.priority
        
    db.commit()
    db.refresh(task)
    return task

# 5. GÖREVİ ÜZERİNE AL (ASSIGN)
@router.put("/{task_id}/assign", response_model=schemas.TaskResponse)
def assign_task(task_id: int, db: Session = Depends(get_db), current_user: models.User = Depends(get_current_user)):
    task = db.query(models.Task).filter(models.Task.id == task_id).first()
    if not task:
        raise HTTPException(status_code=404, detail="Görev bulunamadı")
    
    # Görev zaten birindeyse ve o kişi ben değilsem?
    if task.owner_id is not None and task.owner_id != current_user.id:
        raise HTTPException(status_code=400, detail="Bu görev zaten başkası tarafından alınmış")

    task.owner_id = current_user.id
    task.status = "Devam Ediyor" # Durumu güncelle
    db.commit()
    db.refresh(task)
    return task

# 6. GÖREVİ BIRAK (UNASSIGN)
@router.put("/{task_id}/unassign", response_model=schemas.TaskResponse)
def unassign_task(task_id: int, db: Session = Depends(get_db), current_user: models.User = Depends(get_current_user)):
    task = db.query(models.Task).filter(models.Task.id == task_id).first()
    if not task:
        raise HTTPException(status_code=404, detail="Görev bulunamadı")
    
    # Sadece görevi alan kişi bırakabilir
    if task.owner_id != current_user.id:
        raise HTTPException(status_code=403, detail="Bu görevi bırakma yetkiniz yok")

    task.owner_id = None
    task.status = "Yapılacak" # Havuza geri döndü
    db.commit()
    db.refresh(task)
    return task

# 7. GÖREVİ TAMAMLA
@router.put("/{task_id}/complete", response_model=schemas.TaskResponse)
def complete_task(task_id: int, db: Session = Depends(get_db), current_user: models.User = Depends(get_current_user)):
    task = db.query(models.Task).filter(models.Task.id == task_id).first()
    if not task:
        raise HTTPException(status_code=404, detail="Görev bulunamadı")

    task.status = "Tamamlandı"
    db.commit()
    db.refresh(task)
    return task


@router.put("/{task_id}/toggle_date")
def toggle_task_date(
    task_id: int, 
    date: str, # Format: "YYYY-MM-DD"
    db: Session = Depends(get_db), 
    current_user: models.User = Depends(get_current_user)
):
    task = db.query(models.Task).filter(models.Task.id == task_id).first()
    if not task:
        raise HTTPException(status_code=404, detail="Görev bulunamadı")

    # Mevcut listeyi al (SQLAlchemy JSON listesini bazen kopyalamak gerekir)
    dates = list(task.completed_dates) if task.completed_dates else []

    if date in dates:
        dates.remove(date) # Varsa çıkar (Geri al)
    else:
        dates.append(date) # Yoksa ekle (Yapıldı)
    
    # Listeyi güncelle
    task.completed_dates = dates
    
    # Eğer bu normal bir görevse (tekrar yoksa) ve tarih eklendiyse status'u da güncelle
    if task.repeat == "none":
        task.status = "Tamamlandı" if dates else "Yapılacak"

    db.commit()
    db.refresh(task)
    return task