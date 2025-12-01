from fastapi import APIRouter, Depends, HTTPException, status
from sqlalchemy.orm import Session
from typing import List
from app.database import get_db
from app.models import Sensor, SensorData, User
from app.schemas import SensorCreate, SensorResponse, SensorUpdate
from app.auth import get_current_active_user

router = APIRouter(prefix="/sensors", tags=["Sensors"])

@router.post("/", response_model=SensorResponse, status_code=status.HTTP_201_CREATED)
def create_sensor(
    sensor: SensorCreate, 
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_active_user)
):
    # Check if sensor with external_id already exists
    db_sensor = db.query(Sensor).filter(Sensor.external_id == sensor.external_id).first()
    if db_sensor:
        raise HTTPException(status_code=400, detail="Sensor with this external_id already exists")
    
    # Create sensor
    db_sensor = Sensor(
        external_id=sensor.external_id,
        name=sensor.name,
        location=sensor.location,
        send_data_time=sensor.sendDataTime,
        send_info_time=sensor.sendInfoTime,
        battery=sensor.battery,
        date=sensor.date,
        defective=sensor.defective
    )
    db.add(db_sensor)
    db.commit()
    db.refresh(db_sensor)
    
    # Create sensor data entries
    for data in sensor.todayData:
        db_data = SensorData(
            sensor_id=db_sensor.id,
            level=data.level,
            volume=data.volume,
            temperature=data.temperature,
            date=data.date
        )
        db.add(db_data)
    
    db.commit()
    db.refresh(db_sensor)
    return db_sensor

@router.get("/", response_model=List[SensorResponse])
def get_sensors(
    skip: int = 0, 
    limit: int = 100,
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_active_user)
):
    sensors = db.query(Sensor).offset(skip).limit(limit).all()
    return sensors

@router.get("/{sensor_id}", response_model=SensorResponse)
def get_sensor(
    sensor_id: int,
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_active_user)
):
    sensor = db.query(Sensor).filter(Sensor.id == sensor_id).first()
    if sensor is None:
        raise HTTPException(status_code=404, detail="Sensor not found")
    return sensor

@router.get("/external/{external_id}", response_model=SensorResponse)
def get_sensor_by_external_id(
    external_id: str,
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_active_user)
):
    sensor = db.query(Sensor).filter(Sensor.external_id == external_id).first()
    if sensor is None:
        raise HTTPException(status_code=404, detail="Sensor not found")
    return sensor

@router.put("/{sensor_id}", response_model=SensorResponse)
def update_sensor(
    sensor_id: int,
    sensor_update: SensorUpdate,
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_active_user)
):
    db_sensor = db.query(Sensor).filter(Sensor.id == sensor_id).first()
    if db_sensor is None:
        raise HTTPException(status_code=404, detail="Sensor not found")
    
    # Update sensor fields
    update_data = sensor_update.dict(exclude_unset=True, exclude={"todayData"})
    
    # Map camelCase to snake_case
    field_mapping = {
        "sendDataTime": "send_data_time",
        "sendInfoTime": "send_info_time"
    }
    
    for field, value in update_data.items():
        db_field = field_mapping.get(field, field)
        setattr(db_sensor, db_field, value)
    
    # Update today_data if provided
    if sensor_update.todayData is not None:
        # Delete existing data
        db.query(SensorData).filter(SensorData.sensor_id == sensor_id).delete()
        
        # Add new data
        for data in sensor_update.todayData:
            db_data = SensorData(
                sensor_id=sensor_id,
                level=data.level,
                volume=data.volume,
                temperature=data.temperature,
                date=data.date
            )
            db.add(db_data)
    
    db.commit()
    db.refresh(db_sensor)
    return db_sensor

@router.delete("/{sensor_id}", status_code=status.HTTP_204_NO_CONTENT)
def delete_sensor(
    sensor_id: int,
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_active_user)
):
    db_sensor = db.query(Sensor).filter(Sensor.id == sensor_id).first()
    if db_sensor is None:
        raise HTTPException(status_code=404, detail="Sensor not found")
    
    db.delete(db_sensor)
    db.commit()
    return None
