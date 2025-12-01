from sqlalchemy import Boolean, Column, Integer, String, Float, DateTime, ForeignKey, JSON
from sqlalchemy.orm import relationship
from datetime import datetime
from app.database import Base

class User(Base):
    __tablename__ = "users"

    id = Column(Integer, primary_key=True, index=True)
    username = Column(String, unique=True, index=True, nullable=False)
    email = Column(String, unique=True, index=True, nullable=False)
    hashed_password = Column(String, nullable=False)
    is_active = Column(Boolean, default=True)
    created_at = Column(DateTime, default=datetime.utcnow)

class Sensor(Base):
    __tablename__ = "sensors"

    id = Column(Integer, primary_key=True, index=True)
    external_id = Column(String, unique=True, index=True, nullable=False)  # MongoDB _id
    name = Column(String, nullable=False)
    location = Column(String, nullable=False)
    send_data_time = Column(String, nullable=False)
    send_info_time = Column(String, nullable=False)
    battery = Column(Integer, nullable=False)
    date = Column(DateTime, nullable=False)
    defective = Column(Boolean, default=False)
    created_at = Column(DateTime, default=datetime.utcnow)
    updated_at = Column(DateTime, default=datetime.utcnow, onupdate=datetime.utcnow)
    
    # Relationship to sensor data
    today_data = relationship("SensorData", back_populates="sensor", cascade="all, delete-orphan")

class SensorData(Base):
    __tablename__ = "sensor_data"

    id = Column(Integer, primary_key=True, index=True)
    sensor_id = Column(Integer, ForeignKey("sensors.id"), nullable=False)
    level = Column(Float, nullable=False)
    volume = Column(Float, nullable=False)
    temperature = Column(Integer, nullable=True)  # Temperature in celsius
    date = Column(String, nullable=False)
    created_at = Column(DateTime, default=datetime.utcnow)
    
    # Relationship back to sensor
    sensor = relationship("Sensor", back_populates="today_data")
