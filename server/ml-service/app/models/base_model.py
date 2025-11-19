class BaseModel:
    """Base class for ML models"""
    def __init__(self):
        pass
    
    def train(self, data):
        """Train the model"""
        raise NotImplementedError
    
    def predict(self, data):
        """Make predictions"""
        raise NotImplementedError