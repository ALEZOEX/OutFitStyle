"""
Script to generate Alembic migrations.
"""
import asyncio
from alembic import command
from alembic.config import Config
from pathlib import Path


def generate_migration(message: str = "Initial migration"):
    """Generate a new migration."""
    alembic_cfg = Config(Path(__file__).parent / "alembic.ini")
    command.revision(alembic_cfg, autogenerate=True, message=message)


if __name__ == "__main__":
    import sys
    message = sys.argv[1] if len(sys.argv) > 1 else "Initial migration"
    generate_migration(message)
    print(f"Migration generated: {message}")
