const request = require('supertest');
const app = require('../src/app');

describe('Integration Tests', () => {
  let server;

  beforeAll((done) => {
    server = app.listen(0, done);
  });

  afterAll((done) => {
    server.close(done);
  });

  describe('Application Lifecycle', () => {
    it('should start and respond to health checks', async () => {
      // Test that the application starts successfully
      const healthResponse = await request(server)
        .get('/health')
        .expect(200);

      expect(healthResponse.body.status).toBe('healthy');

      // Test readiness endpoint
      const readyResponse = await request(server)
        .get('/ready')
        .expect(200);

      expect(readyResponse.body.status).toBe('ready');
    });

    it('should handle graceful shutdown', async () => {
      // This test simulates graceful shutdown behavior
      const response = await request(server)
        .get('/health')
        .expect(200);

      expect(response.body.status).toBe('healthy');
      
      // In a real scenario, you would test SIGTERM handling
      // For now, we just verify the app is responsive
    });
  });

  describe('API Integration Flow', () => {
    it('should handle complete API workflow', async () => {
      // Step 1: Get hello message
      const helloResponse = await request(server)
        .get('/api/v1/hello')
        .expect(200);

      expect(helloResponse.body.message).toBe('Hello from ${{ values.component_id }}!');

      // Step 2: Echo data
      const echoData = {
        message: 'Integration test',
        timestamp: new Date().toISOString(),
        data: { test: true }
      };

      const echoResponse = await request(server)
        .post('/api/v1/echo')
        .send(echoData)
        .expect(200);

      expect(echoResponse.body.echo).toEqual(echoData);

      // Step 3: Personalized greeting
      const name = 'IntegrationTest';
      const greetResponse = await request(server)
        .get(`/api/v1/hello/${name}`)
        .expect(200);

      expect(greetResponse.body.name).toBe(name);
      expect(greetResponse.body.message).toBe(`Hello, ${name}!`);
    });
  });

  describe('Metrics Integration', () => {
    it('should expose Prometheus metrics', async () => {
      // Make some requests to generate metrics
      await request(server).get('/api/v1/hello').expect(200);
      await request(server).post('/api/v1/echo').send({ test: true }).expect(200);
      await request(server).get('/health').expect(200);

      // Check metrics endpoint
      const metricsResponse = await request(server)
        .get('/metrics')
        .expect(200);

      expect(metricsResponse.text).toContain('http_requests_total');
      expect(metricsResponse.text).toContain('http_request_duration_seconds');
      expect(metricsResponse.text).toContain('nodejs_');
      expect(metricsResponse.text).toContain('process_');
    });

    it('should track custom metrics', async () => {
      // Make requests to tracked endpoints
      await request(server).get('/api/v1/hello').expect(200);
      await request(server).get('/api/v1/hello/testuser').expect(200);

      const metricsResponse = await request(server)
        .get('/metrics')
        .expect(200);

      // Verify custom metrics are present
      expect(metricsResponse.text).toContain('api_requests_total');
      expect(metricsResponse.text).toContain('method="GET"');
      expect(metricsResponse.text).toContain('status_code="200"');
    });
  });

  describe('Error Handling Integration', () => {
    it('should handle and track errors properly', async () => {
      // Test 404 error
      const notFoundResponse = await request(server)
        .get('/api/v1/nonexistent')
        .expect(404);

      expect(notFoundResponse.body.error).toBe('Not Found');

      // Test method not allowed
      await request(server)
        .delete('/api/v1/hello')
        .expect(405);

      // Check that errors are tracked in metrics
      const metricsResponse = await request(server)
        .get('/metrics')
        .expect(200);

      expect(metricsResponse.text).toContain('status_code="404"');
      expect(metricsResponse.text).toContain('status_code="405"');
    });
  });

  describe('Performance Integration', () => {
    it('should handle concurrent requests', async () => {
      const concurrentRequests = 50;
      const requests = Array.from({ length: concurrentRequests }, (_, i) => 
        request(server)
          .get('/api/v1/hello')
          .expect(200)
      );

      const startTime = Date.now();
      const responses = await Promise.all(requests);
      const endTime = Date.now();

      // All requests should succeed
      expect(responses).toHaveLength(concurrentRequests);
      responses.forEach(response => {
        expect(response.status).toBe(200);
        expect(response.body.message).toBe('Hello from ${{ values.component_id }}!');
      });

      // Performance should be reasonable (adjust threshold as needed)
      const totalTime = endTime - startTime;
      expect(totalTime).toBeLessThan(5000); // 5 seconds for 50 requests
    }, 10000);

    it('should maintain response times under load', async () => {
      const numberOfRequests = 100;
      const responseTimes = [];

      for (let i = 0; i < numberOfRequests; i++) {
        const startTime = Date.now();
        await request(server)
          .get('/api/v1/hello')
          .expect(200);
        const endTime = Date.now();
        responseTimes.push(endTime - startTime);
      }

      const averageResponseTime = responseTimes.reduce((a, b) => a + b, 0) / responseTimes.length;
      const maxResponseTime = Math.max(...responseTimes);

      // Response times should be reasonable
      expect(averageResponseTime).toBeLessThan(100); // 100ms average
      expect(maxResponseTime).toBeLessThan(500); // 500ms max
    }, 30000);
  });

  describe('Security Integration', () => {
    it('should validate input sanitization', async () => {
      const maliciousInputs = [
        '<script>alert("xss")</script>',
        '"; DROP TABLE users; --',
        '../../../etc/passwd',
        'javascript:alert("xss")',
        '<img src="x" onerror="alert(\'xss\')">'
      ];

      for (const input of maliciousInputs) {
        const response = await request(server)
          .get(`/api/v1/hello/${encodeURIComponent(input)}`)
          .expect(200);

        // Verify that malicious input is sanitized
        expect(response.body.name).not.toContain('<script>');
        expect(response.body.name).not.toContain('javascript:');
        expect(response.body.name).not.toContain('DROP TABLE');
        expect(response.body.name).not.toContain('../');
      }
    });

    it('should enforce content type restrictions', async () => {
      // Test with invalid content type
      await request(server)
        .post('/api/v1/echo')
        .set('Content-Type', 'text/plain')
        .send('plain text')
        .expect(400);

      // Test with valid JSON content type
      await request(server)
        .post('/api/v1/echo')
        .set('Content-Type', 'application/json')
        .send('{"valid": "json"}')
        .expect(200);
    });
  });

  describe('Logging Integration', () => {
    it('should log requests and responses', async () => {
      // Capture console output (in a real test, you might use a proper logger mock)
      const originalLog = console.log;
      const logs = [];
      console.log = (...args) => logs.push(args.join(' '));

      try {
        await request(server)
          .get('/api/v1/hello')
          .expect(200);

        await request(server)
          .post('/api/v1/echo')
          .send({ test: 'data' })
          .expect(200);

        // Verify that logs contain request information
        const logString = logs.join('\n');
        expect(logString).toContain('GET');
        expect(logString).toContain('POST');
        expect(logString).toContain('/api/v1/hello');
        expect(logString).toContain('/api/v1/echo');
      } finally {
        console.log = originalLog;
      }
    });
  });
});
