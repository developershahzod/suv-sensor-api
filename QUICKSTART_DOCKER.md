# Docker Quick Start - 2 Commands! 🐳

Get the entire sensor API running in **2 commands** with Docker.

## Prerequisites

- [Docker Desktop](https://www.docker.com/products/docker-desktop/) installed
- That's it! No PostgreSQL installation needed.

## 🚀 Start in 2 Commands

### 1. Start Everything
```bash
docker-compose up -d
```

This starts:
- ✅ PostgreSQL database (port 5432)
- ✅ FastAPI application (port 8000)
- ✅ Automatic database initialization

### 2. Check Status
```bash
docker-compose ps
```

You should see both containers running:
```
NAME            STATUS      PORTS
sensor_db       Up          0.0.0.0:5432->5432/tcp
sensor_api      Up          0.0.0.0:8000->8000/tcp
```

## 🎉 That's It!

Your API is now running at:
- **API**: http://localhost:8000
- **Docs**: http://localhost:8000/docs (Swagger UI)
- **Alt Docs**: http://localhost:8000/redoc

## 📝 First API Call

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

### 2. Login
```bash
curl -X POST "http://localhost:8000/auth/token" \
  -H "Content-Type: application/x-www-form-urlencoded" \
  -d "username=admin&password=admin123"
```

**Copy the `access_token` from response!**

### 3. Create a Sensor
```bash
curl -X POST "http://localhost:8000/sensors/" \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer YOUR_ACCESS_TOKEN_HERE" \
  -d '{
    "external_id": "sensor001",
    "name": "Test Sensor",
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
  -H "Authorization: Bearer YOUR_ACCESS_TOKEN_HERE"
```

## 🛠️ Common Commands

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
docker-compose stop
```

### Start Again
```bash
docker-compose start
```

### Restart
```bash
docker-compose restart
```

### Stop and Remove (keeps data)
```bash
docker-compose down
```

### Remove Everything (including data)
```bash
docker-compose down -v
```

## 🔧 Configuration

### Change Ports

Edit `docker-compose.yml`:
```yaml
api:
  ports:
    - "3000:8000"  # Use port 3000 instead
```

### Use Secure Secret Key

Generate one:
```bash
openssl rand -hex 32
```

Add to `docker-compose.yml` under `api.environment`:
```yaml
SECRET_KEY: your-generated-key-here
```

Or create `.env` file:
```bash
SECRET_KEY=your-generated-key-here
```

## 💾 Database Access

### Connect to PostgreSQL
```bash
docker-compose exec db psql -U sensor_user -d sensor_db
```

### View Tables
```sql
\dt
```

### Query Data
```sql
SELECT * FROM sensors;
SELECT * FROM sensor_data;
SELECT * FROM users;
```

### Exit
```sql
\q
```

## 🐛 Troubleshooting

### Port Already in Use
```bash
# Check what's using port 8000
lsof -ti:8000

# Kill it
lsof -ti:8000 | xargs kill -9

# Or change port in docker-compose.yml
```

### Container Won't Start
```bash
# View logs
docker-compose logs api

# Rebuild
docker-compose up -d --build
```

### Database Issues
```bash
# Restart database
docker-compose restart db

# Check health
docker-compose exec db pg_isready -U sensor_user
```

### Fresh Start
```bash
# Remove everything and start over
docker-compose down -v
docker-compose up -d
```

## 📚 More Information

- Full documentation: [README.md](README.md)
- Detailed Docker guide: [DOCKER.md](DOCKER.md)
- API examples: [API_EXAMPLES.md](API_EXAMPLES.md)

## 🎯 Next Steps

1. ✅ Explore API at http://localhost:8000/docs
2. ✅ Create users and sensors
3. ✅ Integrate with your frontend/application
4. ✅ Read [DOCKER.md](DOCKER.md) for advanced usage

Happy coding! 🚀
