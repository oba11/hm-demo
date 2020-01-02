import socket
import os
import urllib.request
import time
from flask import Flask, request
import json

app = Flask(__name__)

@app.route('/')
def index():
  start_time = time.time()
  data = {}
  hostname = socket.gethostname()
  service_name = os.getenv('SERVICE_NAME', hostname)
  upstream_uri = os.getenv('UPSTREAM_URI', 'http://time.jsontest.com')

  headers = forward_headers(request.headers)
  # print(headers, flush=True)
  req = urllib.request.Request(upstream_uri, headers=headers)
  resp = urllib.request.urlopen(req)

  output = f'''
  {service_name}/{hostname} - {round(time.time() - start_time)}secs<br/>
  {upstream_uri} -> {resp.read().decode('utf-8')}
  '''
  return output

def forward_headers(headers):
  incoming_headers = [
    'x-request-id',
    'x-b3-traceid',
    'x-b3-spanid',
    'x-b3-parentspanid',
    'x-b3-sampled',
    'x-b3-flags',
    'b3',
    'x-ot-span-context'
  ]
  output = {}
  for h in incoming_headers:
    if headers.get(h):
      val = headers[h]
      if h == 'x-b3-sampled' and _convert(val) == 0:
        output[h] = 1
      else:
        output[h] = val
  return output

def _convert(obj):
  try:
    return json.loads(obj)
  except json.decoder.JSONDecodeError:
    return obj

if __name__ == '__main__':
  app.run(host='0.0.0.0', port=80)
