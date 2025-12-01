#!/bin/bash

echo "Setting up Sensor API..."

# Generate secret key
SECRET_KEY=$(python3 -c "import secrets; print(secrets.token_hex(32))")

# Create .env file
cat > .env << EOF
DATABASE_URL=postgresql://postgres:postgres@localhost:5432/sensor_db
SECRET_KEY=$SECRET_KEY
ALGORITHM=HS256
ACCESS_TOKEN_EXPIRE_MINUTES=30
EOF

echo "✅ .env file created with generated SECRET_KEY"
echo ""
echo "⚠️  Please update DATABASE_URL in .env with your PostgreSQL credentials"
echo ""
echo "Next steps:"
echo "1. Edit .env and update DATABASE_URL"
echo "2. Create PostgreSQL database: CREATE DATABASE sensor_db;"
echo "3. Create virtual environment: python3 -m venv venv"
echo "4. Activate it: source venv/bin/activate"
echo "5. Install dependencies: pip install -r requirements.txt"
echo "6. Run the app: ./run.sh"
