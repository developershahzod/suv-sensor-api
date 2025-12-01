# Docker Setup Guide

## 🐳 Quick Start with Docker (Recommended)

The easiest way to run this project is with Docker. Everything is pre-configured!

### Prerequisites
- Docker installed ([Get Docker](https://docs.docker.com/get-docker/))
- Docker Compose installed (included with Docker Desktop)

### 🚀 Start Everything in 2 Commands

```bash
# 1. Generate a secure secret key (optional but recommended)
openssl rand -hex 32

# 2. Start all services (PostgreSQL + FastAPI)
docker-compose up -d
```

That's it! The API will be running at **http://localhost:8000**

### What Gets Started?

- **PostgreSQL Database** (port 5432)
  - User: `sensor_user`
  - Password: `sensor_password`
  - Database: `sensor_db`
  
- **FastAPI Application** (port 8000)
  - Auto-reload enabled for development
  - Connected to PostgreSQL
  - JWT authentication configured

## 📋 Docker Commands

### Start Services
```bash
# Start in background
docker-compose up -d

# Start with logs visible
docker-compose up

# Rebuild and start (after code changes to dependencies)
docker-compose up -d --build
```

### View Logs
```bash
# All services
docker-compose logs -f

# API only
docker-compose logs -f api

# Database only
docker-compose logs -f db
```

### Stop Services
```bash
# Stop containers (keeps data)
docker-compose stop

# Stop and remove containers (keeps volumes)
docker-compose down

# Stop and remove everything including data
docker-compose down -v
```

### Database Management
```bash
# Connect to PostgreSQL
docker-compose exec db psql -U sensor_user -d sensor_db

# Run SQL commands
docker-compose exec db psql -U sensor_user -d sensor_db -c "SELECT * FROM users;"

# Backup database
docker-compose exec db pg_dump -U sensor_user sensor_db > backup.sql

# Restore database
docker-compose exec -T db psql -U sensor_user -d sensor_db < backup.sql
```

### Application Management
```bash
# Restart API only
docker-compose restart api

# View API container logs
docker-compose logs -f api

# Execute command in API container
docker-compose exec api python -c "print('Hello from container')"

# Access API container shell
docker-compose exec api bash
```

## 🔧 Configuration

### Custom Secret Key

For production, generate and use a secure secret key:

```bash
# Generate key
openssl rand -hex 32

# Add to docker-compose.yml under api.environment
SECRET_KEY: your-generated-key-here
```

Or create a `.env` file in the project root:
```bash
SECRET_KEY=your-generated-key-here
```

Docker Compose will automatically load it.

### Custom Database Credentials

Edit `docker-compose.yml` and update both services:

```yaml
db:
  environment:
    POSTGRES_USER: your_user
    POSTGRES_PASSWORD: your_password
    POSTGRES_DB: your_db

api:
  environment:
    DATABASE_URL: postgresql://your_user:your_password@db:5432/your_db
```

### Port Changes

Change exposed ports in `docker-compose.yml`:

```yaml
api:
  ports:
    - "3000:8000"  # Access on port 3000 instead of 8000

db:
  ports:
    - "5433:5432"  # Avoid conflict if PostgreSQL already running
```

## 🧪 Testing the API

### 1. Check if services are running
```bash
docker-compose ps
```

### 2. Register a user
```bash
curl -X POST "http://localhost:8000/auth/register" \
  -H "Content-Type: application/json" \
  -d '{
    "username": "admin",
    "email": "admin@example.com",
    "password": "admin123"
  }'
```

### 3. Get access token
```bash
curl -X POST "http://localhost:8000/auth/token" \
  -H "Content-Type: application/x-www-form-urlencoded" \
  -d "username=admin&password=admin123"
```

### 4. Create a sensor
```bash
curl -X POST "http://localhost:8000/sensors/" \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer YOUR_TOKEN" \
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
      {"level": 406.2, "volume": 0, "date": "2025-11-21 11:00"}
    ]
  }'
```

## 🔍 Debugging

### View API Logs
```bash
docker-compose logs -f api
```

### Check Database Connection
```bash
docker-compose exec api python -c "from app.database import engine; print(engine.url)"
```

### Inspect Database
```bash
docker-compose exec db psql -U sensor_user -d sensor_db
```

Then run:
```sql
-- List all tables
\dt

-- View users
SELECT * FROM users;

-- View sensors
SELECT * FROM sensors;

-- View sensor data
SELECT * FROM sensor_data;
```

### Container Health Check
```bash
# Check if containers are healthy
docker-compose ps

# Check specific container
docker inspect sensor_api
docker inspect sensor_db
```

## 🛠️ Development Mode

The Docker setup includes hot-reload for development:

1. Make changes to code in `./app/` directory
2. API automatically reloads (watch logs with `docker-compose logs -f api`)
3. No need to restart containers

## 🚀 Production Deployment

For production, update `docker-compose.yml`:

```yaml
api:
  command: uvicorn app.main:app --host 0.0.0.0 --port 8000 --workers 4
  environment:
    SECRET_KEY: ${SECRET_KEY}  # Use environment variable
  # Remove the volumes mount to prevent auto-reload
```

And run:
```bash
docker-compose -f docker-compose.yml up -d --build
```

## 📊 Resource Management

### View Resource Usage
```bash
docker stats
```

### Limit Resources
Add to services in `docker-compose.yml`:
```yaml
api:
  deploy:
    resources:
      limits:
        cpus: '0.5'
        memory: 512M
      reservations:
        cpus: '0.25'
        memory: 256M
```

## 🧹 Cleanup

### Remove Unused Resources
```bash
# Remove stopped containers
docker-compose rm

# Remove unused images
docker image prune

# Remove everything (CAUTION: removes all data)
docker-compose down -v
docker system prune -a
```

## ❓ Troubleshooting

### Port Already in Use
```bash
# Change ports in docker-compose.yml or stop conflicting service
lsof -ti:8000 | xargs kill -9  # Kill process on port 8000
```

### Database Connection Failed
```bash
# Check if DB is healthy
docker-compose ps

# Restart DB
docker-compose restart db

# Check DB logs
docker-compose logs db
```

### API Won't Start
```bash
# Check logs
docker-compose logs api

# Rebuild
docker-compose up -d --build

# Force recreate
docker-compose up -d --force-recreate
```

## 📚 Additional Resources

- Interactive API docs: http://localhost:8000/docs
- Alternative docs: http://localhost:8000/redoc
- Health check: http://localhost:8000/health
