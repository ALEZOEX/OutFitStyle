import pandas as pd
import numpy as np
from sklearn.ensemble import GradientBoostingClassifier, RandomForestClassifier
from sklearn.model_selection import train_test_split, cross_val_score, GridSearchCV
from sklearn.metrics import (
    accuracy_score, precision_recall_fscore_support, 
    roc_auc_score, confusion_matrix, classification_report
)
from sklearn.preprocessing import LabelEncoder
import joblib
import logging
import matplotlib.pyplot as plt
import seaborn as sns

logging.basicConfig(level=logging.INFO)
logger = logging.getLogger(__name__)

class AdvancedOutfitRecommender:
    """
    Продвинутая ML модель для рекомендаций одежды
    """
    
    def __init__(self, model_type='gradient_boosting'):
        """
        Args:
            model_type: 'gradient_boosting', 'random_forest', or 'ensemble'
        """
        self.model_type = model_type
        self.model = None
        self.label_encoders = {}
        self.is_trained = False
        self.feature_importance = None
        self.feature_names = None
        
        # Инициализация модели
        if model_type == 'gradient_boosting':
            self.model = GradientBoostingClassifier(
                n_estimators=300,
                learning_rate=0.05,
                max_depth=7,
                min_samples_split=20,
                min_samples_leaf=10,
                subsample=0.8,
                random_state=42,
                verbose=1
            )
        elif model_type == 'random_forest':
            self.model = RandomForestClassifier(
                n_estimators=200,
                max_depth=15,
                min_samples_split=10,
                min_samples_leaf=5,
                random_state=42,
                n_jobs=-1,
                verbose=1
            )
        else:
            raise ValueError(f"Unknown model type: {model_type}")
    
    def prepare_features(self, df, is_training=True):
        """
        Подготавливает признаки из датафрейма
        """
        logger.info("Preparing features...")
        
        # Категориальные признаки для кодирования
        categorical_features = [
            'weather_condition', 'season', 'age_range', 
            'style_preference', 'temperature_sensitivity',
            'formality_preference', 'category', 'item_style'
        ]
        
        # Числовые признаки
        numeric_features = [
            'temperature', 'feels_like', 'humidity', 'wind_speed',
            'min_temp', 'max_temp', 'warmth_level', 'formality_level'
        ]
        
        # Кодируем категориальные признаки
        df_encoded = df.copy()
        
        for feature in categorical_features:
            if feature in df.columns:
                if is_training:
                    # При обучении создаем новый encoder
                    le = LabelEncoder()
                    df_encoded[feature] = le.fit_transform(df[feature].astype(str))
                    self.label_encoders[feature] = le
                else:
                    # При предсказании используем существующий encoder
                    if feature in self.label_encoders:
                        le = self.label_encoders[feature]
                        # Обрабатываем неизвестные категории
                        df_encoded[feature] = df[feature].apply(
                            lambda x: le.transform([str(x)])[0] 
                            if str(x) in le.classes_ else -1
                        )
                    else:
                        df_encoded[feature] = -1
        
        # Создаем дополнительные признаки (feature engineering)
        df_encoded['temp_range'] = df['max_temp'] - df['min_temp']
        df_encoded['temp_suitability'] = (
            (df['temperature'] >= df['min_temp']) & 
            (df['temperature'] <= df['max_temp'])
        ).astype(int)
        df_encoded['temp_distance'] = np.abs(
            df['temperature'] - (df['min_temp'] + df['max_temp']) / 2
        )
        df_encoded['feels_like_diff'] = df['temperature'] - df['feels_like']
        
        # Температурные категории
        df_encoded['temp_category'] = pd.cut(
            df['temperature'],
            bins=[-np.inf, 0, 10, 18, 25, np.inf],
            labels=[0, 1, 2, 3, 4]
        ).astype(int)
        
        # Финальный набор признаков
        feature_columns = (
            categorical_features + 
            numeric_features + 
            ['temp_range', 'temp_suitability', 'temp_distance', 
             'feels_like_diff', 'temp_category']
        )
        
        X = df_encoded[feature_columns]
        
        if is_training:
            self.feature_names = feature_columns
        
        return X
    
    def train(self, df, optimize_hyperparameters=False):
        """
        Обучает модель на датасете
        
        Args:
            df: DataFrame с колонками features + 'is_recommended' (target)
            optimize_hyperparameters: Запускать ли GridSearch для оптимизации
        """
        logger.info(f"Starting training with {len(df)} samples...")
        
        # Подготовка признаков
        X = self.prepare_features(df, is_training=True)
        y = df['is_recommended'].values
        
        # Статистика
        logger.info(f"Features shape: {X.shape}")
        logger.info(f"Positive samples: {sum(y)} ({sum(y)/len(y)*100:.1f}%)")
        logger.info(f"Negative samples: {len(y) - sum(y)} ({(len(y) - sum(y))/len(y)*100:.1f}%)")
        
        # Разделение на train/test
        X_train, X_test, y_train, y_test = train_test_split(
            X, y, test_size=0.2, random_state=42, stratify=y
        )
        
        logger.info(f"Train set: {len(X_train)} samples")
        logger.info(f"Test set: {len(X_test)} samples")
        
        # Оптимизация гиперпараметров (опционально)
        if optimize_hyperparameters:
            logger.info("Running hyperparameter optimization...")
            self._optimize_hyperparameters(X_train, y_train)
        
        # Обучение
        logger.info("Training model...")
        self.model.fit(X_train, y_train)
        
        # Предсказания
        y_pred = self.model.predict(X_test)
        y_pred_proba = self.model.predict_proba(X_test)[:, 1]
        
        # Метрики
        metrics = self._calculate_metrics(y_test, y_pred, y_pred_proba)
        
        # Cross-validation
        cv_scores = cross_val_score(
            self.model, X_train, y_train, 
            cv=5, scoring='accuracy', n_jobs=-1
        )
        metrics['cv_mean'] = float(cv_scores.mean())
        metrics['cv_std'] = float(cv_scores.std())
        
        # Feature importance
        if hasattr(self.model, 'feature_importances_'):
            self.feature_importance = self.model.feature_importances_
            top_features = self._get_top_features(10)
            metrics['top_features'] = top_features
        
        # Confusion matrix
        cm = confusion_matrix(y_test, y_pred)
        metrics['confusion_matrix'] = cm.tolist()
        
        self.is_trained = True
        
        # Логирование результатов
        logger.info("\n" + "="*60)
        logger.info("TRAINING RESULTS")
        logger.info("="*60)
        logger.info(f"Accuracy:  {metrics['accuracy']:.4f}")
        logger.info(f"Precision: {metrics['precision']:.4f}")
        logger.info(f"Recall:    {metrics['recall']:.4f}")
        logger.info(f"F1 Score:  {metrics['f1_score']:.4f}")
        logger.info(f"AUC-ROC:   {metrics['auc']:.4f}")
        logger.info(f"CV Score:  {metrics['cv_mean']:.4f} (+/- {metrics['cv_std']:.4f})")
        logger.info("="*60)
        
        if 'top_features' in metrics:
            logger.info("\nTop 10 Important Features:")
            for feat in metrics['top_features']:
                logger.info(f"  {feat['name']:<30} {feat['importance']:.4f}")
        
        return metrics
    
    def _optimize_hyperparameters(self, X_train, y_train):
        """Оптимизация гиперпараметров через GridSearch"""
        
        if self.model_type == 'gradient_boosting':
            param_grid = {
                'n_estimators': [200, 300],
                'learning_rate': [0.05, 0.1],
                'max_depth': [5, 7],
                'min_samples_split': [10, 20],
            }
        else:  # random_forest
            param_grid = {
                'n_estimators': [150, 200],
                'max_depth': [10, 15],
                'min_samples_split': [5, 10],
            }
        
        grid_search = GridSearchCV(
            self.model, param_grid, 
            cv=3, scoring='f1', n_jobs=-1, verbose=2
        )
        
        grid_search.fit(X_train, y_train)
        
        logger.info(f"Best parameters: {grid_search.best_params_}")
        logger.info(f"Best F1 score: {grid_search.best_score_:.4f}")
        
        self.model = grid_search.best_estimator_
    
    def _calculate_metrics(self, y_true, y_pred, y_pred_proba):
        """Вычисляет метрики качества модели"""
        
        accuracy = accuracy_score(y_true, y_pred)
        precision, recall, f1, _ = precision_recall_fscore_support(
            y_true, y_pred, average='binary', zero_division=0
        )
        
        try:
            auc = roc_auc_score(y_true, y_pred_proba)
        except:
            auc = 0.5
        
        return {
            'accuracy': float(accuracy),
            'precision': float(precision),
            'recall': float(recall),
            'f1_score': float(f1),
            'auc': float(auc),
        }
    
    def _get_top_features(self, n=10):
        """Возвращает топ-N важных признаков"""
        
        if self.feature_importance is None or self.feature_names is None:
            return []
        
        feature_importance_pairs = list(zip(
            self.feature_names, 
            self.feature_importance
        ))
        
        sorted_features = sorted(
            feature_importance_pairs, 
            key=lambda x: x[1], 
            reverse=True
        )[:n]
        
        return [
            {'name': name, 'importance': float(importance)}
            for name, importance in sorted_features
        ]
    
    def predict(self, df):
        """
        Предсказывает для новых данных
        
        Returns:
            (predictions, probabilities)
        """
        if not self.is_trained:
            raise ValueError("Model is not trained yet!")
        
        X = self.prepare_features(df, is_training=False)
        
        predictions = self.model.predict(X)
        probabilities = self.model.predict_proba(X)[:, 1]
        
        return predictions, probabilities
    
    def predict_single(self, weather_data, user_profile, item):
        """Предсказание для одного предмета одежды"""
        
        # Создаем DataFrame из входных данных
        data = {
            **weather_data,
            **user_profile,
            **item
        }
        
        df = pd.DataFrame([data])
        
        predictions, probabilities = self.predict(df)
        
        return {
            'is_recommended': bool(predictions[0]),
            'confidence': float(probabilities[0])
        }
    
    def save(self, filepath='models/advanced_recommender.pkl'):
        """Сохраняет модель"""
        
        model_data = {
            'model': self.model,
            'label_encoders': self.label_encoders,
            'feature_names': self.feature_names,
            'feature_importance': self.feature_importance,
            'is_trained': self.is_trained,
            'model_type': self.model_type
        }
        
        joblib.dump(model_data, filepath)
        logger.info(f"✅ Model saved to {filepath}")
    
    def load(self, filepath='models/advanced_recommender.pkl'):
        """Загружает модель"""
        
        model_data = joblib.load(filepath)
        
        self.model = model_data['model']
        self.label_encoders = model_data['label_encoders']
        self.feature_names = model_data['feature_names']
        self.feature_importance = model_data.get('feature_importance')
        self.is_trained = model_data['is_trained']
        self.model_type = model_data.get('model_type', 'gradient_boosting')
        
        logger.info(f"✅ Model loaded from {filepath}")
    
    def plot_feature_importance(self, save_path='feature_importance.png'):
        """Визуализирует важность признаков"""
        
        if self.feature_importance is None:
            logger.warning("No feature importance available")
            return
        
        top_features = self._get_top_features(15)
        
        names = [f['name'] for f in top_features]
        importances = [f['importance'] for f in top_features]
        
        plt.figure(figsize=(10, 6))
        plt.barh(names, importances)
        plt.xlabel('Importance')
        plt.title('Top 15 Feature Importance')
        plt.tight_layout()
        plt.savefig(save_path, dpi=300, bbox_inches='tight')
        logger.info(f"Feature importance plot saved to {save_path}")