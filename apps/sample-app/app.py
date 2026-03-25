from flask import Flask

app = Flask(__name__)

@app.route("/")
def hello():
    return "Hello from Platform Engineering Project 2 🚀"

@app.route("/health")
def health():
    return {"status": "ok"}, 200