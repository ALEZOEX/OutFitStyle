"""Initial migration - create products, orders, cart tables

Revision ID: 001_initial
Revises: 
Create Date: 2026-02-28

"""
from typing import Sequence, Union

from alembic import op
import sqlalchemy as sa
from sqlalchemy.dialects import postgresql

# revision identifiers, used by Alembic.
revision: str = '001_initial'
down_revision: Union[str, None] = None
branch_labels: Union[str, Sequence[str], None] = None
depends_on: Union[str, Sequence[str], None] = None


def upgrade() -> None:
    # Create enum types
    product_category = postgresql.ENUM(
        'top', 'bottom', 'shoes', 'accessories', 'outerwear', 'headwear',
        name='productcategory',
        create_type=True
    )
    product_category.create(op.get_bind())
    
    order_status = postgresql.ENUM(
        'pending', 'paid', 'shipped', 'delivered', 'cancelled',
        name='orderstatus',
        create_type=True
    )
    order_status.create(op.get_bind())
    
    # Create products table
    op.create_table(
        'products',
        sa.Column('id', postgresql.UUID(as_uuid=True), nullable=False),
        sa.Column('name', sa.String(length=255), nullable=False),
        sa.Column('description', sa.Text(), nullable=True),
        sa.Column('brand', sa.String(length=100), nullable=False),
        sa.Column('category', product_category, nullable=False),
        sa.Column('subcategory', sa.String(length=100), nullable=True),
        sa.Column('price', sa.Numeric(precision=10, scale=2), nullable=False),
        sa.Column('currency', sa.String(length=3), nullable=True),
        sa.Column('image_urls', postgresql.ARRAY(sa.String()), nullable=True),
        sa.Column('sizes', postgresql.ARRAY(sa.String()), nullable=True),
        sa.Column('colors', postgresql.ARRAY(sa.String()), nullable=True),
        sa.Column('style_tags', postgresql.ARRAY(sa.String()), nullable=True),
        sa.Column('in_stock', sa.Boolean(), nullable=True),
        sa.Column('stock_count', sa.Integer(), nullable=True),
        sa.Column('created_at', sa.DateTime(), nullable=False),
        sa.Column('updated_at', sa.DateTime(), nullable=False),
        sa.PrimaryKeyConstraint('id')
    )
    
    # Create indexes for products
    op.create_index('ix_products_category', 'products', ['category'])
    op.create_index('ix_products_brand', 'products', ['brand'])
    op.create_index('ix_products_price', 'products', ['price'])
    op.create_index('ix_products_in_stock', 'products', ['in_stock'])
    op.create_index(
        'ix_products_style_tags',
        'products',
        ['style_tags'],
        postgresql_using='gin'
    )
    
    # Create orders table
    op.create_table(
        'orders',
        sa.Column('id', postgresql.UUID(as_uuid=True), nullable=False),
        sa.Column('user_id', sa.Integer(), nullable=False),
        sa.Column('status', order_status, nullable=False),
        sa.Column('total_amount', sa.Numeric(precision=10, scale=2), nullable=False),
        sa.Column('items', postgresql.JSONB(astext_type=sa.Text()), nullable=False),
        sa.Column('shipping_address', postgresql.JSONB(astext_type=sa.Text()), nullable=True),
        sa.Column('payment_method', sa.String(length=50), nullable=True),
        sa.Column('created_at', sa.DateTime(), nullable=False),
        sa.Column('updated_at', sa.DateTime(), nullable=False),
        sa.PrimaryKeyConstraint('id')
    )
    
    # Create indexes for orders
    op.create_index('ix_orders_user_id', 'orders', ['user_id'])
    op.create_index('ix_orders_status', 'orders', ['status'])
    op.create_index('ix_orders_created_at', 'orders', ['created_at'])
    
    # Create cart table
    op.create_table(
        'cart',
        sa.Column('id', postgresql.UUID(as_uuid=True), nullable=False),
        sa.Column('user_id', sa.Integer(), nullable=False),
        sa.Column('items', postgresql.JSONB(astext_type=sa.Text()), nullable=False),
        sa.Column('updated_at', sa.DateTime(), nullable=False),
        sa.PrimaryKeyConstraint('id'),
        sa.UniqueConstraint('user_id')
    )
    
    # Create index for cart
    op.create_index('ix_cart_user_id', 'cart', ['user_id'])


def downgrade() -> None:
    # Drop tables
    op.drop_table('cart')
    op.drop_table('orders')
    op.drop_table('products')
    
    # Drop enum types
    op.execute('DROP TYPE IF EXISTS orderstatus')
    op.execute('DROP TYPE IF EXISTS productcategory')
