import pandas as pd
import numpy as np
from sklearn.ensemble import GradientBoostingClassifier
from sklearn.model_selection import train_test_split, cross_val_score
from sklearn.metrics import accuracy_score, precision_recall_fscore_support, roc_auc_score
import joblib
import logging
from typing import Tuple, Dict
from .features import FeatureExtractor

logging.basicConfig(level=logging.INFO)
logger = logging.getLogger(__name__)

class OutfitRecommender:
    """
    ML модель для рекомендации одежды на основе градиентного бустинга
    """
    
    def __init__(self):
        self.model = GradientBoostingClassifier(
            n_estimators=200,
            learning_rate=0.05,
            max_depth=6,
            min_samples_split=10,
            min_samples_leaf=5,
            subsample=0.8,
            random_state=42,
            verbose=0
        )
        self.feature_extractor = FeatureExtractor()
        self.is_trained = False
        self.feature_importance = None
        
    def prepare_training_data(self, ratings_data: pd.DataFrame) -> Tuple[np.ndarray, np.ndarray]:
        """
        Подготавливает данные для обучения из рейтингов
        
        Args:
            ratings_data: DataFrame с колонками:
                - overall_rating, comfort_rating, style_rating, weather_match_rating
                - temperature, feels_like, humidity, wind_speed, weather
                - temperature_sensitivity, style_preference, age_range
                - warmth_level, formality_level, min_temp, max_temp, category, item_style
        
        Returns:
            X: матрица признаков
            y: целевая переменная (1 = хорошая рекомендация, 0 = плохая)
        """
        X = []
        y = []
        
        logger.info(f"Preparing training data from {len(ratings_data)} ratings...")
        
        for idx, row in ratings_data.iterrows():
            try:
                # Погодные данные
                weather_data = {
                    'temperature': row.get('temperature'),
                    'feels_like': row.get('feels_like'),
                    'humidity': row.get('humidity'),
                    'wind_speed': row.get('wind_speed'),
                    'weather': row.get('weather', 'Ясно')
                }
                
                # Профиль пользователя
                user_profile = {
                    'temperature_sensitivity': row.get('temperature_sensitivity', 'normal'),
                    'style_preference': row.get('style_preference', 'casual'),
                    'age_range': row.get('age_range', '25-35')
                }
                
                # Предмет одежды
                item = {
                    'warmth_level': row.get('warmth_level', 5),
                    'formality_level': row.get('formality_level', 5),
                    'min_temp': row.get('min_temp', 0),
                    'max_temp': row.get('max_temp', 30),
                    'category': row.get('category', 'upper'),
                    'style': row.get('item_style', 'casual')
                }
                
                # Извлекаем признаки
                weather_features = self.feature_extractor.extract_weather_features(weather_data)
                user_features = self.feature_extractor.extract_user_features(user_profile)
                item_features = self.feature_extractor.extract_item_features(item)
                interaction_features = self.feature_extractor.extract_interaction_features(
                    weather_data, user_profile, item
                )
                
                features = self.feature_extractor.combine_features(
                    weather_features, user_features, item_features, interaction_features
                )
                
                X.append(features)
                
                # Целевая переменная: комбинированная оценка
                overall = row.get('overall_rating', 0)
                comfort = row.get('comfort_rating', 0)
                weather_match = row.get('weather_match_rating', 0)
                
                # Считаем рекомендацию хорошей если:
                # 1. Общая оценка >= 4
                # 2. Комфорт >= 4
                # 3. Соответствие погоде >= 4
                # ИЛИ средняя оценка >= 4
                avg_rating = (overall + comfort + weather_match) / 3
                
                if (overall >= 4 and comfort >= 4 and weather_match >= 4) or avg_rating >= 4.5:
                    y.append(1)
                else:
                    y.append(0)
                    
            except Exception as e:
                logger.warning(f"Error processing row {idx}: {e}")
                continue
        
        X = np.array(X)
        y = np.array(y)
        
        logger.info(f"Prepared {len(X)} samples: {sum(y)} positive, {len(y) - sum(y)} negative")
        
        return X, y
    
    def train(self, ratings_data: pd.DataFrame) -> Dict:
        """
        Обучает модель на исторических данных
        
        Returns:
            Словарь с метриками качества модели
        """
        logger.info(f"Starting training on {len(ratings_data)} records...")
        
        # Подготовка данных
        X, y = self.prepare_training_data(ratings_data)
        
        if len(X) == 0:
            raise ValueError("No valid training data")
        
        # Проверка баланса классов
        pos_ratio = sum(y) / len(y)
        logger.info(f"Class balance: {pos_ratio:.2%} positive")
        
        if pos_ratio < 0.1 or pos_ratio > 0.9:
            logger.warning(f"Imbalanced dataset: {pos_ratio:.2%} positive samples")
        
        # Разделение на train/test
        X_train, X_test, y_train, y_test = train_test_split(
            X, y, test_size=0.2, random_state=42, stratify=y
        )
        
        logger.info(f"Train set: {len(X_train)} samples")
        logger.info(f"Test set: {len(X_test)} samples")
        
        # Обучение модели
        logger.info("Training model...")
        self.model.fit(X_train, y_train)
        
        # Предсказания
        y_pred = self.model.predict(X_test)
        y_pred_proba = self.model.predict_proba(X_test)[:, 1]
        
        # Метрики
        accuracy = accuracy_score(y_test, y_pred)
        precision, recall, f1, _ = precision_recall_fscore_support(
            y_test, y_pred, average='binary', zero_division=0
        )
        
        try:
            auc = roc_auc_score(y_test, y_pred_proba)
        except:
            auc = 0.5
        
        # Cross-validation
        cv_scores = cross_val_score(self.model, X_train, y_train, cv=3, scoring='accuracy')
        
        # Feature importance
        self.feature_importance = self.model.feature_importances_
        feature_names = self.feature_extractor.get_feature_names()
        top_features = sorted(
            zip(feature_names, self.feature_importance),
            key=lambda x: x[1],
            reverse=True
        )[:10]
        
        self.is_trained = True
        
        metrics = {
            'accuracy': float(accuracy),
            'precision': float(precision),
            'recall': float(recall),
            'f1_score': float(f1),
            'auc': float(auc),
            'cv_mean': float(cv_scores.mean()),
            'cv_std': float(cv_scores.std()),
            'train_samples': len(X_train),
            'test_samples': len(X_test),
            'positive_ratio': float(pos_ratio),
            'top_features': [
                {'name': name, 'importance': float(imp)} 
                for name, imp in top_features
            ]
        }
        
        logger.info("Training completed!")
        logger.info(f"Accuracy: {accuracy:.3f}")
        logger.info(f"Precision: {precision:.3f}")
        logger.info(f"Recall: {recall:.3f}")
        logger.info(f"F1: {f1:.3f}")
        logger.info(f"AUC: {auc:.3f}")
        logger.info(f"CV Accuracy: {cv_scores.mean():.3f} (+/- {cv_scores.std():.3f})")
        
        return metrics
    
    def predict_score(self, weather_data: Dict, user_profile: Dict, item: Dict) -> float:
        """
        Предсказывает вероятность, что предмет понравится пользователю
        
        Returns:
            Вероятность от 0 до 1
        """
        if not self.is_trained:
            logger.debug("Model not trained, using fallback scoring")
            return self._fallback_score(weather_data, user_profile, item)
        
        try:
            # Извлекаем признаки
            weather_features = self.feature_extractor.extract_weather_features(weather_data)
            user_features = self.feature_extractor.extract_user_features(user_profile)
            item_features = self.feature_extractor.extract_item_features(item)
            interaction_features = self.feature_extractor.extract_interaction_features(
                weather_data, user_profile, item
            )
            
            features = self.feature_extractor.combine_features(
                weather_features, user_features, item_features, interaction_features
            ).reshape(1, -1)
            
            # Предсказание вероятности
            score = self.model.predict_proba(features)[0][1]
            
            return float(score)
            
        except Exception as e:
            logger.error(f"Error in predict_score: {e}")
            return self._fallback_score(weather_data, user_profile, item)
    
    def _fallback_score(self, weather_data: Dict, user_profile: Dict, item: Dict) -> float:
        """
        Резервная система оценки на основе правил (когда ML модель недоступна)
        """
        temp = weather_data.get('temperature', 20)
        min_temp = item.get('min_temp', 0)
        max_temp = item.get('max_temp', 30)
        warmth = item.get('warmth_level', 5)
        sensitivity = user_profile.get('temperature_sensitivity', 'normal')
        user_style = user_profile.get('style_preference', 'casual')
        item_style = item.get('style', 'casual')
        weather = weather_data.get('weather', 'Ясно').lower()
        weather_conditions = item.get('weather_conditions', [])
        
        score = 0.5  # Базовая оценка
        
        # 1. Температурное соответствие (вес 40%)
        if min_temp <= temp <= max_temp:
            score += 0.4
        elif min_temp - 5 <= temp <= max_temp + 5:
            score += 0.2
        else:
            score -= 0.2
        
        # 2. Чувствительность пользователя (вес 20%)
        if sensitivity == 'cold' and warmth >= 7:
            score += 0.2
        elif sensitivity == 'warm' and warmth <= 3:
            score += 0.2
        elif sensitivity == 'very_cold' and warmth >= 8:
            score += 0.3
        elif sensitivity == 'very_warm' and warmth <= 2:
            score += 0.3
        elif sensitivity == 'normal' and 4 <= warmth <= 6:
            score += 0.1
        
        # 3. Соответствие стилю (вес 20%)
        if user_style == item_style:
            score += 0.2
        elif user_style == 'casual':  # Casual подходит к большинству
            score += 0.1
        
        # 4. Погодные условия (вес 20%)
        weather_map = {
            'ясно': 'clear',
            'облачно': 'clouds',
            'дождь': 'rain',
            'морось': 'drizzle',
            'снег': 'snow'
        }
        weather_eng = weather_map.get(weather, 'clear')
        
        if weather_eng in weather_conditions:
            score += 0.2
        elif not weather_conditions:  # Универсальный предмет
            score += 0.1
        
        # Ограничиваем диапазон [0, 1]
        return max(0.0, min(1.0, score))
    
    def save(self, path: str = 'models/recommender_model.pkl'):
        """Сохраняет модель на диск"""
        try:
            joblib.dump({
                'model': self.model,
                'feature_importance': self.feature_importance,
                'is_trained': self.is_trained
            }, path)
            logger.info(f"✅ Model saved to {path}")
        except Exception as e:
            logger.error(f"Error saving model: {e}")
    
    def load(self, path: str = 'models/recommender_model.pkl'):
        """Загружает модель с диска"""
        try:
            data = joblib.load(path)
            self.model = data['model']
            self.feature_importance = data.get('feature_importance')
            self.is_trained = data.get('is_trained', True)
            logger.info(f"✅ Model loaded from {path}")
        except FileNotFoundError:
            logger.warning(f"⚠️ Model file not found: {path}")
            raise
        except Exception as e:
            logger.error(f"Error loading model: {e}")
            raise