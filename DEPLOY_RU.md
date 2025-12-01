# 🚀 Деплой на сервер - Быстрая инструкция

## 📦 Способ 1: Автоматический (Рекомендуется)

### На локальной машине (вашем компьютере):

```bash
# 1. Запустить скрипт деплоя
./deploy.sh

# Скрипт спросит ваш Docker Hub username и автоматически:
# - Соберёт Docker образ
# - Загрузит на Docker Hub
# - Покажет инструкции для сервера
```

### На сервере:

```bash
# 1. Скачать и запустить скрипт настройки
curl -O https://raw.githubusercontent.com/your-repo/sensor-api/main/server-setup.sh
bash server-setup.sh

# Скрипт автоматически:
# - Установит Docker и Docker Compose
# - Создаст конфигурацию
# - Сгенерирует пароли
# - Настроит firewall

# 2. После этого выйти и войти снова
exit

# 3. Запустить приложение
cd ~/sensor-api
docker-compose pull
docker-compose up -d

# 4. Проверить
curl http://localhost:8000/health
```

## 🔧 Способ 2: Ручной

### Шаг 1: На локальной машине

```bash
# Войти в Docker Hub
docker login

# Собрать образ (замените YOUR_USERNAME)
docker build -t YOUR_USERNAME/sensor-api:latest .

# Загрузить на Docker Hub
docker push YOUR_USERNAME/sensor-api:latest
```

### Шаг 2: На сервере - Установка Docker

```bash
# Установить Docker
curl -fsSL https://get.docker.com -o get-docker.sh
sudo sh get-docker.sh
sudo usermod -aG docker $USER

# Установить Docker Compose
sudo apt update
sudo apt install docker-compose -y

# Выйти и войти снова для применения изменений
exit
```

### Шаг 3: Создать конфигурацию

```bash
# Создать директорию
mkdir -p ~/sensor-api
cd ~/sensor-api

# Создать docker-compose.yml
nano docker-compose.yml
```

Вставить содержимое:
```yaml
services:
  db:
    image: postgres:15-alpine
    container_name: sensor_db
    restart: always
    environment:
      POSTGRES_USER: sensor_user
      POSTGRES_PASSWORD: ${POSTGRES_PASSWORD}
      POSTGRES_DB: sensor_db
    volumes:
      - postgres_data:/var/lib/postgresql/data
    healthcheck:
      test: ["CMD-SHELL", "pg_isready -U sensor_user -d sensor_db"]
      interval: 10s
      timeout: 5s
      retries: 5

  api:
    image: ${DOCKER_IMAGE}
    container_name: sensor_api
    restart: always
    ports:
      - "8000:8000"
    environment:
      DATABASE_URL: postgresql://sensor_user:${POSTGRES_PASSWORD}@db:5432/sensor_db
      SECRET_KEY: ${SECRET_KEY}
      ALGORITHM: HS256
      ACCESS_TOKEN_EXPIRE_MINUTES: 30
    depends_on:
      db:
        condition: service_healthy
    command: uvicorn app.main:app --host 0.0.0.0 --port 8000 --workers 4

volumes:
  postgres_data:
```

### Шаг 4: Создать .env файл

```bash
# Создать .env
nano .env
```

Содержимое (замените на свои значения):
```bash
# Сгенерировать SECRET_KEY: openssl rand -hex 32
SECRET_KEY=ваш_сгенерированный_ключ_здесь

# Пароль БД
POSTGRES_PASSWORD=ваш_безопасный_пароль

# Docker образ (ваш username)
DOCKER_IMAGE=YOUR_USERNAME/sensor-api:latest
```

### Шаг 5: Запустить

```bash
# Скачать образ и запустить
docker-compose up -d

# Проверить статус
docker-compose ps

# Посмотреть логи
docker-compose logs -f api
```

## ✅ Проверка работы

```bash
# 1. Проверить здоровье API
curl http://localhost:8000/health
# Должно вернуть: {"status":"healthy"}

# 2. Открыть документацию
http://ВАШ_IP:8000/docs

# 3. Проверить что контейнеры работают
docker-compose ps
```

## 📊 Полезные команды

```bash
# Посмотреть логи
docker-compose logs -f        # Все логи
docker-compose logs -f api    # Только API
docker-compose logs -f db     # Только БД

# Перезапустить
docker-compose restart

# Остановить
docker-compose stop

# Запустить заново
docker-compose start

# Обновить до новой версии
docker-compose pull
docker-compose up -d

# Полная остановка и удаление (данные сохранятся!)
docker-compose down

# Удалить всё включая данные БД (ОСТОРОЖНО!)
docker-compose down -v
```

## 🔄 Обновление приложения

### На локальной машине:
```bash
# 1. Собрать новую версию
docker build -t YOUR_USERNAME/sensor-api:latest .

# 2. Загрузить на Docker Hub
docker push YOUR_USERNAME/sensor-api:latest
```

### На сервере:
```bash
# 1. Скачать новую версию
cd ~/sensor-api
docker-compose pull

# 2. Перезапустить
docker-compose up -d

# 3. Проверить логи
docker-compose logs -f api
```

## 🔐 Настройка Nginx + SSL (Опционально)

Если хотите использовать доменное имя и HTTPS:

```bash
# Установить Nginx
sudo apt install nginx -y

# Создать конфигурацию
sudo nano /etc/nginx/sites-available/sensor-api
```

Содержимое:
```nginx
server {
    listen 80;
    server_name your-domain.com;

    location / {
        proxy_pass http://localhost:8000;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
    }
}
```

```bash
# Активировать
sudo ln -s /etc/nginx/sites-available/sensor-api /etc/nginx/sites-enabled/
sudo nginx -t
sudo systemctl reload nginx

# Установить SSL (Let's Encrypt)
sudo apt install certbot python3-certbot-nginx -y
sudo certbot --nginx -d your-domain.com
```

## 🆘 Проблемы и решения

### Порт 8000 занят
```bash
sudo netstat -tulpn | grep 8000
# Остановить процесс или изменить порт в docker-compose.yml
```

### Контейнер не запускается
```bash
# Посмотреть логи
docker-compose logs api

# Перезапустить
docker-compose restart

# Пересоздать контейнеры
docker-compose up -d --force-recreate
```

### База данных недоступна
```bash
# Проверить статус БД
docker-compose exec db pg_isready -U sensor_user

# Перезапустить БД
docker-compose restart db
```

### Забыли пароль БД
```bash
# Посмотреть .env файл
cat .env

# Или изменить пароль в .env и пересоздать БД:
docker-compose down -v
docker-compose up -d
```

## 📝 Чеклист

- [ ] Docker установлен на сервере
- [ ] Docker Compose установлен
- [ ] Образ загружен на Docker Hub
- [ ] Создан docker-compose.yml
- [ ] Создан .env с безопасными паролями
- [ ] Запущены контейнеры: `docker-compose ps`
- [ ] API работает: `curl http://localhost:8000/health`
- [ ] Открыт порт 8000 в firewall
- [ ] (Опционально) Настроен Nginx
- [ ] (Опционально) Настроен SSL

## 🎯 Самый быстрый способ (TL;DR)

**На локальной машине:**
```bash
./deploy.sh
```

**На сервере:**
```bash
curl -O https://raw.githubusercontent.com/your-repo/sensor-api/main/server-setup.sh
bash server-setup.sh
# Выйти и войти снова
cd ~/sensor-api
docker-compose up -d
```

**Готово!** Проверьте: `curl http://localhost:8000/health`

## 📞 Поддержка

Полная документация: [DEPLOY.md](DEPLOY.md)

Документация API: `http://ВАШ_IP:8000/docs`
