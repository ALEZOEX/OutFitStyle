"""
Tests for products API endpoints.
"""
import pytest
from httpx import AsyncClient
from sqlalchemy.ext.asyncio import AsyncSession
from sqlalchemy import select

from db.models import Product, ProductCategory
from schemas.schemas import ProductCategory as ProductCategorySchema


class TestProductsEndpoints:
    """Tests for /api/v1/market/products endpoints."""
    
    @pytest.mark.asyncio
    async def test_get_products_empty(self, client: AsyncClient, test_headers: dict):
        """Test getting products when database is empty."""
        response = await client.get("/api/v1/market/products", headers=test_headers)
        
        assert response.status_code == 200
        data = response.json()
        assert data["items"] == []
        assert data["total"] == 0
        assert data["page"] == 1
        assert data["page_size"] == 20
    
    @pytest.mark.asyncio
    async def test_get_products_with_data(
        self,
        client: AsyncClient,
        test_session: AsyncSession,
        test_headers: dict,
    ):
        """Test getting products with data in database."""
        # Create test product
        product = Product(
            name="Test T-Shirt",
            brand="TestBrand",
            category=ProductCategory.TOP,
            price=1000.00,
            sizes=["S", "M", "L"],
            colors=["black", "white"],
            style_tags=["casual"],
            in_stock=True,
            stock_count=10,
        )
        test_session.add(product)
        await test_session.commit()
        
        response = await client.get("/api/v1/market/products", headers=test_headers)
        
        assert response.status_code == 200
        data = response.json()
        assert data["total"] == 1
        assert len(data["items"]) == 1
        assert data["items"][0]["name"] == "Test T-Shirt"
        assert data["items"][0]["brand"] == "TestBrand"
    
    @pytest.mark.asyncio
    async def test_get_products_filter_by_category(
        self,
        client: AsyncClient,
        test_session: AsyncSession,
        test_headers: dict,
    ):
        """Test filtering products by category."""
        # Create test products
        product_top = Product(
            name="Test T-Shirt",
            brand="TestBrand",
            category=ProductCategory.TOP,
            price=1000.00,
            in_stock=True,
        )
        product_bottom = Product(
            name="Test Jeans",
            brand="TestBrand",
            category=ProductCategory.BOTTOM,
            price=2000.00,
            in_stock=True,
        )
        test_session.add_all([product_top, product_bottom])
        await test_session.commit()
        
        response = await client.get(
            "/api/v1/market/products",
            params={"category": "top"},
            headers=test_headers,
        )
        
        assert response.status_code == 200
        data = response.json()
        assert data["total"] == 1
        assert data["items"][0]["category"] == "top"
    
    @pytest.mark.asyncio
    async def test_get_products_filter_by_price(
        self,
        client: AsyncClient,
        test_session: AsyncSession,
        test_headers: dict,
    ):
        """Test filtering products by price range."""
        # Create test products
        product1 = Product(
            name="Cheap T-Shirt",
            brand="TestBrand",
            category=ProductCategory.TOP,
            price=500.00,
            in_stock=True,
        )
        product2 = Product(
            name="Expensive T-Shirt",
            brand="TestBrand",
            category=ProductCategory.TOP,
            price=5000.00,
            in_stock=True,
        )
        test_session.add_all([product1, product2])
        await test_session.commit()
        
        response = await client.get(
            "/api/v1/market/products",
            params={"min_price": 1000, "max_price": 10000},
            headers=test_headers,
        )
        
        assert response.status_code == 200
        data = response.json()
        assert data["total"] == 1
        assert data["items"][0]["price"] == 5000.00
    
    @pytest.mark.asyncio
    async def test_get_product_by_id(
        self,
        client: AsyncClient,
        test_session: AsyncSession,
        test_headers: dict,
    ):
        """Test getting single product by ID."""
        product = Product(
            name="Test T-Shirt",
            description="Test description",
            brand="TestBrand",
            category=ProductCategory.TOP,
            price=1000.00,
            in_stock=True,
        )
        test_session.add(product)
        await test_session.commit()
        
        response = await client.get(
            f"/api/v1/market/products/{product.id}",
            headers=test_headers,
        )
        
        assert response.status_code == 200
        data = response.json()
        assert data["id"] == str(product.id)
        assert data["name"] == "Test T-Shirt"
    
    @pytest.mark.asyncio
    async def test_get_product_not_found(
        self,
        client: AsyncClient,
        test_headers: dict,
    ):
        """Test getting non-existent product."""
        import uuid
        fake_id = str(uuid.uuid4())
        
        response = await client.get(
            f"/api/v1/market/products/{fake_id}",
            headers=test_headers,
        )
        
        assert response.status_code == 404
    
    @pytest.mark.asyncio
    async def test_get_categories(self, client: AsyncClient, test_headers: dict):
        """Test getting product categories."""
        response = await client.get(
            "/api/v1/market/products/categories",
            headers=test_headers,
        )
        
        assert response.status_code == 200
        data = response.json()
        assert len(data) > 0
        
        category_values = [cat["value"] for cat in data]
        assert "top" in category_values
        assert "bottom" in category_values
        assert "shoes" in category_values
