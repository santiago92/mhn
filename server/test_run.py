from gevent.wsgi import WSGIServer
from mhn import mhn
mhn.run(debug=True, host='0.0.0.0', port=5000)
http_server = WSGIServer(('', 5000), mhn)
http_server.serve_forever()