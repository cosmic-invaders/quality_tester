from flask import *
from PIL import Image
import io
import base64
from flask_ngrok import run_with_ngrok
import matplotlib.pyplot as plt
import ObjectMeasurement
import utlis

app = Flask(__name__)

### to test if server is running
@app.route('/')
def home():
    return jsonify({'message': 'hi'})


@app.route('/dimensions', methods=['POST'])
def calc_dimensions():
    image_str = request.json.get('image')
    image_bytes = base64.b64decode(image_str)
    image_file = io.BytesIO(image_bytes)
    image = Image.open(image_file)
    image = image.convert("RGB")
    image.save("K:/MistralHack/quality_tester_server/com/request.jpg")
    dim = ObjectMeasurement.cal_dim()
    print(dim)
    with open('K:/MistralHack/quality_tester_server/com/result.jpg', 'rb') as f:
        image_bytes = f.read()
        image_b64 = base64.b64encode(image_bytes).decode('utf-8')
        response_data = {
            'res_image': image_b64,
            'dimensions': dim
        }
        return jsonify(response_data)
    

if __name__ == '__main__':
    # app.run()  # for global deployment
    app.run(port=3001)  # for local development
    

