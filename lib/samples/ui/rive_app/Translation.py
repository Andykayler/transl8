from transformers import AutoTokenizer, AutoModelForSeq2SeqLM
from flask import Flask, request, jsonify
from flask_cors import CORS

app = Flask(__name__)
CORS(app)
app.config['CORS_HEADERS'] = 'Content-Type'

try:
    # Load models and tokenizers
    model_en_fr = "Helsinki-NLP/opus-mt-en-fr"
    tokenizer_en_fr = AutoTokenizer.from_pretrained(model_en_fr)
    model_en_fr = AutoModelForSeq2SeqLM.from_pretrained(model_en_fr)

    model_fr_tum = "Helsinki-NLP/opus-mt-fr-tum"
    tokenizer_fr_tum = AutoTokenizer.from_pretrained(model_fr_tum)
    model_fr_tum = AutoModelForSeq2SeqLM.from_pretrained(model_fr_tum)

    model_en_ny = "Helsinki-NLP/opus-mt-en-ny"
    tokenizer_en_ny = AutoTokenizer.from_pretrained(model_en_ny)
    model_en_ny = AutoModelForSeq2SeqLM.from_pretrained(model_en_ny)

    model_ny_en = "Helsinki-NLP/opus-mt-ny-en"
    tokenizer_ny_en = AutoTokenizer.from_pretrained(model_ny_en)
    model_ny_en = AutoModelForSeq2SeqLM.from_pretrained(model_ny_en)

    model_tum_en = "Helsinki-NLP/opus-mt-tum-en"
    tokenizer_tum_en = AutoTokenizer.from_pretrained(model_tum_en)
    model_tum_en = AutoModelForSeq2SeqLM.from_pretrained(model_tum_en)

    model_en_ko = "Helsinki-NLP/opus-mt-tc-big-en-ko"
    tokenizer_en_ko = AutoTokenizer.from_pretrained(model_en_ko)
    model_en_ko = AutoModelForSeq2SeqLM.from_pretrained(model_en_ko)

    model_ko_en = "Helsinki-NLP/opus-mt-ko-en"
    tokenizer_ko_en = AutoTokenizer.from_pretrained(model_ko_en)
    model_ko_en = AutoModelForSeq2SeqLM.from_pretrained(model_ko_en)

except Exception as e:
    print("Error loading models:", e)
    exit(1)

@app.route('/translate', methods=['POST'])
def translate_text():
    data = request.get_json()

    if 'text' not in data or 'direction' not in data:
        return jsonify({'error': 'Missing text or direction in request'}), 400

    text = data['text']
    direction = data['direction']

    if direction == "en-ny":
        tokenizer = tokenizer_en_ny
        model = model_en_ny
    elif direction == "ny-en":
        tokenizer = tokenizer_ny_en
        model = model_ny_en
    elif direction == "tum-en":
        tokenizer = tokenizer_tum_en
        model = model_tum_en
    elif direction == "en-tum":
        return translate_en_to_tum(text)
    elif direction == "en-ko":
        tokenizer = tokenizer_en_ko
        model = model_en_ko
    elif direction == "ko-en":
        tokenizer = tokenizer_ko_en
        model = model_ko_en
    elif direction == "ko-ny":
        return translate_ko_to_ny(text)
    elif direction == "ko-tum":
        return translate_ko_to_tum(text)
    elif direction == "ny-ko":
        return translate_ny_to_ko(text)
    elif direction == "tum-ko":
        return translate_tum_to_ko(text)
    else:
        return jsonify({'error': 'Invalid direction specified'}), 400

    try:
        inputs = tokenizer(text, return_tensors="pt", padding=True, truncation=True)
        outputs = model.generate(inputs["input_ids"])
        translated_text = tokenizer.decode(outputs[0], skip_special_tokens=True)
        return jsonify({'translated_text': translated_text})
    except Exception as e:
        return jsonify({'error': str(e)}), 500

def translate_en_to_fr(text):
    inputs = tokenizer_en_fr(text, return_tensors="pt", padding=True, truncation=True)
    outputs = model_en_fr.generate(inputs["input_ids"])
    fr_text = tokenizer_en_fr.decode(outputs[0], skip_special_tokens=True)
    return fr_text

def translate_fr_to_tum(text):
    inputs = tokenizer_fr_tum(text, return_tensors="pt", padding=True, truncation=True)
    outputs = model_fr_tum.generate(inputs["input_ids"])
    tum_text = tokenizer_fr_tum.decode(outputs[0], skip_special_tokens=True)
    return tum_text

def translate_en_to_tum(text):
    try:
        fr_text = translate_en_to_fr(text)
        tum_text = translate_fr_to_tum(fr_text)
        return jsonify({'translated_text': tum_text})
    except Exception as e:
        return jsonify({'error': str(e)}), 500

def translate_en_to_ny(text):
    inputs = tokenizer_en_ny(text, return_tensors="pt", padding=True, truncation=True)
    outputs = model_en_ny.generate(inputs["input_ids"])
    ny_text = tokenizer_en_ny.decode(outputs[0], skip_special_tokens=True)
    return ny_text

def translate_ko_to_en(text):
    inputs = tokenizer_ko_en(text, return_tensors="pt", padding=True, truncation=True)
    outputs = model_ko_en.generate(inputs["input_ids"])
    en_text = tokenizer_ko_en.decode(outputs[0], skip_special_tokens=True)
    return en_text

def translate_ny_to_en(text):
    inputs = tokenizer_ny_en(text, return_tensors="pt", padding=True, truncation=True)
    outputs = model_ny_en.generate(inputs["input_ids"])
    en_text = tokenizer_ny_en.decode(outputs[0], skip_special_tokens=True)
    return en_text

def translate_tum_to_en(text):
    inputs = tokenizer_tum_en(text, return_tensors="pt", padding=True, truncation=True)
    outputs = model_tum_en.generate(inputs["input_ids"])
    en_text = tokenizer_tum_en.decode(outputs[0], skip_special_tokens=True)
    return en_text

def translate_ko_to_ny(text):
    try:
        en_text = translate_ko_to_en(text)
        ny_text = translate_en_to_ny(en_text)
        return jsonify({'translated_text': ny_text})
    except Exception as e:
        return jsonify({'error': str(e)}), 500

def translate_ko_to_tum(text):
    try:
        en_text = translate_ko_to_en(text)
        tum_text = translate_en_to_tum(en_text)
        return jsonify({'translated_text': tum_text})
    except Exception as e:
        return jsonify({'error': str(e)}), 500

def translate_en_to_ko(text):
    inputs = tokenizer_en_ko(text, return_tensors="pt", padding=True, truncation=True)
    outputs = model_en_ko.generate(inputs["input_ids"])
    ko_text = tokenizer_en_ko.decode(outputs[0], skip_special_tokens=True)
    return ko_text

def translate_ny_to_ko(text):
    try:
        en_text = translate_ny_to_en(text)
        ko_text = translate_en_to_ko(en_text)
        return jsonify({'translated_text': ko_text})
    except Exception as e:
        return jsonify({'error': str(e)}), 500

def translate_tum_to_ko(text):
    try:
        en_text = translate_tum_to_en(text)
        ko_text = translate_en_to_ko(en_text)
        return jsonify({'translated_text': ko_text})
    except Exception as e:
        return jsonify({'error': str(e)}), 500

if __name__ == '__main__':
    app.run(host='0.0.0.0', port=5000, debug=True)
