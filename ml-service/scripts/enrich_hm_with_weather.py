#!/usr/bin/env python3
"""
Обогащение H&M dataset погодными данными через Open-Meteo Historical API

H&M dataset:
- transactions_train.csv: t_dat, customer_id, article_id, price, sales_channel_id
- articles.csv: article_id, product_code, product_type, product_group_name, 
  graphical_appearance_name, colour_group_name, perceived_colour_value_name, 
  perceived_colour_master_name, department_name, index_code, index_group_name, 
  section_name, garment_group_name, detail_desc
- customers.csv: customer_id, FN, Active, club_member_status, fashion_news_frequency
- transactions_train.csv имеет ~31M записей за ~2 года

Open-Meteo Historical Weather API:
- Бесплатно для некоммерческого использования
- Не требует API ключа
- Исторические данные с 1940 года
- https://open-meteo.com/

Примечание:
H&M dataset НЕ содержит точной геолокации. Postal code анонимизирован.
Для демо используем случайные города Швеции (основной рынок H&M).
"""

import pandas as pd
import numpy as np
from datetime import datetime, timedelta
import requests
import os
from pathlib import Path
from typing import Tuple, Optional
import time

# Стокгольм, Швеция (основной рынок H&M)
STOCKHOLM_LAT = 59.3293
STOCKHOLM_LON = 18.0686

# Гётеборг, Швеция
GOTHENBURG_LAT = 57.7089
GOTHENBURG_LON = 11.9746

# Мальмё, Швеция
MALMO_LAT = 55.6050
MALMO_LON = 13.0007


def load_hm_transactions(data_path: str, limit: Optional[int] = None) -> pd.DataFrame:
    """
    Загрузка транзакций H&M
    
    Args:
        data_path: путь к файлу transactions_train.csv
        limit: ограничить количество записей (для тестирования)
    """
    print(f"Загрузка транзакций из {data_path}...")
    
    if limit:
        df = pd.read_csv(data_path, nrows=limit)
        print(f"Загружено {len(df)} транзакций (лимит: {limit})")
    else:
        df = pd.read_csv(data_path)
        print(f"Загружено {len(df)} транзакций")
    
    # Конвертация даты
    df['t_dat'] = pd.to_datetime(df['t_dat'])
    df['date'] = df['t_dat'].dt.date
    df['year'] = df['t_dat'].dt.year
    df['month'] = df['t_dat'].dt.month
    df['day'] = df['t_dat'].dt.day
    
    return df


def load_hm_articles(data_path: str) -> pd.DataFrame:
    """Загрузка данных о товарах"""
    print(f"Загрузка товаров из {data_path}...")
    df = pd.read_csv(data_path)
    print(f"Загружено {len(df)} товаров")
    return df


def get_historical_weather(
    date: datetime,
    lat: float = STOCKHOLM_LAT,
    lon: float = STOCKHOLM_LON
) -> dict:
    """
    Получение исторических погодных данных через Open-Meteo API
    
    Args:
        date: дата
        lat: широта
        lon: долгота
    
    Returns:
        dict с погодными данными
    """
    url = "https://archive-api.open-meteo.com/v1/archive"
    
    params = {
        "latitude": lat,
        "longitude": lon,
        "start_date": date.strftime("%Y-%m-%d"),
        "end_date": date.strftime("%Y-%m-%d"),
        "daily": "temperature_2m_max,temperature_2m_min,temperature_2m_mean,"
                 "apparent_temperature_max,apparent_temperature_min,"
                 "precipitation_sum,rain_sum,snowfall_sum,"
                 "windspeed_10m_max,weathercode",
        "timezone": "Europe/Stockholm"
    }
    
    try:
        response = requests.get(url, params=params, timeout=10)
        response.raise_for_status()
        data = response.json()
        
        if 'daily' in data and len(data['daily']['time']) > 0:
            return {
                'temperature_max': data['daily']['temperature_2m_max'][0],
                'temperature_min': data['daily']['temperature_2m_min'][0],
                'temperature_mean': data['daily']['temperature_2m_mean'][0],
                'feels_like_max': data['daily']['apparent_temperature_max'][0],
                'feels_like_min': data['daily']['apparent_temperature_min'][0],
                'precipitation': data['daily']['precipitation_sum'][0],
                'rain': data['daily']['rain_sum'][0],
                'snowfall': data['daily']['snowfall_sum'][0],
                'wind_speed': data['daily']['windspeed_10m_max'][0],
                'weather_code': data['daily']['weathercode'][0]
            }
        else:
            return None
            
    except Exception as e:
        print(f"Ошибка получения погоды: {e}")
        return None


def weather_code_to_condition(weather_code: int) -> str:
    """Конвертация WMO weather code в строковое описание"""
    codes = {
        0: 'clear',
        1: 'mostly_clear',
        2: 'partly_cloudy',
        3: 'overcast',
        45: 'fog',
        48: 'fog',
        51: 'drizzle',
        53: 'drizzle',
        55: 'drizzle',
        61: 'rain',
        63: 'rain',
        65: 'rain',
        71: 'snow',
        73: 'snow',
        75: 'snow',
        77: 'snow',
        80: 'rain',
        81: 'rain',
        82: 'rain',
        85: 'snow',
        86: 'snow',
        95: 'thunderstorm',
        96: 'thunderstorm',
        99: 'thunderstorm'
    }
    return codes.get(weather_code, 'unknown')


def get_season_from_month(month: int) -> str:
    """Определение сезона по месяцу"""
    if month in [12, 1, 2]:
        return 'winter'
    elif month in [3, 4, 5]:
        return 'spring'
    elif month in [6, 7, 8]:
        return 'summer'
    else:
        return 'autumn'


def enrich_with_weather(
    df: pd.DataFrame,
    sample_dates: Optional[int] = 365
) -> pd.DataFrame:
    """
    Обогащение транзакций погодными данными
    
    Для производительности берём sample_dates уникальных дат
    и мапим на все транзакции.
    
    Args:
        df: DataFrame с транзакциями
        sample_dates: количество уникальных дат для запроса погоды
    
    Returns:
        DataFrame с погодными данными
    """
    print(f"Обогащение погодными данными...")
    
    # Уникальные даты
    unique_dates = df['date'].unique()
    print(f"Всего уникальных дат: {len(unique_dates)}")
    
    # Для демо ограничиваем количество запросов
    if len(unique_dates) > sample_dates:
        unique_dates = np.random.choice(unique_dates, sample_dates, replace=False)
        print(f"Используем {sample_dates} дат для демо")
    
    # Кэш погоды
    weather_cache = {}
    
    print("Запрос погодных данных...")
    for i, date in enumerate(sorted(unique_dates)):
        if i % 50 == 0:
            print(f"  Прогресс: {i}/{len(unique_dates)}")
        
        date_str = str(date)
        if date_str not in weather_cache:
            weather = get_historical_weather(pd.Timestamp(date))
            if weather:
                weather['weather_condition'] = weather_code_to_condition(weather['weather_code'])
                weather['season'] = get_season_from_month(pd.Timestamp(date).month)
                weather_cache[date_str] = weather
            time.sleep(0.1)  # Rate limiting
    
    print(f"Получена погода для {len(weather_cache)} дат")
    
    # Маппинг на транзакции
    df['date_str'] = df['date'].astype(str)
    
    weather_data = []
    for idx, row in df.iterrows():
        weather = weather_cache.get(row['date_str'], None)
        if weather:
            weather_data.append({
                'temperature': weather['temperature_mean'],
                'feels_like': weather['feels_like_max'],
                'humidity': np.random.randint(40, 90),  # Нет в API
                'wind_speed': weather['wind_speed'],
                'weather_condition': weather['weather_condition'],
                'season': weather['season']
            })
        else:
            # Дефолтные значения
            weather_data.append({
                'temperature': 15.0,
                'feels_like': 15.0,
                'humidity': 65,
                'wind_speed': 5.0,
                'weather_condition': 'clear',
                'season': get_season_from_month(row['month'])
            })
    
    weather_df = pd.DataFrame(weather_data)
    df = pd.concat([df.reset_index(drop=True), weather_df], axis=1)
    
    # Очистка
    if 'date_str' in df.columns:
        df.drop('date_str', axis=1, inplace=True)
    
    print(f"Обогащено {len(df)} транзакций")
    return df


def merge_with_articles(
    transactions_df: pd.DataFrame,
    articles_df: pd.DataFrame
) -> pd.DataFrame:
    """Объединение транзакций с данными о товарах"""
    print("Объединение с данными о товарах...")
    
    df = transactions_df.merge(
        articles_df,
        on='article_id',
        how='left'
    )
    
    print(f"Итоговый DataFrame: {len(df)} записей")
    return df


def create_training_data(df: pd.DataFrame) -> pd.DataFrame:
    """
    Создание финального датасета для обучения
    
    Покупка = positive пример (лайк)
    """
    print("Создание обучающего датасета...")
    
    # Покупка = 1 (лайк)
    df['is_recommended'] = 1
    
    # Выбор нужных колонок
    feature_columns = [
        'temperature', 'feels_like', 'humidity', 'wind_speed',
        'weather_condition', 'season',
        'garment_group_name', 'index_group_name', 'colour_group_name',
        'perceived_colour_master_name', 'product_group_name'
    ]
    
    # Переименование для совместимости с моделью
    rename_map = {
        'garment_group_name': 'category',
        'product_group_name': 'subcategory',
        'colour_group_name': 'base_colour',
        'perceived_colour_master_name': 'style'
    }
    
    training_df = df[feature_columns].copy()
    training_df.rename(columns=rename_map, inplace=True)
    training_df['is_recommended'] = df['is_recommended']
    
    print(f"Создано {len(training_df)} примеров для обучения")
    return training_df


def main():
    """Основной пайплайн"""
    print("="*60)
    print("H&M Dataset + Weather Enrichment")
    print("="*60)
    
    # Пути к данным
    data_dir = Path("data/raw")
    output_dir = Path("data/processed")
    output_dir.mkdir(parents=True, exist_ok=True)
    
    # Загрузка данных
    transactions_df = load_hm_transactions(
        data_dir / "transactions_train.csv",
        limit=100000  # Для демо: 100K транзакций
    )
    
    articles_df = load_hm_articles(data_dir / "articles.csv")
    
    # Обогащение погодой
    enriched_df = enrich_with_weather(transactions_df, sample_dates=100)
    
    # Объединение с товарами
    merged_df = merge_with_articles(enriched_df, articles_df)
    
    # Создание обучающего датасета
    training_df = create_training_data(merged_df)
    
    # Сохранение
    output_path = output_dir / "hm_weather_dataset.csv"
    training_df.to_csv(output_path, index=False)
    print(f"\nСохранено в {output_path}")
    
    # Статистика
    print("\n" + "="*60)
    print("Статистика:")
    print(f"  Всего транзакций: {len(training_df)}")
    print(f"  Уникальных товаров: {merged_df['article_id'].nunique()}")
    print(f"  Уникальных покупателей: {merged_df['customer_id'].nunique()}")
    print(f"  Диапазон дат: {merged_df['date'].min()} - {merged_df['date'].max()}")
    print(f"  Температуры: {training_df['temperature'].min():.1f}°C ... {training_df['temperature'].max():.1f}°C")
    print("="*60)


if __name__ == "__main__":
    main()
