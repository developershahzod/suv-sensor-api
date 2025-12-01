# Sensor API - FastAPI with JWT Authentication

A FastAPI project for managing sensor data with PostgreSQL database and JWT authentication.

## Features

- 🔐 JWT Authentication
- 🗄️ PostgreSQL Database
- 📊 Sensor Data Management
- 🔄 RESTful API
- 📝 Auto-generated API Documentation

## Tech Stack

- **FastAPI** - Modern, fast web framework
- **PostgreSQL** - Relational database
- **SQLAlchemy** - ORM
- **Pydantic** - Data validation
- **JWT** - Secure authentication
- **Uvicorn** - ASGI server
- **Docker** - Containerization

## Quick Start

### 🐳 Docker (Recommended)

The fastest way to get started:

```bash
# Start all services (PostgreSQL + API)
docker-compose up -d
```

API will be available at **http://localhost:8000**

For detailed Docker instructions, see [DOCKER.md](DOCKER.md)

### 📦 Manual Installation

If you prefer to run without Docker:

#### 1. Clone the repository

```bash
cd /Users/shahzodakhmedov/Documents/it_park_projects/suv-sensor-api
```

#### 2. Create virtual environment

```bash
python -m venv venv
source venv/bin/activate  # On Windows: venv\Scripts\activate
```

#### 3. Install dependencies

```bash
pip install -r requirements.txt
```

#### 4. Set up environment variables

Copy `.env.example` to `.env` and update the values:

```bash
cp .env.example .env
```

Edit `.env`:
```
DATABASE_URL=postgresql://username:password@localhost:5432/sensor_db
SECRET_KEY=your-super-secret-key-change-this-in-production
ALGORITHM=HS256
ACCESS_TOKEN_EXPIRE_MINUTES=30
```

#### 5. Set up PostgreSQL

Create a PostgreSQL database:

```bash
# Connect to PostgreSQL
psql -U postgres

# Create database
CREATE DATABASE sensor_db;

# Create user (optional)
CREATE USER sensor_user WITH PASSWORD 'your_password';
GRANT ALL PRIVILEGES ON DATABASE sensor_db TO sensor_user;
```

#### 6. Run the application

```bash
uvicorn app.main:app --reload
```

The API will be available at `http://localhost:8000`

## API Documentation

Once the server is running, visit:

- **Swagger UI**: http://localhost:8000/docs
- **ReDoc**: http://localhost:8000/redoc

## API Endpoints

### Authentication

#### Register User
```http
POST /auth/register
Content-Type: application/json

{
  "username": "testuser",
  "email": "test@example.com",
  "password": "securepassword"
}
```

#### Login
```http
POST /auth/token
Content-Type: application/x-www-form-urlencoded

username=testuser&password=securepassword
```

Response:
```json
{
  "access_token": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...",
  "token_type": "bearer"
}
```

#### Get Current User
```http
GET /auth/me
Authorization: Bearer {your_access_token}
```

### Sensors

All sensor endpoints require authentication. Include the JWT token in the Authorization header:
```
Authorization: Bearer {your_access_token}
```

#### Create Sensor
```http
POST /sensors/
Content-Type: application/json
Authorization: Bearer {your_access_token}

{
  "_id": "68fdde281540e282dbebdefe",
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
}
```

#### Get All Sensors
```http
GET /sensors/?skip=0&limit=100
Authorization: Bearer {your_access_token}
```

#### Get Sensor by ID
```http
GET /sensors/{sensor_id}
Authorization: Bearer {your_access_token}
```

#### Get Sensor by External ID
```http
GET /sensors/external/{external_id}
Authorization: Bearer {your_access_token}
```

#### Update Sensor
```http
PUT /sensors/{sensor_id}
Content-Type: application/json
Authorization: Bearer {your_access_token}

{
  "battery": 95,
  "defective": false,
  "todayData": [...]
}
```

#### Delete Sensor
```http
DELETE /sensors/{sensor_id}
Authorization: Bearer {your_access_token}
```

## Data Model

### Sensor
```json
{
  "id": 1,
  "external_id": "68fdde281540e282dbebdefe",
  "name": "Janubiy Surxon S.O",
  "location": "67.615645-37.8337474",
  "sendDataTime": "60",
  "sendInfoTime": "1440",
  "battery": 98,
  "date": "2022-02-24T11:59:29.000Z",
  "defective": false,
  "createdAt": "2025-10-26T08:39:04.413Z",
  "updatedAt": "2025-11-21T06:11:04.478Z",
  "todayData": [...]
}
```

### Sensor Data
```json
{
  "level": 406.2,
  "volume": 0,
  "date": "2025-11-21 11:00"
}
```

## Development

### Project Structure

```
suv-sensor-api/
├── app/
│   ├── __init__.py
│   ├── main.py              # FastAPI application
│   ├── config.py            # Configuration settings
│   ├── database.py          # Database connection
│   ├── models.py            # SQLAlchemy models
│   ├── schemas.py           # Pydantic schemas
│   ├── auth.py              # JWT authentication
│   └── routers/
│       ├── __init__.py
│       ├── auth_router.py   # Authentication endpoints
│       └── sensor_router.py # Sensor endpoints
├── requirements.txt
├── .env.example
├── .gitignore
└── README.md
```

### Running Tests

```bash
# Install test dependencies
pip install pytest pytest-asyncio httpx

# Run tests (create test files as needed)
pytest
```

## Security Notes

1. **Change SECRET_KEY**: Generate a secure secret key for production:
   ```bash
   openssl rand -hex 32
   ```

2. **CORS**: Update CORS settings in `app/main.py` to allow only specific origins in production

3. **HTTPS**: Always use HTTPS in production

4. **Environment Variables**: Never commit `.env` file to version control

## License

MIT
