import numpy as np

def calculate_accuracy(y_true, y_pred):
    """Calculate prediction accuracy"""
    return np.mean(np.array(y_true) == np.array(y_pred))

def calculate_precision(y_true, y_pred):
    """Calculate prediction precision"""
    # TODO: Implement precision calculation
    pass