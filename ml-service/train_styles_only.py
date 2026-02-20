import pandas as pd
import os
import logging
import random
import sys
import json
from datetime import datetime
from model.advanced_trainer import AdvancedOutfitRecommender

# Set up logging
logging.basicConfig(level=logging.INFO, format='%(asctime)s - %(levelname)s - %(message)s')
logger = logging.getLogger(__name__)

def map_season_to_temp(season):
    """Отображает сезон на соответствующую температуру"""
    season_temp_map = {
        'Winter': 5,
        'Fall': 15,
        'Spring': 15,
        'Summer': 25
    }
    return season_temp_map.get(season, 15)

def map_category_to_warmth(category):
    """Отображает категорию одежды на уровень тепла"""
    warmth_map = {
        'Shirts': 3,
        'Tshirts': 2,
        'Sweatshirts': 4,
        'Jackets': 6,
        'Sweaters': 5,
        'Coats': 7,
        'Jeans': 2,
        'Trousers': 2,
        'Shorts': 1,
        'Skirts': 1,
        'Dresses': 3,
        'Sarees': 3,
        'Kurtas': 3,
        'Casual Shoes': 1,
        'Sports Shoes': 1,
        'Sandals': 1,
        'Flip Flops': 1,
        'Formal Shoes': 1,
        'Heels': 1,
        'Flats': 1,
        'Belts': 1,
        'Watches': 1,
        'Sunglasses': 1,
        'Wallets': 1,
        'Bags': 1,
        'Handbags': 1,
        'Scarves': 3,
        'Caps': 2,
        'Innerwear Vests': 2,
        'Briefs': 1,
        'Boxers': 1,
        'Night suits': 2,
        'Loungewear and Nightwear': 2,
        'Rain Jacket': 6,
        'Blazers': 5,
        'Waistcoat': 4,
        'Tracksuits': 4,
        'Track Pants': 3,
        'Swimwear': 1,
        'Apparel Set': 3,
        'Kurta Sets': 3,
        'unknown': 3  # значение по умолчанию
    }
    return warmth_map.get(category, 3)

def map_formality(article_type, usage):
    """Определяет уровень формальности на основе типа изделия и использования"""
    formal_types = ['Shirts', 'Blazers', 'Formal Shoes', 'Trousers']
    casual_types = ['Tshirts', 'Jeans', 'Shorts', 'Casual Shoes', 'Flip Flops', 'Sandals']
    
    if article_type in formal_types or (usage and 'Formal' in usage):
        return 7
    elif article_type in casual_types or (usage and 'Casual' in usage):
        return 3
    else:
        return 5  # средняя формальность по умолчанию

def prepare_training_data_from_styles(styles_path='data/styles.csv'):
    """
    Подготавливает обучающие данные из файла styles.csv
    
    Args:
        styles_path: Путь к файлу styles.csv
        
    Returns:
        DataFrame с подготовленными данными для обучения
    """
    logger.info(f"Загрузка данных из {styles_path}...")
    
    # Загружаем данные
    if not os.path.exists(styles_path):
        raise FileNotFoundError(f"Файл {styles_path} не найден")
        
    # Загружаем CSV с обработкой ошибок
    try:
        styles_df = pd.read_csv(styles_path, on_bad_lines='skip')
        logger.info(f"Загружено {len(styles_df)} записей из styles.csv (поврежденные строки пропущены)")
    except Exception as e:
        logger.error(f"Ошибка при загрузке CSV: {str(e)}")
        raise
    
    # Пример преобразования:
    training_data = []
    
    # Генерируем обучающие примеры на основе записей из styles.csv
    logger.info("Генерация обучающих примеров...")
    total_rows = len(styles_df)
    for idx, row in styles_df.iterrows():
        # Прогресс
        if idx % max(1, total_rows // 20) == 0:  # Показываем прогресс каждые 5%
            progress = (idx / total_rows) * 100
            logger.info(f"Прогресс: {progress:.1f}% ({idx}/{total_rows})")
            
        # Получаем информацию из строки
        try:
            gender = str(row.get('gender', 'Unisex'))
            master_category = str(row.get('masterCategory', 'unknown'))
            sub_category = str(row.get('subCategory', 'unknown'))
            article_type = str(row.get('articleType', 'unknown'))
            base_colour = str(row.get('baseColour', 'unknown'))
            season = str(row.get('season', 'unknown'))
            year = row.get('year', 2015)
            usage = str(row.get('usage', 'unknown'))
            product_display_name = str(row.get('productDisplayName', f'Item_{idx}'))
        except Exception as e:
            logger.warning(f"Ошибка при обработке строки {idx}: {str(e)}")
            continue
        
        # Определяем параметры одежды
        warmth_level = map_category_to_warmth(article_type)
        formality_level = map_formality(article_type, usage)
        
        # Генерируем обучающие примеры для разных условий
        for i in range(3):  # Создаем 3 примера для каждого элемента одежды
            # Случайные пользовательские данные
            age_ranges = ['18-25', '25-35', '35-45', '45+']
            style_preferences = ['Casual', 'Formal', 'Sports', 'Ethnic']
            temperature_sensitivities = ['cold_sensitive', 'normal', 'heat_sensitive']
            formality_preferences = ['very_formal', 'formal', 'normal', 'informal']
            
            # Случайные погодные условия
            temp = random.randint(-5, 35)
            feels_like = temp + random.randint(-3, 3)
            humidity = random.randint(30, 90)
            wind_speed = random.uniform(0, 15)
            weather_conditions = ['clear', 'clouds', 'rain', 'snow']
            weather_condition = random.choice(weather_conditions)
            
            # Определяем сезон на основе температуры
            if temp < 5:
                weather_season = 'winter'
            elif temp < 15:
                weather_season = 'spring'
            elif temp < 25:
                weather_season = 'summer'
            else:
                weather_season = 'autumn'
            
            # Определяем, рекомендуется ли этот предмет одежды
            # Это ключевая логика для создания обучающего набора данных
            is_recommended = False
            
            # Основные критерии рекомендации:
            # 1. Температура находится в пределах рекомендуемого диапазона
            # 2. Сезон совпадает с назначением одежды
            # 3. Формальность соответствует предпочтениям пользователя
            
            # Определяем подходящий температурный диапазон для этой одежды
            min_temp_for_item = 15 - warmth_level * 2  # Более теплая одежда для холодной погоды
            max_temp_for_item = 30 - warmth_level      # Более легкая одежда для теплой погоды
            
            # Проверяем, подходит ли температура
            temp_suitable = min_temp_for_item <= temp <= max_temp_for_item
            
            # Проверяем сезонную совместимость
            season_match = True
            if season != 'unknown':
                optimal_temp_for_season = map_season_to_temp(season)
                season_match = abs(temp - optimal_temp_for_season) <= 10
            
            # Проверяем формальность
            formality_suitable = True  # Упрощенная проверка
            
            # Определяем рекомендацию
            is_recommended = temp_suitable and season_match and formality_suitable
            
            # С вероятностью 10% делаем "ошибочные" рекомендации для лучшего обучения
            if random.random() < 0.1:
                is_recommended = not is_recommended
            
            # Создаем запись для обучения
            record = {
                'temperature': temp,
                'feels_like': feels_like,
                'humidity': humidity,
                'wind_speed': wind_speed,
                'weather_condition': weather_condition,
                'season': weather_season,
                'age_range': random.choice(age_ranges),
                'style_preference': random.choice(style_preferences),
                'temperature_sensitivity': random.choice(temperature_sensitivities),
                'formality_preference': random.choice(formality_preferences),
                'category': article_type,
                'item_style': usage,
                'min_temp': min_temp_for_item,
                'max_temp': max_temp_for_item,
                'warmth_level': warmth_level,
                'formality_level': formality_level,
                'is_recommended': is_recommended,
                'item_name': product_display_name
            }
            
            training_data.append(record)
    
    # Преобразуем в DataFrame
    df = pd.DataFrame(training_data)
    logger.info(f"Создано {len(df)} обучающих примеров")
    
    # Показываем статистику
    logger.info(f"Рекомендуемые предметы: {df['is_recommended'].sum()} ({df['is_recommended'].mean()*100:.1f}%)")
    logger.info(f"Нерекомендуемые предметы: {len(df) - df['is_recommended'].sum()} ({(1-df['is_recommended'].mean())*100:.1f}%)")
    
    return df

def load_previous_metrics():
    """Загружает метрики предыдущих обучений"""
    metrics_file = 'models/training_metrics.json'
    if os.path.exists(metrics_file):
        try:
            with open(metrics_file, 'r') as f:
                return json.load(f)
        except:
            return []
    return []

def save_metrics(metrics, version):
    """Сохраняет метрики обучения"""
    metrics_file = 'models/training_metrics.json'
    all_metrics = load_previous_metrics()
    
    # Добавляем информацию о версии и времени
    metrics['version'] = version
    metrics['timestamp'] = datetime.now().isoformat()
    
    all_metrics.append(metrics)
    
    # Сохраняем только последние 10 записей
    if len(all_metrics) > 10:
        all_metrics = all_metrics[-10:]
    
    with open(metrics_file, 'w') as f:
        json.dump(all_metrics, f, indent=2)

def get_next_version():
    """Определяет следующий номер версии модели"""
    models_dir = 'models'
    if not os.path.exists(models_dir):
        os.makedirs(models_dir)
        return 1
    
    versions = []
    for file in os.listdir(models_dir):
        if file.startswith('advanced_recommender_v') and file.endswith('.pkl'):
            try:
                version = int(file.split('_v')[1].split('.')[0])
                versions.append(version)
            except:
                continue
    
    return max(versions) + 1 if versions else 1

def main():
    logger.info("="*60)
    logger.info("🚀 Training OutfitStyle ML Model from styles.csv Only")
    logger.info("="*60)
    
    # Подготавливаем данные для обучения
    styles_path = 'data/styles.csv'
    
    if not os.path.exists(styles_path):
        logger.error(f"Файл styles.csv не найден: {styles_path}")
        logger.info("Пожалуйста, поместите файл styles.csv в директорию data/")
        sys.exit(1)
    
    try:
        df = prepare_training_data_from_styles(styles_path)
    except Exception as e:
        logger.error(f"Ошибка при подготовке обучающих данных: {str(e)}")
        sys.exit(1)
    
    # Создаем и обучаем модель
    logger.info("\n🧠 Обучение модели...")
    model = AdvancedOutfitRecommender(model_type='gradient_boosting')
    
    try:
        metrics = model.train(df, optimize_hyperparameters=False)
        logger.info("✅ Обучение успешно завершено")
    except Exception as e:
        logger.error(f"Ошибка при обучении модели: {str(e)}")
        sys.exit(1)
    
    # Создаем директорию для моделей если её нет
    os.makedirs('models', exist_ok=True)
    
    # Определяем версию модели
    version = get_next_version()
    model_filename = f'models/advanced_recommender_v{version}.pkl'
    default_model_filename = 'models/advanced_recommender.pkl'
    kaggle_model_filename = 'models/kaggle_trained_recommender.pkl'
    
    # Сохраняем модель
    try:
        model.save(model_filename)
        # Также сохраняем как основную модель
        model.save(default_model_filename)
        # И как Kaggle-модель для совместимости
        model.save(kaggle_model_filename)
        logger.info(f"💾 Модель сохранена как {model_filename}")
        logger.info(f"💾 Модель также сохранена как {default_model_filename}")
        logger.info(f"💾 Модель также сохранена как {kaggle_model_filename}")
    except Exception as e:
        logger.error(f"Ошибка при сохранении модели: {str(e)}")
        sys.exit(1)
    
    # Сохраняем метрики
    save_metrics(metrics, version)
    logger.info("📈 Метрики обучения сохранены")
    
    # Создаем тестовое предсказание
    logger.info("\n🧪 Тестовое предсказание...")
    
    test_weather = {
        'temperature': 15.0,
        'feels_like': 13.0,
        'humidity': 70,
        'wind_speed': 5.0,
        'weather_condition': 'clouds',
        'season': 'spring'
    }
    
    test_user = {
        'age_range': '25-35',
        'style_preference': 'Casual',
        'temperature_sensitivity': 'normal',
        'formality_preference': 'informal'
    }
    
    test_item = {
        'item_name': 'Light Jacket',
        'category': 'Jackets',
        'min_temp': 10,
        'max_temp': 20,
        'warmth_level': 4,
        'formality_level': 3,
        'item_style': 'Casual'
    }
    
    result = model.predict_single(test_weather, test_user, test_item)

    logger.info(f"\nРезультат тестового предсказания:")
    logger.info(f"  Предмет: {test_item['item_name']}")
    logger.info(f"  Температура: {test_weather['temperature']}°C")
    logger.info(f"  Рекомендуется: {result['is_recommended']}")
    logger.info(f"  Уверенность: {result['confidence']:.2%}")
    logger.info(f"  Вероятности: {result['probabilities']}")

    logger.info("\n✅ Обучение модели завершено!")
    logger.info(f"Модель сохранена как: {model_filename}")

if __name__ == '__main__':
    main()