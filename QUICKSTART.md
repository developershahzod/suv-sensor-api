# Quick Start Guide

## 🚀 Get Started in 5 Minutes

### Step 1: Run Setup Script
```bash
./setup.sh
```
This will generate your `.env` file with a secure secret key.

### Step 2: Configure Database
Edit `.env` and update your PostgreSQL credentials:
```bash
DATABASE_URL=postgresql://YOUR_USER:YOUR_PASSWORD@localhost:5432/sensor_db
```

### Step 3: Create PostgreSQL Database
```bash
# Connect to PostgreSQL
psql -U postgres

# Create the database
CREATE DATABASE sensor_db;

# Exit
\q
```

### Step 4: Install Dependencies
```bash
# Create virtual environment
python3 -m venv venv

# Activate it
source venv/bin/activate

# Install packages
pip install -r requirements.txt
```

### Step 5: Run the Application
```bash
./run.sh
```

The API will be running at **http://localhost:8000**

### Step 6: Test the API

Open your browser and visit:
- **http://localhost:8000/docs** - Interactive API documentation
- **http://localhost:8000/** - API welcome message

## 📝 Quick Test

### 1. Register a User
```bash
curl -X POST "http://localhost:8000/auth/register" \
  -H "Content-Type: application/json" \
  -d '{
    "username": "admin",
    "email": "admin@example.com",
    "password": "admin123"
  }'
```

### 2. Get Access Token
```bash
curl -X POST "http://localhost:8000/auth/token" \
  -H "Content-Type: application/x-www-form-urlencoded" \
  -d "username=admin&password=admin123"
```

Copy the `access_token` from the response.

### 3. Create a Sensor
```bash
curl -X POST "http://localhost:8000/sensors/" \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer YOUR_TOKEN_HERE" \
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
      }
    ]
  }'
```

### 4. Get All Sensors
```bash
curl -X GET "http://localhost:8000/sensors/" \
  -H "Authorization: Bearer YOUR_TOKEN_HERE"
```

## 📚 Documentation

- See `README.md` for detailed documentation
- See `API_EXAMPLES.md` for more API examples
- Visit `/docs` endpoint for interactive API testing

## ❓ Troubleshooting

### Database Connection Error
Make sure PostgreSQL is running and the DATABASE_URL in `.env` is correct.

### Import Errors
Make sure you activated the virtual environment:
```bash
source venv/bin/activate
```

### Port Already in Use
Change the port in `run.sh` or kill the process using port 8000:
```bash
lsof -ti:8000 | xargs kill -9
```

## 🎉 You're All Set!

Your FastAPI sensor management system is ready to use with:
- ✅ JWT Authentication
- ✅ PostgreSQL Database
- ✅ RESTful API Endpoints
- ✅ Auto-generated Documentation
