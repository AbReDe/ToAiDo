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
def create_task(task: schemas.TaskCreate, db: Session = Depends(get_db), current_user: models.User = Depends(get_current_user)):
    new_task = models.Task(
        title=task.title,
        description=task.description,
        priority=task.priority,
        due_date=task.due_date,
        owner_id=current_user.id
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