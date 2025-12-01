# API Examples - Quick Reference

## Setup Steps

### 1. Install Dependencies
```bash
python -m venv venv
source venv/bin/activate
pip install -r requirements.txt
```

### 2. Configure Database
Create a `.env` file:
```bash
cp .env.example .env
```

Edit `.env` with your PostgreSQL credentials:
```
DATABASE_URL=postgresql://your_user:your_password@localhost:5432/sensor_db
SECRET_KEY=your-secret-key-here
ALGORITHM=HS256
ACCESS_TOKEN_EXPIRE_MINUTES=30
```

### 3. Create PostgreSQL Database
```bash
# Login to PostgreSQL
psql -U postgres

# Create database
CREATE DATABASE sensor_db;
```

### 4. Run the Application
```bash
uvicorn app.main:app --reload
# Or use the script:
./run.sh
```

## Testing with cURL

### 1. Register a User
```bash
curl -X POST "http://localhost:8000/auth/register" \
  -H "Content-Type: application/json" \
  -d '{
    "username": "testuser",
    "email": "test@example.com",
    "password": "testpassword123"
  }'
```

### 2. Login and Get Token
```bash
curl -X POST "http://localhost:8000/auth/token" \
  -H "Content-Type: application/x-www-form-urlencoded" \
  -d "username=testuser&password=testpassword123"
```

**Save the access_token from the response!**

### 3. Create a Sensor (with authentication)
```bash
curl -X POST "http://localhost:8000/sensors/" \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer YOUR_ACCESS_TOKEN" \
  -d '{
    "external_id": "68fdde281540e282dbebdefe",
    "name": "Janubiy Surxon S.O",
    "location": "67.615645-37.8337474",
    "sendDataTime": "60",
    "sendInfoTime": "1440",
    "battery": 98,
    "date": "2022-02-24T11:59:29.000Z",
    "defective": false,
    "todayData": [
      {
        "level": 406.2,
        "volume": 0,
        "date": "2025-11-21 11:00"
      },
      {
        "level": 406.19,
        "volume": 0,
        "date": "2025-11-21 10:00"
      }
    ]
  }'
```

### 4. Get All Sensors
```bash
curl -X GET "http://localhost:8000/sensors/" \
  -H "Authorization: Bearer YOUR_ACCESS_TOKEN"
```

### 5. Get Sensor by ID
```bash
curl -X GET "http://localhost:8000/sensors/1" \
  -H "Authorization: Bearer YOUR_ACCESS_TOKEN"
```

### 6. Get Sensor by External ID
```bash
curl -X GET "http://localhost:8000/sensors/external/68fdde281540e282dbebdefe" \
  -H "Authorization: Bearer YOUR_ACCESS_TOKEN"
```

### 7. Update Sensor
```bash
curl -X PUT "http://localhost:8000/sensors/1" \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer YOUR_ACCESS_TOKEN" \
  -d '{
    "battery": 95,
    "defective": false
  }'
```

### 8. Delete Sensor
```bash
curl -X DELETE "http://localhost:8000/sensors/1" \
  -H "Authorization: Bearer YOUR_ACCESS_TOKEN"
```

## Using Python Requests

### Install requests
```bash
pip install requests
```

### Example Script
```python
import requests
import json

BASE_URL = "http://localhost:8000"

# 1. Register
register_data = {
    "username": "testuser",
    "email": "test@example.com",
    "password": "testpassword123"
}
response = requests.post(f"{BASE_URL}/auth/register", json=register_data)
print("Register:", response.json())

# 2. Login
login_data = {
    "username": "testuser",
    "password": "testpassword123"
}
response = requests.post(
    f"{BASE_URL}/auth/token",
    data=login_data,
    headers={"Content-Type": "application/x-www-form-urlencoded"}
)
token = response.json()["access_token"]
print("Token:", token)

# 3. Create Sensor
headers = {"Authorization": f"Bearer {token}"}
sensor_data = {
    "external_id": "68fdde281540e282dbebdefe",
    "name": "Janubiy Surxon S.O",
    "location": "67.615645-37.8337474",
    "sendDataTime": "60",
    "sendInfoTime": "1440",
    "battery": 98,
    "date": "2022-02-24T11:59:29.000Z",
    "defective": False,
    "todayData": [
        {"level": 406.2, "volume": 0, "date": "2025-11-21 11:00"}
    ]
}
response = requests.post(f"{BASE_URL}/sensors/", json=sensor_data, headers=headers)
print("Create Sensor:", response.json())

# 4. Get All Sensors
response = requests.get(f"{BASE_URL}/sensors/", headers=headers)
print("All Sensors:", response.json())
```

## Field Mapping

Your JSON uses `_id` but in the request, use `external_id`:

| Your Field | API Field |
|-----------|-----------|
| `_id` | `external_id` |
| `sendDataTime` | `sendDataTime` |
| `sendInfoTime` | `sendInfoTime` |
| `todayData` | `todayData` |

## Interactive API Documentation

Visit these URLs when the server is running:
- Swagger UI: http://localhost:8000/docs
- ReDoc: http://localhost:8000/redoc

You can test all endpoints directly from the Swagger UI!
