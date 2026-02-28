"""
Tests for cart API endpoints.
"""
import pytest
from httpx import AsyncClient
from sqlalchemy.ext.asyncio import AsyncSession
from decimal import Decimal

from db.models import Product, ProductCategory


class TestCartEndpoints:
    """Tests for /api/v1/market/cart endpoints."""
    
    @pytest.mark.asyncio
    async def test_get_empty_cart(self, client: AsyncClient, test_headers: dict):
        """Test getting empty cart."""
        response = await client.get("/api/v1/market/cart", headers=test_headers)
        
        assert response.status_code == 200
        data = response.json()
        assert data["items"] == []
        assert data["total_amount"] == "0"
    
    @pytest.mark.asyncio
    async def test_add_to_cart(
        self,
        client: AsyncClient,
        test_session: AsyncSession,
        test_headers: dict,
    ):
        """Test adding item to cart."""
        # Create test product
        product = Product(
            name="Test T-Shirt",
            brand="TestBrand",
            category=ProductCategory.TOP,
            price=Decimal("1000.00"),
            sizes=["S", "M", "L"],
            in_stock=True,
            stock_count=10,
        )
        test_session.add(product)
        await test_session.commit()
        
        response = await client.post(
            "/api/v1/market/cart/items",
            json={
                "product_id": str(product.id),
                "size": "M",
                "color": "black",
                "quantity": 2,
            },
            headers=test_headers,
        )
        
        assert response.status_code == 200
        data = response.json()
        assert len(data["items"]) == 1
        assert data["items"][0]["product_id"] == str(product.id)
        assert data["items"][0]["quantity"] == 2
        assert data["items"][0]["size"] == "M"
    
    @pytest.mark.asyncio
    async def test_add_to_cart_product_not_found(
        self,
        client: AsyncClient,
        test_headers: dict,
    ):
        """Test adding non-existent product to cart."""
        import uuid
        fake_id = str(uuid.uuid4())
        
        response = await client.post(
            "/api/v1/market/cart/items",
            json={
                "product_id": fake_id,
                "quantity": 1,
            },
            headers=test_headers,
        )
        
        assert response.status_code == 404
    
    @pytest.mark.asyncio
    async def test_update_cart_item(
        self,
        client: AsyncClient,
        test_session: AsyncSession,
        test_headers: dict,
    ):
        """Test updating cart item quantity."""
        # Create test product
        product = Product(
            name="Test T-Shirt",
            brand="TestBrand",
            category=ProductCategory.TOP,
            price=Decimal("1000.00"),
            in_stock=True,
        )
        test_session.add(product)
        await test_session.commit()
        
        # Add to cart
        await client.post(
            "/api/v1/market/cart/items",
            json={
                "product_id": str(product.id),
                "quantity": 1,
            },
            headers=test_headers,
        )
        
        # Update quantity
        response = await client.patch(
            f"/api/v1/market/cart/items/{product.id}",
            json={"quantity": 5},
            headers=test_headers,
        )
        
        assert response.status_code == 200
        data = response.json()
        assert len(data["items"]) == 1
        assert data["items"][0]["quantity"] == 5
    
    @pytest.mark.asyncio
    async def test_remove_from_cart(
        self,
        client: AsyncClient,
        test_session: AsyncSession,
        test_headers: dict,
    ):
        """Test removing item from cart."""
        # Create test product
        product = Product(
            name="Test T-Shirt",
            brand="TestBrand",
            category=ProductCategory.TOP,
            price=Decimal("1000.00"),
            in_stock=True,
        )
        test_session.add(product)
        await test_session.commit()
        
        # Add to cart
        await client.post(
            "/api/v1/market/cart/items",
            json={
                "product_id": str(product.id),
                "quantity": 1,
            },
            headers=test_headers,
        )
        
        # Remove from cart
        response = await client.delete(
            f"/api/v1/market/cart/items/{product.id}",
            headers=test_headers,
        )
        
        assert response.status_code == 200
        data = response.json()
        assert data["items"] == []
    
    @pytest.mark.asyncio
    async def test_clear_cart(
        self,
        client: AsyncClient,
        test_session: AsyncSession,
        test_headers: dict,
    ):
        """Test clearing entire cart."""
        # Create test products
        product1 = Product(
            name="Test T-Shirt",
            brand="TestBrand",
            category=ProductCategory.TOP,
            price=Decimal("1000.00"),
            in_stock=True,
        )
        product2 = Product(
            name="Test Jeans",
            brand="TestBrand",
            category=ProductCategory.BOTTOM,
            price=Decimal("2000.00"),
            in_stock=True,
        )
        test_session.add_all([product1, product2])
        await test_session.commit()
        
        # Add both to cart
        await client.post(
            "/api/v1/market/cart/items",
            json={"product_id": str(product1.id), "quantity": 1},
            headers=test_headers,
        )
        await client.post(
            "/api/v1/market/cart/items",
            json={"product_id": str(product2.id), "quantity": 1},
            headers=test_headers,
        )
        
        # Clear cart
        response = await client.delete("/api/v1/market/cart", headers=test_headers)
        
        assert response.status_code == 200
        data = response.json()
        assert data["message"] == "Cart cleared"
        
        # Verify cart is empty
        get_response = await client.get("/api/v1/market/cart", headers=test_headers)
        assert get_response.json()["items"] == []
