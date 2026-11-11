"""Smoke test against the three running applications, through gateway only.
Run: python verify-api.py [http://localhost:8080]
Creates a dedicated car/renting. The rented car remains as verification evidence.
"""
import json
import sys
from urllib.request import Request, urlopen
from urllib.error import HTTPError
from uuid import uuid4

base = sys.argv[1].rstrip('/') if len(sys.argv) > 1 else 'http://localhost:8080'
checks = 0

def call(method, path, expected, body=None):
    global checks
    data = json.dumps(body).encode() if body is not None else None
    request = Request(base + path, data=data, method=method,
                      headers={'Content-Type': 'application/json', 'X-Test': 'gateway-smoke'})
    try:
        response = urlopen(request, timeout=15)
    except HTTPError as error:
        response = error
    with response:
        raw = response.read()
        assert response.status == expected, (method, path, response.status, raw)
        checks += 1
        return json.loads(raw) if raw else None

def error(method, path, code, message, body=None):
    assert call(method, path, code, body) == {'error': message}

car = dict(carName='Smoke-' + uuid4().hex[:8], model='Test model', color='Red',
           pricePerDay=1500000, status='Available')
error('POST', '/api/cars', 400, 'Invalid data', {})
error('POST', '/api/cars', 400, 'Invalid data', dict(car, pricePerDay=0))
created = call('POST', '/api/cars', 201, car)
assert set(created) == {'carId', *car.keys()}
car_id = created['carId']
path = f'/api/cars/{car_id}'
assert call('GET', path, 200) == created
assert any(c['carId'] == car_id for c in call('GET', '/api/cars', 200))
updated = call('PUT', path, 200, dict(car, color='Blue'))
assert updated['color'] == 'Blue'
renting = dict(customerId='SMOKE-TEST', carId=car_id,
               rentStartDate='2026-10-15', rentEndDate='2026-10-17')
before = len(call('GET', '/api/rentings', 200))
error('POST', '/api/rentings', 400, 'Invalid data', {})
error('POST', '/api/rentings', 400, 'Invalid data', dict(renting, rentEndDate='2026-10-15'))
error('POST', '/api/rentings', 404, 'Car not found', dict(renting, carId=2147483647))
assert len(call('GET', '/api/rentings', 200)) == before
result = call('POST', '/api/rentings', 201, renting)
assert set(result) == {'rentingId', 'customerId', 'carId', 'carName', 'carModel',
                       'rentStartDate', 'rentEndDate', 'totalPrice'}
assert result['totalPrice'] == 3000000
assert result['carName'] == car['carName'] and result['carModel'] == car['model']
assert call('GET', path, 200)['status'] == 'Rented'
error('POST', '/api/rentings', 409, 'Car is rented', renting)
error('DELETE', path, 409, 'Car is rented')
assert len(call('GET', '/api/rentings', 200)) == before + 1
disposable = call('POST', '/api/cars', 201, car)['carId']
assert call('DELETE', f'/api/cars/{disposable}', 204) is None
error('GET', f'/api/cars/{disposable}', 404, 'Car not found')
call('GET', '/api/unknown', 404)
call('POST', f'/internal/cars/{car_id}/reserve', 404)
print(f'PASS: {checks} HTTP checks through {base}. Rented evidence carId={car_id}, rentingId={result["rentingId"]}.')
