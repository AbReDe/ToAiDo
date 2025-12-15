from fastapi import APIRouter, Depends, HTTPException
from sqlalchemy.orm import Session
from typing import List
import schemas, models
from dependencies import get_db, get_current_user

router = APIRouter(
    prefix="/projects",
    tags=["Projects"]
)

# 1. KULLANICININ PROJELERİNİ GETİR
@router.get("/", response_model=List[schemas.ProjectResponse])
def get_projects(
    db: Session = Depends(get_db), 
    current_user: models.User = Depends(get_current_user)
):
    return db.query(models.Project).filter(models.Project.owner_id == current_user.id).all()

# 2. YENİ PROJE OLUŞTUR
@router.post("/", response_model=schemas.ProjectResponse)
def create_project(
    project: schemas.ProjectCreate, 
    db: Session = Depends(get_db), 
    current_user: models.User = Depends(get_current_user)
):
    new_project = models.Project(
        name=project.name,
        description=project.description,
        owner_id=current_user.id
    )
    db.add(new_project)
    db.commit()
    db.refresh(new_project)
    return new_project

# 3. PROJE SİL
@router.delete("/{project_id}")
def delete_project(
    project_id: int, 
    db: Session = Depends(get_db), 
    current_user: models.User = Depends(get_current_user)
):
    project = db.query(models.Project).filter(
        models.Project.id == project_id, 
        models.Project.owner_id == current_user.id
    ).first()
    
    if not project:
        raise HTTPException(status_code=404, detail="Proje bulunamadı")
    
    db.delete(project)
    db.commit()
    return {"message": "Proje silindi"}

# 4. PROJEYE ÜYE EKLE (DAVET ET)
@router.post("/{project_id}/invite")
def invite_member(
    project_id: int, 
    username: str, 
    db: Session = Depends(get_db), 
    current_user: models.User = Depends(get_current_user)
):
    project = db.query(models.Project).filter(models.Project.id == project_id, models.Project.owner_id == current_user.id).first()
    if not project:
        raise HTTPException(status_code=404, detail="Proje bulunamadı veya yetkiniz yok")
    
    new_member = db.query(models.User).filter(models.User.username == username).first()
    if not new_member:
        raise HTTPException(status_code=404, detail="Kullanıcı bulunamadı")
    
    if new_member in project.members:
        raise HTTPException(status_code=400, detail="Kullanıcı zaten projede")
    
    project.members.append(new_member)
    db.commit()
    return {"message": f"{username} projeye eklendi!"}

# --- İŞTE EKSİK OLAN / HATALI OLAN KISIMLAR BURASIYDI ---

# 5. PROJENİN GÖREVLERİNİ GETİR (GET REQUEST)
@router.get("/{project_id}/tasks", response_model=List[schemas.TaskResponse])
def get_project_tasks(
    project_id: int,
    db: Session = Depends(get_db),
    current_user: models.User = Depends(get_current_user)
):
    # Proje var mı?
    project = db.query(models.Project).filter(models.Project.id == project_id).first()
    if not project:
        raise HTTPException(status_code=404, detail="Proje bulunamadı")
    
    # Yetki kontrolü (Sahibi mi veya Üyesi mi?)
    # Not: Basitlik adına şimdilik herkes görebilsin diye bu if'i yoruma alabilirsin, 
    # ama doğrusu budur:
    if project.owner_id != current_user.id and current_user not in project.members:
         raise HTTPException(status_code=403, detail="Bu projeyi görme yetkiniz yok")

    return project.tasks

# 6. PROJEYE GÖREV EKLE (POST REQUEST)
@router.post("/{project_id}/tasks", response_model=schemas.TaskResponse)
def create_project_task(
    project_id: int,
    task: schemas.TaskCreate,
    db: Session = Depends(get_db),
    current_user: models.User = Depends(get_current_user)
):
    project = db.query(models.Project).filter(models.Project.id == project_id).first()
    if not project:
         raise HTTPException(status_code=404, detail="Proje bulunamadı")

    new_task = models.Task(
        title=task.title,
        description=task.description,
        status="Yapılacak",
        priority=task.priority,
        due_date=task.due_date,
        project_id=project_id,
        owner_id=None 
    )
    db.add(new_task)
    db.commit()
    db.refresh(new_task)
    return new_task