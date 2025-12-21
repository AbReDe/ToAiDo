# backend/routers/projects.py (GÜNCELLENMİŞ TAM HALİ)

from fastapi import APIRouter, Depends, HTTPException
from sqlalchemy.orm import Session
from typing import List
import schemas, models
from dependencies import get_db, get_current_user

router = APIRouter(prefix="/projects", tags=["Projects"])

# 1. PROJELERİ GETİR (Sahibi olduklarım + Üye olduklarım)
@router.get("/", response_model=List[schemas.ProjectResponse])
def get_projects(db: Session = Depends(get_db), current_user: models.User = Depends(get_current_user)):
    # 1. Sahibi olduğum projeler
    owned_projects = db.query(models.Project).filter(models.Project.owner_id == current_user.id).all()
    
    # 2. Üyesi olduğum projeler (Many-to-Many ilişkisinden gelir)
    member_projects = current_user.joined_projects
    
    # İkisini birleştirip (tekrarsız) dön
    return list(set(owned_projects + member_projects))

# 2. PROJE OLUŞTUR
@router.post("/", response_model=schemas.ProjectResponse)
def create_project(project: schemas.ProjectCreate, db: Session = Depends(get_db), current_user: models.User = Depends(get_current_user)):
    new_project = models.Project(name=project.name, description=project.description, owner_id=current_user.id)
    db.add(new_project)
    db.commit()
    db.refresh(new_project)
    return new_project

# 3. PROJE SİL
@router.delete("/{project_id}")
def delete_project(project_id: int, db: Session = Depends(get_db), current_user: models.User = Depends(get_current_user)):
    project = db.query(models.Project).filter(models.Project.id == project_id, models.Project.owner_id == current_user.id).first()
    if not project:
        raise HTTPException(status_code=404, detail="Proje bulunamadı veya yetkiniz yok")
    db.delete(project)
    db.commit()
    return {"message": "Proje silindi"}

# --- DAVET SİSTEMİ ---

# 4. DAVET GÖNDER (Eski invite_member güncellendi)
@router.post("/{project_id}/invite")
def invite_member(project_id: int, username: str, db: Session = Depends(get_db), current_user: models.User = Depends(get_current_user)):
    project = db.query(models.Project).filter(models.Project.id == project_id, models.Project.owner_id == current_user.id).first()
    if not project:
        raise HTTPException(status_code=404, detail="Proje bulunamadı veya yetki yok")
    
    receiver = db.query(models.User).filter(models.User.username == username).first()
    if not receiver:
        raise HTTPException(status_code=404, detail="Kullanıcı bulunamadı")
    
    # Zaten üye mi?
    if receiver in project.members or receiver.id == project.owner_id:
        raise HTTPException(status_code=400, detail="Kullanıcı zaten projede")

    # Zaten davet var mı?
    existing_invite = db.query(models.ProjectInvitation).filter(
        models.ProjectInvitation.project_id == project.id,
        models.ProjectInvitation.receiver_id == receiver.id,
        models.ProjectInvitation.status == "pending"
    ).first()
    
    if existing_invite:
        return {"message": "Zaten bekleyen bir davet var"}

    # Davet oluştur
    invite = models.ProjectInvitation(project_id=project.id, sender_id=current_user.id, receiver_id=receiver.id)
    db.add(invite)
    db.commit()
    return {"message": f"{username} kullanıcısına davet gönderildi"}

# 5. BANA GELEN DAVETLERİ GÖR
@router.get("/invitations/my", response_model=List[schemas.ProjectInvitationResponse])
def get_my_invitations(db: Session = Depends(get_db), current_user: models.User = Depends(get_current_user)):
    invites = db.query(models.ProjectInvitation).filter(
        models.ProjectInvitation.receiver_id == current_user.id,
        models.ProjectInvitation.status == "pending"
    ).all()
    
    # Response modeline uygun hale getir
    result = []
    for inv in invites:
        result.append(schemas.ProjectInvitationResponse(
            id=inv.id,
            project_id=inv.project_id,
            project_name=inv.project.name,
            sender_username=inv.sender.username,
            status=inv.status
        ))
    return result

# 6. DAVETE CEVAP VER (Kabul/Red)
@router.put("/invitations/{invite_id}/{action}")
def respond_invitation(invite_id: int, action: str, db: Session = Depends(get_db), current_user: models.User = Depends(get_current_user)):
    invite = db.query(models.ProjectInvitation).filter(
        models.ProjectInvitation.id == invite_id,
        models.ProjectInvitation.receiver_id == current_user.id
    ).first()
    
    if not invite:
        raise HTTPException(status_code=404, detail="Davet bulunamadı")

    if action == "accept":
        # Kullanıcıyı projeye üye yap
        project = db.query(models.Project).filter(models.Project.id == invite.project_id).first()
        if project:
            project.members.append(current_user)
            db.delete(invite) # Daveti sil (veya status='accepted' yapıp saklayabilirsin)
            db.commit()
            return {"message": "Projeye katıldınız!"}
    
    elif action == "reject":
        db.delete(invite)
        db.commit()
        return {"message": "Davet reddedildi"}
    
    return {"message": "İşlem başarısız"}

# --- GÖREVLER (Eski kodlar aynı kalıyor) ---
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
    
    # Yetki kontrolü (kısa versiyon)
    if project.owner_id != current_user.id and current_user not in project.members:
         raise HTTPException(status_code=403, detail="Yetkiniz yok")

    new_task = models.Task(
        title=task.title,
        description=task.description,
        status="Yapılacak",
        priority=task.priority,
        due_date=task.due_date,
        project_id=project_id,
        owner_id=None,
        
        # --- YENİ ALANLAR ---
        repeat=task.repeat,
        tags=task.tags
        # --------------------
    )
    db.add(new_task)
    db.commit()
    db.refresh(new_task)
    return new_task

@router.post("/{project_id}/tasks", response_model=schemas.TaskResponse)
def create_project_task(project_id: int, task: schemas.TaskCreate, db: Session = Depends(get_db), current_user: models.User = Depends(get_current_user)):
    # ... (Eski kodun aynısı) ...
    project = db.query(models.Project).filter(models.Project.id == project_id).first()
    # Üye olan da görev ekleyebilir
    if not project or (project.owner_id != current_user.id and current_user not in project.members):
         raise HTTPException(status_code=403, detail="Yetkiniz yok")

    new_task = models.Task(title=task.title, description=task.description, status="Yapılacak", priority=task.priority, due_date=task.due_date, project_id=project_id, owner_id=None)
    db.add(new_task)
    db.commit()
    db.refresh(new_task)
    return new_task 


# 7. PROJE ÜYELERİNİ GETİR
@router.get("/{project_id}/members", response_model=List[schemas.UserBasicInfo])
def get_project_members(
    project_id: int,
    db: Session = Depends(get_db),
    current_user: models.User = Depends(get_current_user)
):
    project = db.query(models.Project).filter(models.Project.id == project_id).first()
    
    if not project:
        raise HTTPException(status_code=404, detail="Proje bulunamadı")
    
    # Erişim kontrolü
    if project.owner_id != current_user.id and current_user not in project.members:
         raise HTTPException(status_code=403, detail="Erişim yetkiniz yok")

    # Listeyi oluştur: [Sahip] + [Diğer Üyeler]
    # Set kullanarak aynı kişinin iki kere listede olmasını engelliyoruz
    all_members = [project.owner] + project.members
    
    # User objelerini ID'lerine göre benzersiz yapıyoruz
    unique_members = {user.id: user for user in all_members}.values()
    
    return list(unique_members)


@router.get("/{project_id}/tasks", response_model=List[schemas.TaskResponse])
def get_project_tasks(
    project_id: int,
    db: Session = Depends(get_db),
    current_user: models.User = Depends(get_current_user)
):
    project = db.query(models.Project).filter(models.Project.id == project_id).first()
    
    if not project:
        raise HTTPException(status_code=404, detail="Proje bulunamadı")
        
    # Erişim kontrolü
    if project.owner_id != current_user.id and current_user not in project.members:
         raise HTTPException(status_code=403, detail="Erişim yetkiniz yok")

    return project.tasks