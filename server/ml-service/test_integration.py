"""
Test script to verify ML model integration
"""
import requests
import json

def test_health_endpoint():
    """Test the health endpoint"""
    try:
        response = requests.get('http://localhost:5000/health')
        data = response.json()
        print("Health Check:")
        print(f"  Status: {data['status']}")
        print(f"  Service: {data['service']}")
        print(f"  Model Trained: {data['model_trained']}")
        print(f"  Model Type: {data['model_type']}")
        return data['status'] == 'ok'
    except Exception as e:
        print(f"Health check failed: {e}")
        return False

def test_recommendation():
    """Test the recommendation endpoint"""
    try:
        payload = {
            "user_id": 1,
            "weather": {
                "location": "Moscow",
                "temperature": 5,
                "feels_like": 3,
                "weather": "Облачно",
                "humidity": 70,
                "wind_speed": 5
            },
            "min_confidence": 0.5
        }
        
        response = requests.post(
            'http://localhost:5000/api/ml/recommend',
            headers={'Content-Type': 'application/json'},
            data=json.dumps(payload)
        )
        
        if response.status_code == 200:
            data = response.json()
            print("\nRecommendation Test:")
            print(f"  ML Powered: {data['ml_powered']}")
            print(f"  Outfit Score: {data['outfit_score']:.2%}")
            print(f"  Total Items: {data['total_items']}")
            print(f"  Algorithm: {data['algorithm']}")
            
            if 'recommendations' in data and data['recommendations']:
                print("  Recommended Items:")
                for item in data['recommendations'][:3]:  # Show first 3
                    name = item.get('name', 'Unknown')
                    category = item.get('category', 'Unknown')
                    ml_score = item.get('ml_score', 0)
                    print(f"    - {name} ({category}): {ml_score:.2%}")
            
            return True
        else:
            print(f"Recommendation test failed with status {response.status_code}")
            print(response.text)
            return False
    except Exception as e:
        print(f"Recommendation test failed: {e}")
        return False

def test_model_info():
    """Test the model info endpoint"""
    try:
        response = requests.get('http://localhost:5000/api/ml/model-info')
        if response.status_code == 200:
            data = response.json()
            print("\nModel Info:")
            print(f"  Model Type: {data.get('model_type', 'Unknown')}")
            print(f"  Trained: {data.get('is_trained', False)}")
            print(f"  Features: {data.get('feature_count', 0)}")
            
            if 'top_features' in data:
                print("  Top Features:")
                for feature in data['top_features'][:5]:  # Show top 5
                    name = feature.get('name', 'Unknown')
                    importance = feature.get('importance', 0)
                    print(f"    - {name}: {importance:.4f}")
            
            return True
        else:
            print(f"Model info test failed with status {response.status_code}")
            return False
    except Exception as e:
        print(f"Model info test failed: {e}")
        return False

def main():
    print("Testing ML Model Integration...")
    print("=" * 50)
    
    tests = [
        ("Health Endpoint", test_health_endpoint),
        ("Recommendation Endpoint", test_recommendation),
        ("Model Info Endpoint", test_model_info),
    ]
    
    passed = 0
    total = len(tests)
    
    for name, test_func in tests:
        print(f"\nTesting {name}...")
        if test_func():
            print(f"✅ {name} PASSED")
            passed += 1
        else:
            print(f"❌ {name} FAILED")
    
    print("\n" + "=" * 50)
    print(f"Test Results: {passed}/{total} tests passed")
    
    if passed == total:
        print("🎉 All tests passed! Integration is working correctly.")
    else:
        print("⚠️  Some tests failed. Please check the service.")

if __name__ == '__main__':
    main()