import http from 'k6/http';
import { check } from 'k6';
export const options = {
  stages: [{ duration: '10s', target: 1000 }, { duration: '30s', target: 1000 }, { duration: '5s', target: 0 }],
};
export default function () {
  check(http.get('http://web/descarga.bin'), { 'status 200': (r) => r.status === 200 });
}