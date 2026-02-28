"""
Scraper API — FastAPI wrapper для WildSearch Crawler.
Парсинг товаров с WB/Ozon по ссылке.
"""
import logging
import os
import subprocess
import tempfile
import json
from pathlib import Path
from typing import Optional

from fastapi import FastAPI, HTTPException
from pydantic import BaseModel, Field

# Настройка логирования
logging.basicConfig(
    level=logging.INFO,
    format="%(asctime)s - %(name)s - %(levelname)s - %(message)s"
)
logger = logging.getLogger(__name__)

app = FastAPI(
    title="Scraper API",
    description="API для парсинга товаров с маркетплейсов (WB/Ozon)",
    version="1.0.0"
)


# ═══════════════════════════════════════════
# МОДЕЛИ ДАННЫХ
# ═══════════════════════════════════════════

class ParseRequest(BaseModel):
    """Запрос на парсинг товара."""
    url: str = Field(..., description="Ссылка на товар")
    marketplace: str = Field(default="auto", description="Маркетплейс: auto, wb, ozon")


class ParseResponse(BaseModel):
    """Ответ парсинга товара."""
    status: str = Field(..., description="Статус: success/error")
    product: Optional[dict] = Field(default=None, description="Данные товара")
    error: Optional[str] = Field(default=None, description="Ошибка если есть")


# ═══════════════════════════════════════════
# ВСПОМОГАТЕЛЬНЫЕ ФУНКЦИИ
# ═══════════════════════════════════════════

def detect_marketplace(url: str) -> str:
    """
    Определить маркетплейс по URL.
    
    Args:
        url: Ссылка на товар
        
    Returns:
        marketplace: wb, ozon
        
    Raises:
        ValueError: Если маркетплейс не поддерживается
    """
    url_lower = url.lower()
    
    if "wildberries" in url_lower or "wb.ru" in url_lower:
        return "wb"
    elif "ozon" in url_lower:
        return "ozon"
    else:
        raise ValueError(f"Неподдерживаемый маркетплейс для URL: {url}")


def run_scraper(marketplace: str, url: str) -> tuple[bool, str, str]:
    """
    Запустить Scrapy crawler для парсинга.
    
    Args:
        marketplace: wb или ozon
        url: Ссылка на товар
        
    Returns:
        (success, stdout, stderr)
    """
    # Создать временный файл для результата
    with tempfile.NamedTemporaryFile(
        mode='w',
        suffix='.json',
        delete=False,
        encoding='utf-8'
    ) as tmp_file:
        tmp_path = tmp_file.name
    
    try:
        # Путь к scraper-service (клонированный WildSearch Crawler)
        scraper_dir = Path(__file__).parent / "scraper-service"
        
        if not scraper_dir.exists():
            logger.error(f"Директория scraper-service не найдена: {scraper_dir}")
            return False, "", "scraper-service не найден. Клонирован ли WildSearch Crawler?"
        
        # Команда для запуска Scrapy
        cmd = [
            "scrapy", "crawl", marketplace,
            "-o", tmp_path,
            "-a", f"good_url={url}"
        ]
        
        logger.info(f"Запуск парсера: {' '.join(cmd)}")
        
        process = subprocess.run(
            cmd,
            capture_output=True,
            text=True,
            cwd=str(scraper_dir),
            timeout=60  # 60 секунд таймаут
        )
        
        if process.returncode != 0:
            logger.error(f"Ошибка парсера: {process.stderr}")
            return False, process.stdout, process.stderr
        
        return True, process.stdout, process.stderr
        
    except subprocess.TimeoutExpired:
        logger.error("Таймаут парсинга (60 сек)")
        return False, "", "Таймаут парсинга (60 сек)"
    except Exception as e:
        logger.error(f"Ошибка запуска парсера: {e}")
        return False, "", str(e)
    finally:
        # Удалить временный файл
        try:
            if os.path.exists(tmp_path):
                os.remove(tmp_path)
        except Exception as e:
            logger.warning(f"Не удалось удалить временный файл: {e}")


def read_scraper_result(marketplace: str) -> Optional[dict]:
    """
    Прочитать результат парсинга из временного файла.
    
    Args:
        marketplace: wb или ozon
        
    Returns:
        Данные товара или None
    """
    # Ищем последний созданный JSON файл в artifacts
    artifacts_dir = Path(__file__).parent / "artifacts"
    
    if not artifacts_dir.exists():
        return None
    
    # Найти все JSON файлы
    json_files = list(artifacts_dir.glob(f"{marketplace}_*.json"))
    
    if not json_files:
        return None
    
    # Взять самый свежий
    latest_file = max(json_files, key=lambda f: f.stat().st_mtime)
    
    try:
        with open(latest_file, 'r', encoding='utf-8') as f:
            data = json.load(f)
        
        # Удалить файл после чтения
        os.remove(latest_file)
        
        # Вернуть первый элемент (если массив)
        if isinstance(data, list) and len(data) > 0:
            return data[0]
        elif isinstance(data, dict):
            return data
        else:
            return None
            
    except Exception as e:
        logger.error(f"Ошибка чтения результата: {e}")
        return None


# ═══════════════════════════════════════════
# API ENDPOINTS
# ═══════════════════════════════════════════

@app.post("/api/v1/scraper/parse", response_model=ParseResponse)
async def parse_product(request: ParseRequest):
    """
    Распарсить товар по ссылке через WildSearch Crawler.
    
    Поддерживаемые маркетплейсы:
    - Wildberries (wb)
    - Ozon (ozon)
    
    Таймаут парсинга: 60 секунд
    """
    logger.info(f"Запрос парсинга: url={request.url}, marketplace={request.marketplace}")
    
    try:
        # Определить маркетплейс
        marketplace = request.marketplace
        if marketplace == "auto":
            marketplace = detect_marketplace(request.url)
            logger.info(f"Автоматически определен маркетплейс: {marketplace}")
        
        # Запустить парсер
        success, stdout, stderr = run_scraper(marketplace, request.url)
        
        if not success:
            logger.error(f"Ошибка парсинга: {stderr}")
            return ParseResponse(
                status="error",
                product=None,
                error=f"Ошибка парсинга: {stderr}"
            )
        
        # Прочитать результат
        product = read_scraper_result(marketplace)
        
        if not product:
            # Попытаться прочитать из stdout (если scrapy вывел JSON в консоль)
            try:
                # Ищем JSON в выводе
                for line in stdout.strip().split('\n'):
                    if line.startswith('{') or line.startswith('['):
                        data = json.loads(line)
                        if isinstance(data, list) and len(data) > 0:
                            product = data[0]
                            break
                        elif isinstance(data, dict):
                            product = data
                            break
            except:
                pass
        
        if not product:
            return ParseResponse(
                status="error",
                product=None,
                error="Не удалось получить данные товара"
            )
        
        logger.info(f"Успешный парсинг: {product.get('name', 'Unknown')}")
        
        return ParseResponse(
            status="success",
            product=product,
            error=None
        )
    
    except ValueError as e:
        logger.warning(f"Ошибка валидации: {e}")
        raise HTTPException(status_code=400, detail=str(e))
    except HTTPException:
        raise
    except Exception as e:
        logger.exception(f"Неожиданная ошибка: {e}")
        return ParseResponse(
            status="error",
            product=None,
            error=f"Внутренняя ошибка сервера: {str(e)}"
        )


@app.get("/health")
async def health():
    """Проверка здоровья сервиса."""
    return {"status": "ok", "service": "scraper-api"}


@app.get("/ready")
async def ready():
    """Проверка готовности сервиса."""
    # Проверить наличие scraper-service
    scraper_dir = Path(__file__).parent / "scraper-service"
    scraper_exists = scraper_dir.exists()
    
    return {
        "status": "ready" if scraper_exists else "not_ready",
        "service": "scraper-api",
        "scraper_service": scraper_exists
    }


if __name__ == "__main__":
    import uvicorn
    uvicorn.run(app, host="0.0.0.0", port=8000)
