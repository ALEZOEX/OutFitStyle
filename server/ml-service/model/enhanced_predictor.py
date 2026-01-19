import os
import json
import pickle
import logging
from catboost import CatBoostClassifier, CatBoostRanker

logger = logging.getLogger(__name__)

class EnhancedPredictor:
    def __init__(self, model_path: str):
        self.model_path = model_path
        self.model = None
        self.model_version = "unknown"
        self.cat_features = None
        self._load_model()

    def _load_model(self):
        with open(self.model_path, "rb") as f:
            obj = pickle.load(f)

        if isinstance(obj, dict) and obj.get("format") == "catboost_cbm":
            self.model_version = obj.get("version", "unknown")
            self.cat_features = obj.get("cat_features")

            cbm_rel = obj["cbm_path"]
            cbm_path = os.path.join(os.path.dirname(self.model_path), cbm_rel)

            model_type = obj.get("model_type", "classifier")
            if model_type == "ranker":
                self.model = CatBoostRanker()
            else:
                self.model = CatBoostClassifier()

            self.model.load_model(cbm_path)
            logger.info(f"Loaded CatBoost model from {cbm_path}")
            return

        if isinstance(obj, dict) and "model" in obj:
            self.model = obj["model"]
            self.model_version = obj.get("version", "legacy")
            return

        self.model = obj
        self.model_version = "legacy"

    def get_model_version(self) -> str:
        return self.model_version or "unknown"

    def predict(self, feature_df):
        if self.model is None or feature_df is None or len(feature_df) == 0:
            return []

        if hasattr(self.model, "predict_proba"):
            proba = self.model.predict_proba(feature_df)
            return [float(p[1]) for p in proba]

        preds = self.model.predict(feature_df)
        return [float(x) for x in preds]
