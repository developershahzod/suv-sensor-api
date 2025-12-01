#!/bin/bash

# Скрипт для первоначальной настройки сервера
# Запустить на сервере: bash server-setup.sh

set -e

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

echo -e "${GREEN}🚀 Настройка сервера для Sensor API${NC}"
echo ""

# 1. Установка Docker
if ! command -v docker &> /dev/null; then
    echo -e "${YELLOW}📦 Установка Docker...${NC}"
    curl -fsSL https://get.docker.com -o get-docker.sh
    sudo sh get-docker.sh
    sudo usermod -aG docker $USER
    rm get-docker.sh
    echo -e "${GREEN}✅ Docker установлен${NC}"
else
    echo -e "${GREEN}✅ Docker уже установлен${NC}"
fi

# 2. Установка Docker Compose
if ! command -v docker-compose &> /dev/null; then
    echo -e "${YELLOW}📦 Установка Docker Compose...${NC}"
    sudo apt update
    sudo apt install -y docker-compose
    echo -e "${GREEN}✅ Docker Compose установлен${NC}"
else
    echo -e "${GREEN}✅ Docker Compose уже установлен${NC}"
fi

# 3. Создание директории проекта
echo -e "${YELLOW}📁 Создание директории проекта...${NC}"
mkdir -p ~/sensor-api
cd ~/sensor-api

# 4. Получение Docker Hub username
read -p "Введите Docker Hub username: " DOCKER_USERNAME

# 5. Генерация SECRET_KEY
SECRET_KEY=$(openssl rand -hex 32)

# 6. Создание docker-compose.yml
echo -e "${YELLOW}📝 Создание docker-compose.yml...${NC}"
cat > docker-compose.yml << 'EOF'
services:
  db:
    image: postgres:15-alpine
    container_name: sensor_db_prod
    restart: always
    environment:
      POSTGRES_USER: ${POSTGRES_USER:-sensor_user}
      POSTGRES_PASSWORD: ${POSTGRES_PASSWORD}
      POSTGRES_DB: ${POSTGRES_DB:-sensor_db}
    ports:
      - "5432:5432"
    volumes:
      - postgres_data:/var/lib/postgresql/data
    healthcheck:
      test: ["CMD-SHELL", "pg_isready -U sensor_user -d sensor_db"]
      interval: 10s
      timeout: 5s
      retries: 5
    networks:
      - sensor_network

  api:
    image: ${DOCKER_IMAGE}
    container_name: sensor_api_prod
    restart: always
    ports:
      - "8000:8000"
    environment:
      DATABASE_URL: postgresql://${POSTGRES_USER:-sensor_user}:${POSTGRES_PASSWORD}@db:5432/${POSTGRES_DB:-sensor_db}
      SECRET_KEY: ${SECRET_KEY}
      ALGORITHM: HS256
      ACCESS_TOKEN_EXPIRE_MINUTES: 30
    depends_on:
      db:
        condition: service_healthy
    networks:
      - sensor_network
    command: uvicorn app.main:app --host 0.0.0.0 --port 8000 --workers 4

volumes:
  postgres_data:

networks:
  sensor_network:
    driver: bridge
EOF

# 7. Создание .env файла
echo -e "${YELLOW}📝 Создание .env файла...${NC}"
read -sp "Введите пароль для базы данных: " DB_PASSWORD
echo ""

cat > .env << EOF
# Database
POSTGRES_USER=sensor_user
POSTGRES_PASSWORD=$DB_PASSWORD
POSTGRES_DB=sensor_db

# API
SECRET_KEY=$SECRET_KEY
ALGORITHM=HS256
ACCESS_TOKEN_EXPIRE_MINUTES=30

# Docker Image
DOCKER_IMAGE=$DOCKER_USERNAME/sensor-api:latest
EOF

chmod 600 .env

echo -e "${GREEN}✅ Конфигурация создана${NC}"
echo ""

# 8. Настройка firewall (опционально)
read -p "Настроить firewall? (y/n): " setup_firewall
if [ "$setup_firewall" = "y" ]; then
    echo -e "${YELLOW}🔥 Настройка firewall...${NC}"
    sudo ufw allow 22/tcp
    sudo ufw allow 8000/tcp
    sudo ufw --force enable
    echo -e "${GREEN}✅ Firewall настроен${NC}"
fi

echo ""
echo -e "${GREEN}🎉 Сервер настроен!${NC}"
echo ""
echo -e "${YELLOW}📋 Следующие шаги:${NC}"
echo ""
echo "1. Выйдите и войдите снова (для применения Docker прав)"
echo "   exit"
echo ""
echo "2. Вернитесь в директорию и запустите приложение:"
echo "   cd ~/sensor-api"
echo "   docker-compose pull"
echo "   docker-compose up -d"
echo ""
echo "3. Проверьте статус:"
echo "   docker-compose ps"
echo "   curl http://localhost:8000/health"
echo ""
echo -e "${YELLOW}💡 Ваши данные:${NC}"
echo "   SECRET_KEY: $SECRET_KEY"
echo "   Пароль БД: $DB_PASSWORD"
echo "   Docker образ: $DOCKER_USERNAME/sensor-api:latest"
echo ""
echo -e "${RED}⚠️  СОХРАНИТЕ ЭТИ ДАННЫЕ!${NC}"
