import hashlib
import sys
import requests
import json

m = hashlib.sha1()
m.update(sys.argv[2])
m.update(sys.argv[1])
m.update(sys.argv[3])
out = m.hexdigest()

#print sys.argv[2]

url = "http://nanowrimo.org/api/wordcount"
payload = {'hash': out, 'name': sys.argv[1], 'wordcount': sys.argv[3]}
print payload

r = requests.put(url, data=payload)
print r.status_code
print r.content
