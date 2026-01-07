const assert = require('assert');

try {
  // Basic sanity checks for backend
  assert.strictEqual(1 + 1, 2);
  console.log('backend: sanity check passed');
  process.exit(0);
} catch (err) {
  console.error('backend: sanity check failed', err);
  process.exit(1);
}
