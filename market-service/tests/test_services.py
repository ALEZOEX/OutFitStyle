"""
Tests for health endpoints and services.
"""
import pytest
from httpx import AsyncClient


class TestHealthEndpoints:
    """Tests for health check endpoints."""
    
    @pytest.mark.asyncio
    async def test_health_check(self, client: AsyncClient):
        """Test health check endpoint."""
        response = await client.get("/health")
        
        assert response.status_code == 200
        data = response.json()
        assert data["status"] == "healthy"
        assert data["service"] == "market-service"
        assert "version" in data
    
    @pytest.mark.asyncio
    async def test_root_endpoint(self, client: AsyncClient):
        """Test root endpoint."""
        response = await client.get("/")
        
        assert response.status_code == 200
        data = response.json()
        assert "service" in data
        assert "version" in data
        assert data["docs"] == "/docs"


class TestServices:
    """Tests for service integrations."""
    
    def test_ml_service_integration_initialization(self):
        """Test ML service integration initialization."""
        from services.ml_integration import MLIntegrationService
        
        service = MLIntegrationService()
        assert service.base_url is not None
        assert service.timeout > 0
    
    def test_payment_service_integration_initialization(self):
        """Test payment service integration initialization."""
        from services.payment_integration import PaymentIntegrationService
        
        service = PaymentIntegrationService()
        assert service.base_url is not None
    
    def test_redis_service_initialization(self):
        """Test Redis service initialization."""
        from services.redis_service import RedisService
        
        service = RedisService()
        assert service.redis_url is not None
        assert service.cache_ttl > 0
    
    def test_api_service_initialization(self):
        """Test API service integration initialization."""
        from services.api_integration import APIService
        
        service = APIService()
        assert service.base_url is not None
        assert service.timeout > 0


class TestSchemas:
    """Tests for Pydantic schemas."""
    
    def test_product_create_schema(self):
        """Test ProductCreate schema validation."""
        from schemas.schemas import ProductCreate, ProductCategory
        
        product = ProductCreate(
            name="Test Product",
            brand="TestBrand",
            category=ProductCategory.TOP,
            price=1000.00,
        )
        
        assert product.name == "Test Product"
        assert product.brand == "TestBrand"
        assert product.category == ProductCategory.TOP
        assert product.price == 1000.00
    
    def test_product_create_schema_validation(self):
        """Test ProductCreate schema validation errors."""
        from schemas.schemas import ProductCreate, ProductCategory
        from pydantic import ValidationError
        
        with pytest.raises(ValidationError):
            ProductCreate(
                name="",  # Empty name
                brand="TestBrand",
                category=ProductCategory.TOP,
                price=-100,  # Negative price
            )
    
    def test_cart_item_create_schema(self):
        """Test CartItemCreate schema validation."""
        from schemas.schemas import CartItemCreate
        
        item = CartItemCreate(
            product_id="123e4567-e89b-12d3-a456-426614174000",
            size="M",
            color="black",
            quantity=2,
        )
        
        assert item.product_id == "123e4567-e89b-12d3-a456-426614174000"
        assert item.quantity == 2
    
    def test_cart_item_create_schema_quantity_validation(self):
        """Test CartItemCreate quantity validation."""
        from schemas.schemas import CartItemCreate
        from pydantic import ValidationError
        
        with pytest.raises(ValidationError):
            CartItemCreate(
                product_id="123e4567-e89b-12d3-a456-426614174000",
                quantity=0,  # Invalid quantity
            )
        
        with pytest.raises(ValidationError):
            CartItemCreate(
                product_id="123e4567-e89b-12d3-a456-426614174000",
                quantity=101,  # Exceeds maximum
            )
