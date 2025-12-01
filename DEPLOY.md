# 🚀 Деплой на сервер через Docker

Полная инструкция по деплою FastAPI приложения на продакшн сервер.

## 📋 Подготовка

### 1. Требования на сервере
- Ubuntu/Debian Linux
- Docker установлен
- Docker Compose установлен
- Открытые порты: 8000 (API), 5432 (опционально для внешнего доступа к БД)

### 2. Установка Docker на сервере (если не установлен)

```bash
# Обновить систему
sudo apt update && sudo apt upgrade -y

# Установить Docker
curl -fsSL https://get.docker.com -o get-docker.sh
sudo sh get-docker.sh

# Добавить пользователя в группу docker
sudo usermod -aG docker $USER

# Установить Docker Compose
sudo apt install docker-compose -y

# Проверить установку
docker --version
docker-compose --version
```

## 🐳 Метод 1: Через Docker Hub (Рекомендуется)

### Шаг 1: Сборка и пуш образа на Docker Hub

На локальной машине:

```bash
# 1. Войти в Docker Hub
docker login

# 2. Собрать образ (замените на ваш username)
docker build -t your-username/sensor-api:latest .

# 3. Запушить на Docker Hub
docker push your-username/sensor-api:latest
```

### Шаг 2: Настройка на сервере

```bash
# 1. Создать директорию для проекта
mkdir -p ~/sensor-api
cd ~/sensor-api

# 2. Скопировать файлы на сервер (с локальной машины)
# Либо через scp:
scp docker-compose.prod.yml your-server:/home/user/sensor-api/docker-compose.yml
scp .env.production your-server:/home/user/sensor-api/.env

# Либо создать файлы напрямую на сервере (см. ниже)
```

### Шаг 3: Создать .env файл на сервере

```bash
# На сервере
cd ~/sensor-api
nano .env
```

Содержимое `.env`:
```bash
# Database
POSTGRES_USER=sensor_user
POSTGRES_PASSWORD=secure_password_123
POSTGRES_DB=sensor_db
DB_PORT=5432

# API
API_PORT=8000
SECRET_KEY=your_generated_secret_key_here
ALGORITHM=HS256
ACCESS_TOKEN_EXPIRE_MINUTES=30

# Docker Image (ваш Docker Hub username)
DOCKER_IMAGE=your-username/sensor-api:latest
```

**Сгенерировать SECRET_KEY:**
```bash
openssl rand -hex 32
```

### Шаг 4: Запуск на сервере

```bash
# Скачать образ и запустить
docker-compose -f docker-compose.prod.yml up -d

# Проверить статус
docker-compose ps

# Посмотреть логи
docker-compose logs -f
```

## 🔄 Метод 2: Прямой деплой (без Docker Hub)

### Вариант A: Копирование всего проекта

```bash
# На локальной машине
cd /path/to/project
tar -czf sensor-api.tar.gz --exclude=venv --exclude=__pycache__ .

# Скопировать на сервер
scp sensor-api.tar.gz user@your-server:/home/user/

# На сервере
cd ~
tar -xzf sensor-api.tar.gz -C sensor-api/
cd sensor-api

# Запустить
docker-compose -f docker-compose.prod.yml up -d --build
```

### Вариант B: Git клонирование

```bash
# На сервере
git clone https://github.com/your-username/sensor-api.git
cd sensor-api

# Создать .env файл
cp .env.production .env
nano .env  # Отредактировать

# Запустить
docker-compose -f docker-compose.prod.yml up -d --build
```

## 📦 Файлы для деплоя

Минимальные файлы на сервере:

```
sensor-api/
├── docker-compose.yml (или docker-compose.prod.yml)
└── .env
```

Если билдите на сервере, нужны также:
```
sensor-api/
├── Dockerfile
├── docker-compose.prod.yml
├── .env
├── requirements.txt
└── app/
    ├── __init__.py
    ├── main.py
    ├── models.py
    ├── schemas.py
    ├── auth.py
    ├── config.py
    ├── database.py
    └── routers/
        ├── __init__.py
        ├── auth_router.py
        └── sensor_router.py
```

## 🔐 Безопасность

### 1. Настроить firewall

```bash
# Разрешить только нужные порты
sudo ufw allow 22/tcp    # SSH
sudo ufw allow 8000/tcp  # API
sudo ufw enable
```

### 2. Использовать Nginx как reverse proxy (Опционально)

```bash
# Установить Nginx
sudo apt install nginx -y

# Создать конфигурацию
sudo nano /etc/nginx/sites-available/sensor-api
```

Конфигурация Nginx:
```nginx
server {
    listen 80;
    server_name your-domain.com;

    location / {
        proxy_pass http://localhost:8000;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
    }
}
```

```bash
# Активировать конфигурацию
sudo ln -s /etc/nginx/sites-available/sensor-api /etc/nginx/sites-enabled/
sudo nginx -t
sudo systemctl reload nginx
```

### 3. Настроить SSL с Let's Encrypt

```bash
sudo apt install certbot python3-certbot-nginx -y
sudo certbot --nginx -d your-domain.com
```

## 🔄 Обновление приложения

### Метод 1: Через Docker Hub

```bash
# На локальной машине: собрать и запушить новую версию
docker build -t your-username/sensor-api:latest .
docker push your-username/sensor-api:latest

# На сервере: обновить и перезапустить
cd ~/sensor-api
docker-compose pull
docker-compose up -d
```

### Метод 2: Прямое обновление

```bash
# На сервере
cd ~/sensor-api
git pull  # если используете git
# или загрузите новые файлы через scp

docker-compose -f docker-compose.prod.yml up -d --build
```

## 📊 Мониторинг и управление

### Просмотр логов
```bash
# Все логи
docker-compose logs -f

# Только API
docker-compose logs -f api

# Только БД
docker-compose logs -f db

# Последние 100 строк
docker-compose logs --tail=100
```

### Управление контейнерами
```bash
# Остановить
docker-compose stop

# Запустить
docker-compose start

# Перезапустить
docker-compose restart

# Пересоздать контейнеры
docker-compose up -d --force-recreate

# Остановить и удалить (данные сохранятся)
docker-compose down

# Удалить всё включая данные БД (ОСТОРОЖНО!)
docker-compose down -v
```

### Проверка статуса
```bash
# Список контейнеров
docker-compose ps

# Использование ресурсов
docker stats

# Проверить здоровье API
curl http://localhost:8000/health
```

## 💾 Бэкап базы данных

### Создать бэкап
```bash
# Бэкап в файл
docker-compose exec db pg_dump -U sensor_user sensor_db > backup_$(date +%Y%m%d_%H%M%S).sql

# Или в контейнере
docker-compose exec db pg_dump -U sensor_user sensor_db > /tmp/backup.sql
```

### Восстановить из бэкапа
```bash
# Восстановить
docker-compose exec -T db psql -U sensor_user -d sensor_db < backup_20251128.sql
```

### Автоматический бэкап (cron)
```bash
# Создать скрипт бэкапа
nano ~/backup-db.sh
```

Содержимое:
```bash
#!/bin/bash
BACKUP_DIR="/home/user/backups"
DATE=$(date +%Y%m%d_%H%M%S)
mkdir -p $BACKUP_DIR
cd ~/sensor-api
docker-compose exec -T db pg_dump -U sensor_user sensor_db > $BACKUP_DIR/backup_$DATE.sql
# Удалить старые бэкапы (старше 7 дней)
find $BACKUP_DIR -name "backup_*.sql" -mtime +7 -delete
```

```bash
# Сделать исполняемым
chmod +x ~/backup-db.sh

# Добавить в cron (каждый день в 2 AM)
crontab -e
# Добавить строку:
0 2 * * * /home/user/backup-db.sh
```

## 🧪 Тестирование после деплоя

```bash
# 1. Проверить здоровье
curl http://your-server:8000/health

# 2. Зарегистрировать пользователя
curl -X POST "http://your-server:8000/auth/register" \
  -H "Content-Type: application/json" \
  -d '{
    "username": "admin",
    "email": "admin@example.com",
    "password": "securepassword"
  }'

# 3. Получить токен
curl -X POST "http://your-server:8000/auth/token" \
  -H "Content-Type: application/x-www-form-urlencoded" \
  -d "username=admin&password=securepassword"

# 4. Открыть документацию
http://your-server:8000/docs
```

## 🔧 Troubleshooting

### Контейнер не запускается
```bash
# Проверить логи
docker-compose logs api
docker-compose logs db

# Проверить порты
sudo netstat -tulpn | grep 8000
sudo netstat -tulpn | grep 5432
```

### База данных недоступна
```bash
# Проверить здоровье БД
docker-compose exec db pg_isready -U sensor_user

# Подключиться к БД
docker-compose exec db psql -U sensor_user -d sensor_db
```

### Ошибка подключения
```bash
# Проверить переменные окружения
docker-compose exec api env | grep DATABASE_URL

# Перезапустить сервисы
docker-compose restart
```

### Нехватка места
```bash
# Очистить неиспользуемые образы и контейнеры
docker system prune -a

# Проверить место
df -h
docker system df
```

## 📝 Чеклист деплоя

- [ ] Docker и Docker Compose установлены на сервере
- [ ] Созданы файлы docker-compose.prod.yml и .env
- [ ] Сгенерирован безопасный SECRET_KEY
- [ ] Изменены пароли БД
- [ ] Образ запушен на Docker Hub (если используете)
- [ ] Настроен firewall
- [ ] Контейнеры запущены: `docker-compose ps`
- [ ] API доступен: `curl http://localhost:8000/health`
- [ ] Настроен Nginx (опционально)
- [ ] Настроен SSL (опционально)
- [ ] Настроен автоматический бэкап
- [ ] Протестированы все эндпоинты

## 🚀 Быстрый деплой (TL;DR)

```bash
# 1. На локальной машине - пуш на Docker Hub
docker login
docker build -t your-username/sensor-api:latest .
docker push your-username/sensor-api:latest

# 2. На сервере
mkdir ~/sensor-api && cd ~/sensor-api

# 3. Создать docker-compose.yml (скопируйте содержимое docker-compose.prod.yml)

# 4. Создать .env с вашими настройками
nano .env

# 5. Запустить
docker-compose up -d

# 6. Проверить
curl http://localhost:8000/health
```

Готово! Ваш API работает на сервере! 🎉
