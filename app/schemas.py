from pydantic import BaseModel, EmailStr, Field, ConfigDict
from typing import List, Optional
from datetime import datetime

# User Schemas
class UserBase(BaseModel):
    username: str
    email: EmailStr

class UserCreate(UserBase):
    password: str

class UserResponse(UserBase):
    id: int
    is_active: bool
    created_at: datetime

    class Config:
        from_attributes = True

class Token(BaseModel):
    access_token: str
    token_type: str

class TokenData(BaseModel):
    username: Optional[str] = None

# Sensor Data Schemas
class SensorDataBase(BaseModel):
    level: float
    volume: float
    temperature: Optional[int] = None
    date: str

class SensorDataCreate(SensorDataBase):
    pass

class SensorDataResponse(SensorDataBase):
    id: int
    sensor_id: int
    created_at: datetime

    class Config:
        from_attributes = True

# Sensor Schemas
class SensorBase(BaseModel):
    name: str
    location: str
    sendDataTime: str
    sendInfoTime: str
    battery: int
    date: datetime
    defective: bool = False

class SensorCreate(SensorBase):
    external_id: str
    todayData: List[SensorDataCreate] = []

class SensorUpdate(BaseModel):
    name: Optional[str] = None
    location: Optional[str] = None
    sendDataTime: Optional[str] = None
    sendInfoTime: Optional[str] = None
    battery: Optional[int] = None
    date: Optional[datetime] = None
    defective: Optional[bool] = None
    todayData: Optional[List[SensorDataCreate]] = None

class SensorResponse(BaseModel):
    id: int
    external_id: str
    name: str
    location: str
    send_data_time: str = Field(serialization_alias="sendDataTime")
    send_info_time: str = Field(serialization_alias="sendInfoTime")
    battery: int
    date: datetime
    defective: bool = False
    created_at: datetime
    updated_at: datetime
    today_data: List[SensorDataResponse] = Field(default=[], serialization_alias="todayData")

    model_config = ConfigDict(from_attributes=True, populate_by_name=True, by_alias=True)
