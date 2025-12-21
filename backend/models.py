from sqlalchemy import Column, Integer, String, DateTime, ForeignKey, Table, Boolean, JSON
from sqlalchemy.sql import func
from sqlalchemy.orm import relationship
from database import Base

# --- ARA TABLO: PROJE ÜYELERİ ---
project_members = Table(
    'project_members',
    Base.metadata,
    Column('user_id', Integer, ForeignKey('users.id')),
    Column('project_id', Integer, ForeignKey('projects.id'))
)

# --- KULLANICI ---
class User(Base):
    __tablename__ = "users"

    id = Column(Integer, primary_key=True, index=True)
    username = Column(String, unique=True, index=True, nullable=False)
    email = Column(String, unique=True, index=True, nullable=False)
    password_hash = Column(String, nullable=False)
    full_name = Column(String)
    gemini_api_key = Column(String, nullable=True)
    created_at = Column(DateTime(timezone=True), server_default=func.now())

    tasks = relationship("Task", back_populates="owner")
    owned_projects = relationship("Project", back_populates="owner")
    joined_projects = relationship("Project", secondary=project_members, back_populates="members")

# --- PROJE ---
class Project(Base):
    __tablename__ = "projects"

    id = Column(Integer, primary_key=True, index=True)
    name = Column(String, nullable=False)
    description = Column(String, nullable=True)
    owner_id = Column(Integer, ForeignKey("users.id"))
    created_at = Column(DateTime(timezone=True), server_default=func.now())

    owner = relationship("User", back_populates="owned_projects")
    members = relationship("User", secondary=project_members, back_populates="joined_projects")
    tasks = relationship("Task", back_populates="project", cascade="all, delete")

# --- PROJE DAVETLERİ ---
class ProjectInvitation(Base):
    __tablename__ = "project_invitations"

    id = Column(Integer, primary_key=True, index=True)
    project_id = Column(Integer, ForeignKey("projects.id"))
    sender_id = Column(Integer, ForeignKey("users.id"))
    receiver_id = Column(Integer, ForeignKey("users.id"))
    status = Column(String, default="pending") 
    created_at = Column(DateTime(timezone=True), server_default=func.now())

    project = relationship("Project")
    sender = relationship("User", foreign_keys=[sender_id])
    receiver = relationship("User", foreign_keys=[receiver_id])

# --- GÖREV (GÜNCELLENDİ) ---
class Task(Base):
    __tablename__ = "tasks"

    id = Column(Integer, primary_key=True, index=True)
    title = Column(String, nullable=False)
    description = Column(String, nullable=True)
    status = Column(String, default="Yapılacak")
    priority = Column(String, default="medium")
    due_date = Column(DateTime, nullable=True)
    completed_dates = Column(JSON, default=[])
    
    # --- YENİ EKLENEN ALANLAR ---
    repeat = Column(String, default="none") # daily, weekly, monthly, none
    tags = Column(JSON, default=[])         # ["yazılım", "spor"]
    # ----------------------------

    owner_id = Column(Integer, ForeignKey("users.id"), nullable=True)
    project_id = Column(Integer, ForeignKey("projects.id"), nullable=True) 

    created_at = Column(DateTime(timezone=True), server_default=func.now())

    owner = relationship("User", back_populates="tasks")
    project = relationship("Project", back_populates="tasks")
    
    # Arkadaşlık tablosu
class Friendship(Base):
    __tablename__ = "friendships"

    id = Column(Integer, primary_key=True, index=True)
    sender_id = Column(Integer, ForeignKey("users.id"))
    receiver_id = Column(Integer, ForeignKey("users.id"))
    status = Column(String, default="pending") 
    created_at = Column(DateTime(timezone=True), server_default=func.now())