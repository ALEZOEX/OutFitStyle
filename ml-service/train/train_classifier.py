import os
import json
import pickle
import argparse
from datetime import datetime

import pandas as pd
from sklearn.model_selection import train_test_split
from sklearn.metrics import roc_auc_score, log_loss
from catboost import CatBoostClassifier

CAT_FEATURES = [
    "weather_condition",
    "season",
    "age_range",
    "style_preference",
    "temperature_sensitivity",
    "formality_preference",
    "item_name",
    "category",
    "item_style"
]

def main():
    ap = argparse.ArgumentParser()
    ap.add_argument("--data-path", default="data/raw/training_data.csv")
    ap.add_argument("--out-dir", default="models")
    args = ap.parse_args()

    df = pd.read_csv(args.data_path, on_bad_lines="skip")

    # Определяем целевую колонку
    if "is_recommended" in df.columns:
        df['target'] = df["is_recommended"].astype(int)
    elif "target" in df.columns:
        df['target'] = df["target"].astype(int)
    else:
        raise ValueError("No target column found (need 'is_recommended' or 'target')")

    y = df["target"].values
    X = df.drop(columns=["target", "is_recommended"], errors='ignore')

    # сохраняем список колонок, на которых обучалась модель
    feature_columns = list(X.columns)

    # приводим к строкам категориальные
    for c in CAT_FEATURES:
        if c in X.columns:
            X[c] = X[c].astype(str)

    X_train, X_test, y_train, y_test = train_test_split(X, y, test_size=0.2, random_state=42)

    model = CatBoostClassifier(
        iterations=800,
        depth=6,
        learning_rate=0.05,
        loss_function="Logloss",
        eval_metric="AUC",
        random_seed=42,
        verbose=100,
        cat_features=[X.columns.get_loc(c) for c in CAT_FEATURES if c in X.columns],
    )

    print("Категориальные колонки:", [c for c in CAT_FEATURES if c in X.columns])
    print("Все колонки X:", X.columns.tolist())

    model.fit(X_train, y_train, eval_set=(X_test, y_test), use_best_model=True)

    proba = model.predict_proba(X_test)[:, 1]
    auc = roc_auc_score(y_test, proba)
    ll = log_loss(y_test, proba)

    os.makedirs(args.out_dir, exist_ok=True)

    version = datetime.now().strftime("%Y%m%d_%H%M%S")
    cbm_path = os.path.join(args.out_dir, "model.cbm")
    model.save_model(cbm_path)

    manifest = {
        "format": "catboost_cbm",
        "model_kind": "classifier",       # потом будет "ranker"
        "cbm_path": "model.cbm",
        "version": version,
        "cat_features": [c for c in CAT_FEATURES if c in X.columns],
        "feature_columns": feature_columns,
        "metrics": {"auc": float(auc), "logloss": float(ll)},
        "created_at": datetime.now().isoformat(),
    }

    with open(os.path.join(args.out_dir, "model.pkl"), "wb") as f:
        pickle.dump(manifest, f)

    with open(os.path.join(args.out_dir, "metadata.json"), "w", encoding="utf-8") as f:
        json.dump(manifest, f, ensure_ascii=False, indent=2)

    print("Saved:", cbm_path)
    print("AUC:", auc, "Logloss:", ll)

if __name__ == "__main__":
    main()