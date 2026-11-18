import http from 'k6/http';
import { check } from 'k6';
export const options = {
  stages: [{ duration: '10s', target: 1000 }, { duration: '30s', target: 1000 }, { duration: '5s', target: 0 }],
  thresholds: { http_req_failed: ['rate<0.05'], http_req_duration: ['p(95)<3000'] },
};
export default function () {
  // 90% lecturas (replica) / 10% escrituras (primario)
  if (Math.random() < 0.9) {
    check(http.get('http://web/api/items'), { 'GET 200': (r) => r.status === 200 });
  } else {
    check(http.post('http://web/api/items', JSON.stringify({ nombre: 'carga k6' }),
      { headers: { 'Content-Type': 'application/json' } }), { 'POST 201': (r) => r.status === 201 });
  }
}