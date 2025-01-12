from flask import Flask, request, jsonify
from flask_cors import CORS
import pickle
import numpy as np

# Load your ensemble model (pickle file)
with open('ensemble_model_final.pkl', 'rb') as file:
    model = pickle.load(file)

# Crop mapping dictionary
CROP_MAPPING = {
    "Crop 1": "Tomato",
    "Crop 2": "Watermelon",
    "Crop 3": "Tapioca",
    "Crop 4": "Sweet Potato",
    "Crop 5": "Sunflower",
    "Crop 6": "Sugarcane",
    "Crop 7": "Spinach",
    "Crop 8": "Soybean",
    "Crop 9": "Rice",
    "Crop 10": "Pumpkin",
    "Crop 11": "Peanut",
    "Crop 12": "Okra or Lady Finger",
    "Crop 13": "Mustard Greens",
    "Crop 14": "Muskmelon",
    "Crop 15": "MungBeans",
    "Crop 16": "Maize",
    "Crop 17": "Lentil",
    "Crop 18": "KidneyBeans",
    "Crop 19": "Ginger",
    "Crop 20": "Garlic",
    "Crop 21": "Elephant Foot Yam",
    "Crop 22": "Cucumber",
    "Crop 23": "Cotton",
    "Crop 24": "Colocasia",
    "Crop 25": "Chilli",
    "Crop 26": "Cauliflower",
    "Crop 27": "Carrot",
    "Crop 28": "Cabbage",
    "Crop 29": "Brinjal",
    "Crop 30": "Banana"
}

app = Flask(__name__)
CORS(app)  # Enable cross-origin requests

@app.route('/predict', methods=['POST'])
def predict():
    data = request.json
    N = data['Nitrogen']
    P = data['Phosphorus']
    K = data['Potassium']
    temp = data['Temperature']
    ph = data['pH']
    humidity = data['Humidity']
    rainfall = data['Rainfall']

    # Predict using the model
    input_features = np.array([[N, P, K, temp, ph, humidity, rainfall]])
    predictions = model.predict_proba(input_features)

    # Return the top 3 crops with percentages
    top_3 = sorted(
        [(i, prob) for i, prob in enumerate(predictions[0])],
        key=lambda x: x[1],
        reverse=True
    )[:3]

    # Map the indices to the crop names from CROP_MAPPING
    response = [{"crop": CROP_MAPPING[f"Crop {idx + 1}"], "probability": f"{prob*100:.2f}%"} for idx, prob in top_3]
    return jsonify(response)

if __name__ == '__main__':
    app.run(host='0.0.0.0', port=5000, debug=True)
