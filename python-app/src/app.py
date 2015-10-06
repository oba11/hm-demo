import socket

from flask import Flask
from flask import render_template

app = Flask(__name__)

def get_ip_address():
    ip_addr = socket.gethostbyname(socket.gethostname())
    return ip_addr

@app.route('/')
def index():
    data = {}
    data["hostname"] = socket.gethostname()
    data["ip_addr"] = get_ip_address()
    return render_template('index.html', data=data)

if __name__ == '__main__':
    app.run(host='0.0.0.0', port=8080)
