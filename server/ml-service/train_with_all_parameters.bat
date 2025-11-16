@echo off
echo Generating comprehensive training data with all parameters...
python scripts/generate_comprehensive_training_data.py

echo.
echo Training model with comprehensive data...
python scripts/train_comprehensive_model.py

echo.
echo Done! Model has been trained with all parameters:
echo - Gender
echo - Age
echo - Temperature
echo - Humidity
echo - Wind
echo - Weather conditions
echo - Temperature sensitivity
pause