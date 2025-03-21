import http from 'k6/http';
import { sleep, check } from 'k6';

export const options = {
    stages: [
        { duration: '30s', target: 5 },
        { duration: '30s', target: 5 },
        { duration: '30s', target: 0 },
    ],
};

export default () => {
    const res = http.get('http://test.k6.io');
    sleep(1);
    check(res, {
        'is status 200': (r) => r.status === 200,
    });
};