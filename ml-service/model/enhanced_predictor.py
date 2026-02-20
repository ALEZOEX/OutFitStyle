import os
import pickle
import logging
from typing import List, Optional
import gc

import pandas as pd
from catboost import CatBoostClassifier, CatBoostRanker, Pool

logger = logging.getLogger(__name__)


class EnhancedPredictor:
    """
    Predictor that loads CatBoost model via manifest models/model.pkl
    and model binary models/model.cbm.
    """

    def __init__(self, manifest_path: str):
        self.manifest_path = manifest_path
        self.model = None
        self.model_kind: str = "classifier"  # classifier | ranker
        self.model_version: str = "unknown"
        self.cat_features: Optional[List[str]] = None
        self.feature_columns: Optional[List[str]] = None  # список колонок для выравнивания
        self._load()

    def _load(self):
        with open(self.manifest_path, "rb") as f:
            manifest = pickle.load(f)

        if not isinstance(manifest, dict) or manifest.get("format") != "catboost_cbm":
            raise ValueError("model.pkl must be a dict with format=catboost_cbm")

        self.model_kind = manifest.get("model_kind", "classifier")
        self.model_version = manifest.get("version", "unknown")
        self.cat_features = manifest.get("cat_features")
        self.feature_columns = manifest.get("feature_columns")  # загружаем список колонок

        cbm_rel = manifest.get("cbm_path", "model.cbm")
        cbm_path = os.path.join(os.path.dirname(self.manifest_path), cbm_rel)

        if self.model_kind == "ranker":
            self.model = CatBoostRanker()
        else:
            self.model = CatBoostClassifier()

        self.model.load_model(cbm_path)
        logger.info("Loaded CatBoost %s model from %s", self.model_kind, cbm_path)

    def get_model_version(self) -> str:
        return self.model_version or "unknown"

    def predict(self, feature_df: pd.DataFrame) -> List[float]:
        if feature_df is None or len(feature_df) == 0:
            return []

        original_shape = feature_df.shape

        # Выравнивание фичей по сохраненному списку колонок
        if self.feature_columns:
            # Добавляем отсутствующие колонки с пустыми значениями
            for col in self.feature_columns:
                if col not in feature_df.columns:
                    # Для категориальных признаков используем пустую строку, для числовых - 0
                    default_value = "" if self.cat_features and col in self.cat_features else 0
                    feature_df[col] = default_value

            # Удаляем лишние колонки
            feature_df = feature_df[[col for col in self.feature_columns if col in feature_df.columns]]

            # Устанавливаем правильный порядок колонок
            feature_df = feature_df[self.feature_columns]

        data = feature_df
        if self.cat_features:
            data = Pool(feature_df, cat_features=self.cat_features)

        # Memory optimization: explicitly manage memory during prediction
        try:
            if self.model_kind == "classifier":
                proba = self.model.predict_proba(data)[:, 1]
                result = [float(x) for x in proba]
            else:
                preds = self.model.predict(data)
                result = [float(x) for x in preds]

            # Explicitly delete temporary variables to free memory
            del data
            if 'proba' in locals():
                del proba
            if 'preds' in locals():
                del preds

            # Trigger garbage collection periodically
            if original_shape[0] > 100:  # Only for larger datasets
                gc.collect()

            return result
        except Exception as e:
            logger.error(f"Prediction error: {e}")
            # Clean up on error
            gc.collect()
            raise
