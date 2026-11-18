import http from 'k6/http';
import { check } from 'k6';
export const options = {
  stages: [{ duration: '10s', target: 1000 }, { duration: '30s', target: 1000 }, { duration: '5s', target: 0 }],
  thresholds: { http_req_failed: ['rate<0.05'], http_req_duration: ['p(95)<2000'] },
};
export default function () {
  const r = http.get('http://web/');
  check(r, { 'status 200': (x) => x.status === 200 });
}