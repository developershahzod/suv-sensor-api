"""add temperature to sensor_data

Revision ID: 001
Revises: 
Create Date: 2025-11-28 17:30:00.000000

"""
from alembic import op
import sqlalchemy as sa


# revision identifiers, used by Alembic.
revision = '001'
down_revision = None
branch_labels = None
depends_on = None


def upgrade() -> None:
    # Add temperature column to sensor_data table
    op.add_column('sensor_data', sa.Column('temperature', sa.Integer(), nullable=True))


def downgrade() -> None:
    # Remove temperature column from sensor_data table
    op.drop_column('sensor_data', 'temperature')
