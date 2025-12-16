# backend/routers/friends.py

from fastapi import APIRouter, Depends, HTTPException
from sqlalchemy.orm import Session
from sqlalchemy import or_, and_
from typing import List
import models, schemas
from dependencies import get_db, get_current_user

router = APIRouter(prefix="/friends", tags=["Friends"])

# 1. ARKADAŞ İSTEĞİ GÖNDER
@router.post("/request/{username}")
def send_friend_request(username: str, db: Session = Depends(get_db), current_user: models.User = Depends(get_current_user)):
    # Kullanıcı var mı?
    receiver = db.query(models.User).filter(models.User.username == username).first()
    if not receiver:
        raise HTTPException(status_code=404, detail="Kullanıcı bulunamadı")
    
    if receiver.id == current_user.id:
        raise HTTPException(status_code=400, detail="Kendine istek atamazsın")

    # Zaten istek var mı veya arkadaşlar mı?
    existing = db.query(models.Friendship).filter(
        or_(
            and_(models.Friendship.sender_id == current_user.id, models.Friendship.receiver_id == receiver.id),
            and_(models.Friendship.sender_id == receiver.id, models.Friendship.receiver_id == current_user.id)
        )
    ).first()

    if existing:
        if existing.status == "accepted":
            return {"message": "Zaten arkadaşsınız"}
        if existing.status == "pending":
            return {"message": "Zaten bekleyen bir istek var"}

    # Yeni İstek Oluştur
    new_friendship = models.Friendship(sender_id=current_user.id, receiver_id=receiver.id, status="pending")
    db.add(new_friendship)
    db.commit()
    return {"message": f"{username} kullanıcısına istek gönderildi"}

# 2. BEKLEYEN İSTEKLERİ GETİR (Bana gelenler)
@router.get("/requests", response_model=List[schemas.FriendResponse])
def get_pending_requests(db: Session = Depends(get_db), current_user: models.User = Depends(get_current_user)):
    # Alıcısı BEN olduğum ve statüsü 'pending' olanlar
    requests = db.query(models.Friendship).filter(
        models.Friendship.receiver_id == current_user.id,
        models.Friendship.status == "pending"
    ).all()

    # İsteği gönderenlerin bilgilerini çekip dönüyoruz
    result = []
    for req in requests:
        sender = db.query(models.User).filter(models.User.id == req.sender_id).first()
        if sender:
            result.append(schemas.FriendResponse(
                id=req.id, # İstek ID'si
                user_id=sender.id,
                username=sender.username,
                full_name=sender.full_name
            ))
    return result

# 3. ARKADAŞLARI GETİR (Kabul edilmişler)
@router.get("/", response_model=List[schemas.FriendResponse])
def get_friends(db: Session = Depends(get_db), current_user: models.User = Depends(get_current_user)):
    friendships = db.query(models.Friendship).filter(
        or_(models.Friendship.sender_id == current_user.id, models.Friendship.receiver_id == current_user.id),
        models.Friendship.status == "accepted"
    ).all()

    result = []
    for f in friendships:
        # Ben gönderdiysem -> Arkadaş Alıcıdır, Ben aldıysam -> Arkadaş Gönderendir
        friend_id = f.receiver_id if f.sender_id == current_user.id else f.sender_id
        friend = db.query(models.User).filter(models.User.id == friend_id).first()
        if friend:
            result.append(schemas.FriendResponse(
                id=f.id,
                user_id=friend.id,
                username=friend.username,
                full_name=friend.full_name
            ))
    return result

# 4. İSTEĞİ KABUL ET / REDDET
@router.put("/{friendship_id}/{action}") # action: accept veya reject
def respond_friend_request(friendship_id: int, action: str, db: Session = Depends(get_db), current_user: models.User = Depends(get_current_user)):
    request = db.query(models.Friendship).filter(
        models.Friendship.id == friendship_id,
        models.Friendship.receiver_id == current_user.id # Sadece alıcı cevap verebilir
    ).first()

    if not request:
        raise HTTPException(status_code=404, detail="İstek bulunamadı")

    if action == "accept":
        request.status = "accepted"
        db.commit()
        return {"message": "Arkadaşlık isteği kabul edildi"}
    elif action == "reject":
        db.delete(request)
        db.commit()
        return {"message": "İstek reddedildi ve silindi"}
    else:
        raise HTTPException(status_code=400, detail="Geçersiz işlem")