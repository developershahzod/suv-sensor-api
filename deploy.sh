#!/bin/bash

# Скрипт для деплоя на Docker Hub
# Использование: ./deploy.sh [version]

set -e

# Цвета для вывода
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

echo -e "${GREEN}🚀 Деплой Sensor API${NC}"
echo ""

# Проверка Docker
if ! command -v docker &> /dev/null; then
    echo -e "${RED}❌ Docker не установлен${NC}"
    exit 1
fi

# Получить Docker Hub username
read -p "Введите ваш Docker Hub username: " DOCKER_USERNAME

if [ -z "$DOCKER_USERNAME" ]; then
    echo -e "${RED}❌ Username не может быть пустым${NC}"
    exit 1
fi

# Версия (по умолчанию latest)
VERSION=${1:-latest}
IMAGE_NAME="$DOCKER_USERNAME/sensor-api:$VERSION"

echo -e "${YELLOW}📦 Образ: $IMAGE_NAME${NC}"
echo ""

# 1. Логин в Docker Hub
echo -e "${YELLOW}🔐 Логин в Docker Hub...${NC}"
docker login

# 2. Сборка образа
echo -e "${YELLOW}🔨 Сборка образа...${NC}"
docker build -t $IMAGE_NAME .

# 3. Также тегнуть как latest если это не latest
if [ "$VERSION" != "latest" ]; then
    echo -e "${YELLOW}🏷️  Добавление тега latest...${NC}"
    docker tag $IMAGE_NAME $DOCKER_USERNAME/sensor-api:latest
fi

# 4. Пуш на Docker Hub
echo -e "${YELLOW}⬆️  Загрузка на Docker Hub...${NC}"
docker push $IMAGE_NAME

if [ "$VERSION" != "latest" ]; then
    docker push $DOCKER_USERNAME/sensor-api:latest
fi

echo ""
echo -e "${GREEN}✅ Успешно задеплоено!${NC}"
echo ""
echo -e "${YELLOW}📋 Следующие шаги на сервере:${NC}"
echo ""
echo "1. Создайте директорию:"
echo "   mkdir -p ~/sensor-api && cd ~/sensor-api"
echo ""
echo "2. Создайте docker-compose.yml (используйте docker-compose.prod.yml)"
echo ""
echo "3. Создайте .env файл с настройками:"
echo "   DOCKER_IMAGE=$IMAGE_NAME"
echo "   SECRET_KEY=\$(openssl rand -hex 32)"
echo "   POSTGRES_PASSWORD=your_secure_password"
echo ""
echo "4. Запустите:"
echo "   docker-compose up -d"
echo ""
echo -e "${GREEN}🎉 Готово!${NC}"
