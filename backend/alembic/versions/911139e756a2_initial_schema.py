"""initial_schema

Revision ID: 911139e756a2
Revises: 
Create Date: 2026-11-04 11:22:25.492428

"""
from typing import Sequence, Union
from alembic import op
import sqlalchemy as sa
from sqlalchemy import inspect

# revision identifiers, used by Alembic.
revision: str = '911139e756a2'
down_revision: Union[str, Sequence[str], None] = None
branch_labels: Union[str, Sequence[str], None] = None
depends_on: Union[str, Sequence[str], None] = None


def upgrade() -> None:
    conn = op.get_bind()
    inspector = inspect(conn)
    existing_tables = inspector.get_table_names()

    # 1. sensor_readings
    if "sensor_readings" not in existing_tables:
        op.create_table(
            "sensor_readings",
            sa.Column("id", sa.Integer(), autoincrement=True, nullable=False),
            sa.Column("soil_moisture", sa.Float(), nullable=False),
            sa.Column("temperature", sa.Float(), nullable=False),
            sa.Column("humidity", sa.Float(), nullable=False),
            sa.Column("light_intensity", sa.Float(), nullable=False),
            sa.Column("source", sa.String(length=50), nullable=False, server_default="esp32"),
            sa.Column("timestamp", sa.DateTime(timezone=True), server_default=sa.func.now(), nullable=False),
            sa.PrimaryKeyConstraint("id"),
        )
        op.create_index(op.f("ix_sensor_readings_id"), "sensor_readings", ["id"], unique=False)
        op.create_index(op.f("ix_sensor_readings_timestamp"), "sensor_readings", ["timestamp"], unique=False)

    # 2. disease_predictions
    if "disease_predictions" not in existing_tables:
        op.create_table(
            "disease_predictions",
            sa.Column("id", sa.Integer(), autoincrement=True, nullable=False),
            sa.Column("crop", sa.String(length=50), nullable=False, server_default="tomato"),
            sa.Column("predicted_disease", sa.String(length=100), nullable=False),
            sa.Column("confidence", sa.Float(), nullable=False),
            sa.Column("class_probabilities", sa.JSON(), nullable=False),
            sa.Column("image_filename", sa.String(length=255), nullable=True),
            sa.Column("timestamp", sa.DateTime(timezone=True), server_default=sa.func.now(), nullable=False),
            sa.PrimaryKeyConstraint("id"),
        )
        op.create_index(op.f("ix_disease_predictions_id"), "disease_predictions", ["id"], unique=False)
        op.create_index(op.f("ix_disease_predictions_timestamp"), "disease_predictions", ["timestamp"], unique=False)

    # 3. irrigation_logs
    if "irrigation_logs" not in existing_tables:
        op.create_table(
            "irrigation_logs",
            sa.Column("id", sa.Integer(), autoincrement=True, nullable=False),
            sa.Column("crop", sa.String(length=50), nullable=False),
            sa.Column("growth_stage", sa.String(length=50), nullable=False),
            sa.Column("soil_moisture", sa.Float(), nullable=False),
            sa.Column("water_required_mm", sa.Float(), nullable=False),
            sa.Column("water_required_liters_per_m2", sa.Float(), nullable=False),
            sa.Column("pump_duration_seconds", sa.Float(), nullable=False),
            sa.Column("calculation_method", sa.String(length=100), nullable=False),
            sa.Column("timestamp", sa.DateTime(timezone=True), server_default=sa.func.now(), nullable=False),
            sa.PrimaryKeyConstraint("id"),
        )
        op.create_index(op.f("ix_irrigation_logs_id"), "irrigation_logs", ["id"], unique=False)
        op.create_index(op.f("ix_irrigation_logs_timestamp"), "irrigation_logs", ["timestamp"], unique=False)

    # 4. crop_configs
    if "crop_configs" not in existing_tables:
        op.create_table(
            "crop_configs",
            sa.Column("id", sa.Integer(), autoincrement=True, nullable=False),
            sa.Column("crop_name", sa.String(length=50), nullable=False),
            sa.Column("growth_stage", sa.String(length=50), nullable=False),
            sa.Column("kc_value", sa.Float(), nullable=False),
            sa.Column("root_depth_m", sa.Float(), nullable=False),
            sa.Column("soil_depletion_fraction", sa.Float(), nullable=False),
            sa.Column("created_at", sa.DateTime(timezone=True), server_default=sa.func.now(), nullable=False),
            sa.PrimaryKeyConstraint("id"),
        )
        op.create_index(op.f("ix_crop_configs_id"), "crop_configs", ["id"], unique=False)
        op.create_index(op.f("ix_crop_configs_crop_name"), "crop_configs", ["crop_name"], unique=False)


def downgrade() -> None:
    op.drop_table("crop_configs")
    op.drop_table("irrigation_logs")
    op.drop_table("disease_predictions")
    op.drop_table("sensor_readings")
