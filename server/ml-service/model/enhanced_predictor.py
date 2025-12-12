import pickle
import pandas as pd
import numpy as np
from typing import List, Dict, Any
import logging


logger = logging.getLogger(__name__)


class EnhancedPredictor:
    """
    Enhanced predictor that implements ranking functionality according to the new contract.
    This predictor works with the /api/rank endpoint and processes candidates in batches.
    """
    
    def __init__(self, model_path: str):
        """
        Initialize the predictor with a trained model.
        
        Args:
            model_path: Path to the trained model pickle file
        """
        self.model_path = model_path
        self.model = None
        self.vectorizer = None  # для one-hot кодирования
        self.model_version = None
        self._load_model()
    
    def _load_model(self):
        """Load the trained model from disk."""
        try:
            with open(self.model_path, 'rb') as f:
                model_artifacts = pickle.load(f)
                
                # Предполагаем, что артефакты содержат модель, версию и векторайзер
                if isinstance(model_artifacts, dict):
                    self.model = model_artifacts.get('model')
                    self.vectorizer = model_artifacts.get('vectorizer')
                    self.model_version = model_artifacts.get('version', 'unknown')
                else:
                    # Обратная совместимость - если просто модель
                    self.model = model_artifacts
                    self.model_version = 'legacy'
                    
            logger.info(f"Model loaded successfully from {self.model_path}")
        except Exception as e:
            logger.error(f"Failed to load model from {self.model_path}: {e}")
            raise
    
    def get_model_version(self) -> str:
        """Get the version of the loaded model."""
        return self.model_version or "unknown"
    
    def predict(self, feature_df: pd.DataFrame) -> List[float]:
        """
        Predict scores for a batch of candidates.
        
        Args:
            feature_df: DataFrame with features for all candidates in the batch
            
        Returns:
            List of scores for each candidate
        """
        if self.model is None:
            raise ValueError("Model not loaded")
        
        try:
            # Выполняем предсказание
            if hasattr(self.model, 'predict_proba'):
                # Для классификаторов используем вероятность положительного класса
                predictions = self.model.predict_proba(feature_df)
                # Берем вероятность класса 1 (подходит/не подходит)
                scores = [pred[1] if len(pred) > 1 else pred[0] for pred in predictions]
            elif hasattr(self.model, 'predict'):
                # Для регрессоров или моделей без predict_proba
                scores = self.model.predict(feature_df).tolist()
            else:
                raise ValueError("Model does not have predict or predict_proba method")
            
            # Преобразуем в положительные значения если необходимо
            # (важно для интерпретации как "релевантность")
            scores = [max(0.0, float(score)) for score in scores]
            
            return scores
        except Exception as e:
            logger.error(f"Prediction failed: {e}")
            # В случае ошибки возвращаем нулевые оценки
            return [0.0] * len(feature_df)