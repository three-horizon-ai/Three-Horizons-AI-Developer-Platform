const request = require('supertest');
const app = require('../src/app');

describe('Health Endpoints', () => {
  let server;

  beforeAll((done) => {
    server = app.listen(0, done);
  });

  afterAll((done) => {
    server.close(done);
  });

  describe('GET /health', () => {
    it('should return 200 and health status', async () => {
      const response = await request(server)
        .get('/health')
        .expect('Content-Type', /json/)
        .expect(200);

      expect(response.body).toHaveProperty('status', 'healthy');
      expect(response.body).toHaveProperty('timestamp');
      expect(response.body).toHaveProperty('uptime');
      expect(response.body).toHaveProperty('version');
      expect(response.body).toHaveProperty('environment');
    });
  });

  describe('GET /ready', () => {
    it('should return 200 and readiness status', async () => {
      const response = await request(server)
        .get('/ready')
        .expect('Content-Type', /json/)
        .expect(200);

      expect(response.body).toHaveProperty('status', 'ready');
      expect(response.body).toHaveProperty('checks');
      expect(response.body.checks).toHaveProperty('database');
      expect(response.body.checks).toHaveProperty('cache');
      expect(response.body.checks).toHaveProperty('external_services');
    });
  });
});

describe('API Endpoints', () => {
  let server;

  beforeAll((done) => {
    server = app.listen(0, done);
  });

  afterAll((done) => {
    server.close(done);
  });

  describe('GET /api/v1/hello', () => {
    it('should return 200 and hello message', async () => {
      const response = await request(server)
        .get('/api/v1/hello')
        .expect('Content-Type', /json/)
        .expect(200);

      expect(response.body).toHaveProperty('message', 'Hello from ${{ values.component_id }}!');
      expect(response.body).toHaveProperty('timestamp');
      expect(response.body).toHaveProperty('version');
    });
  });

  describe('GET /api/v1/hello/:name', () => {
    it('should return personalized greeting', async () => {
      const name = 'Alice';
      const response = await request(server)
        .get(`/api/v1/hello/${name}`)
        .expect('Content-Type', /json/)
        .expect(200);

      expect(response.body).toHaveProperty('message', `Hello, ${name}!`);
      expect(response.body).toHaveProperty('name', name);
      expect(response.body).toHaveProperty('timestamp');
    });

    it('should sanitize special characters in name', async () => {
      const name = '<script>alert("xss")</script>';
      const response = await request(server)
        .get(`/api/v1/hello/${encodeURIComponent(name)}`)
        .expect('Content-Type', /json/)
        .expect(200);

      expect(response.body.name).not.toContain('<script>');
      expect(response.body.name).not.toContain('</script>');
    });
  });

  describe('POST /api/v1/echo', () => {
    it('should echo back the request body', async () => {
      const testData = { message: 'test message', data: [1, 2, 3] };
      
      const response = await request(server)
        .post('/api/v1/echo')
        .send(testData)
        .expect('Content-Type', /json/)
        .expect(200);

      expect(response.body).toHaveProperty('echo', testData);
      expect(response.body).toHaveProperty('timestamp');
      expect(response.body).toHaveProperty('received_at');
    });

    it('should handle empty request body', async () => {
      const response = await request(server)
        .post('/api/v1/echo')
        .send({})
        .expect('Content-Type', /json/)
        .expect(200);

      expect(response.body).toHaveProperty('echo', {});
    });

    it('should validate request body size limits', async () => {
      const largeData = { data: 'x'.repeat(11 * 1024 * 1024) }; // 11MB
      
      await request(server)
        .post('/api/v1/echo')
        .send(largeData)
        .expect(413);
    });
  });
});

describe('Error Handling', () => {
  let server;

  beforeAll((done) => {
    server = app.listen(0, done);
  });

  afterAll((done) => {
    server.close(done);
  });

  describe('404 Errors', () => {
    it('should return 404 for non-existent routes', async () => {
      const response = await request(server)
        .get('/api/v1/nonexistent')
        .expect('Content-Type', /json/)
        .expect(404);

      expect(response.body).toHaveProperty('error', 'Not Found');
      expect(response.body).toHaveProperty('message');
      expect(response.body).toHaveProperty('path', '/api/v1/nonexistent');
    });
  });

  describe('Method Not Allowed', () => {
    it('should return 405 for unsupported methods', async () => {
      await request(server)
        .delete('/api/v1/hello')
        .expect(405);
    });
  });

  describe('Rate Limiting', () => {
    it('should enforce rate limits', async () => {
      // Make multiple requests to trigger rate limit
      const requests = Array.from({ length: 105 }, () => 
        request(server).get('/api/v1/hello')
      );

      const responses = await Promise.all(requests);
      const rateLimitedResponses = responses.filter(res => res.status === 429);
      
      expect(rateLimitedResponses.length).toBeGreaterThan(0);
    }, 10000);
  });
});

describe('Security Headers', () => {
  let server;

  beforeAll((done) => {
    server = app.listen(0, done);
  });

  afterAll((done) => {
    server.close(done);
  });

  it('should include security headers', async () => {
    const response = await request(server)
      .get('/health')
      .expect(200);

    expect(response.headers).toHaveProperty('x-content-type-options', 'nosniff');
    expect(response.headers).toHaveProperty('x-frame-options', 'DENY');
    expect(response.headers).toHaveProperty('x-xss-protection', '1; mode=block');
    expect(response.headers).toHaveProperty('strict-transport-security');
  });
});

describe('CORS', () => {
  let server;

  beforeAll((done) => {
    server = app.listen(0, done);
  });

  afterAll((done) => {
    server.close(done);
  });

  it('should handle CORS preflight requests', async () => {
    const response = await request(server)
      .options('/api/v1/hello')
      .set('Origin', 'https://example.com')
      .set('Access-Control-Request-Method', 'GET')
      .expect(200);

    expect(response.headers).toHaveProperty('access-control-allow-origin');
    expect(response.headers).toHaveProperty('access-control-allow-methods');
  });
});
