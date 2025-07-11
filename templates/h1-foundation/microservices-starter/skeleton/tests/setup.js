// Test setup file
// This file is executed before each test file

// Set test environment variables
process.env.NODE_ENV = 'test';
process.env.PORT = '0'; // Use random port for tests
process.env.LOG_LEVEL = 'error'; // Reduce log noise during tests

// Global test timeout
jest.setTimeout(10000);

// Mock environment variables for consistent testing
process.env.AZURE_REGION = 'eastus';
process.env.AZURE_RESOURCE_GROUP = 'test-rg';
process.env.AZURE_SUBSCRIPTION_ID = 'test-subscription-id';

// Mock external dependencies if needed
jest.mock('applicationinsights', () => ({
  setup: jest.fn().mockReturnThis(),
  start: jest.fn(),
  defaultClient: {
    trackEvent: jest.fn(),
    trackException: jest.fn(),
    trackMetric: jest.fn(),
    trackTrace: jest.fn()
  }
}));

// Console spy setup for log testing
global.consoleSpy = {
  log: jest.spyOn(console, 'log').mockImplementation(() => {}),
  error: jest.spyOn(console, 'error').mockImplementation(() => {}),
  warn: jest.spyOn(console, 'warn').mockImplementation(() => {}),
  info: jest.spyOn(console, 'info').mockImplementation(() => {})
};

// Global test utilities
global.testUtils = {
  // Helper to wait for async operations
  wait: (ms) => new Promise(resolve => setTimeout(resolve, ms)),
  
  // Helper to generate test data
  generateTestData: (overrides = {}) => ({
    id: Math.random().toString(36).substring(7),
    timestamp: new Date().toISOString(),
    message: 'test message',
    ...overrides
  }),
  
  // Helper to create mock request/response objects
  createMockReq: (overrides = {}) => ({
    method: 'GET',
    url: '/test',
    headers: {},
    query: {},
    params: {},
    body: {},
    ...overrides
  }),
  
  createMockRes: () => {
    const res = {};
    res.status = jest.fn().mockReturnValue(res);
    res.json = jest.fn().mockReturnValue(res);
    res.send = jest.fn().mockReturnValue(res);
    res.set = jest.fn().mockReturnValue(res);
    res.get = jest.fn();
    return res;
  }
};

// Clean up after each test
afterEach(() => {
  // Clear all console spies
  Object.values(global.consoleSpy).forEach(spy => spy.mockClear());
  
  // Clear all mocks
  jest.clearAllMocks();
});

// Clean up after all tests
afterAll(() => {
  // Restore console methods
  Object.values(global.consoleSpy).forEach(spy => spy.mockRestore());
});
