# Scraper API Dockerfile
# FastAPI wrapper для WildSearch Crawler (WB/Ozon парсинг)

FROM python:3.11-slim

WORKDIR /app

# Установить системные зависимости для Scrapy + Chrome/Selenium
RUN apt-get update && apt-get install -y \
    # Chromium для headless браузера
    chromium \
    chromium-driver \
    chromium-l10n \
    # Шрифты для рендеринга
    fonts-liberation \
    fonts-noto-color-emoji \
    fonts-ipafont-gothic \
    fonts-wqy-zenhei \
    # Утилиты
    xdg-utils \
    wget \
    git \
    && rm -rf /var/lib/apt/lists/* \
    && apt-get clean

# Переменные окружения для Chromium
ENV CHROME_BIN=/usr/bin/chromium \
    CHROME_PATH=/usr/lib/chromium/ \
    CHROMEDRIVER_BIN=/usr/bin/chromedriver

# Установить Python зависимости для FastAPI wrapper
COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

# Клонировать WildSearch Crawler (Wildberries-API)
RUN git clone --depth 1 https://github.com/MichaelZav/Wildberries-API.git scraper-service

# Установить зависимости Scrapy из клонированного репозитория
WORKDIR /app/scraper-service
RUN if [ -f requirements.txt ]; then \
        pip install --no-cache-dir -r requirements.txt; \
    fi

# Вернуться в рабочую директорию
WORKDIR /app

# Создать директорию для артефактов (временных файлов парсинга)
RUN mkdir -p artifacts

# Скопировать основной код
COPY main.py .

# Создать .gitkeep для artifacts
RUN touch artifacts/.gitkeep

EXPOSE 8000

# Запуск приложения
CMD ["uvicorn", "main:app", "--host", "0.0.0.0", "--port", "8000"]
