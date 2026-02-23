const request = require('supertest');
const app = require('../app'); 

describe('Pipeline Quality Gate', () => {
    it('should pass the health check route', async () => {
        const response = await request(app).get('/api/health');
        
        expect(response.statusCode).toBe(200);
        expect(response.body.status).toBe('success');
    });
});