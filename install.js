#!/usr/bin/env node

const { execSync } = require('child_process');
const path = require('path');

const scriptPath = path.join(__dirname, 'scripts', 'base-install.sh');

try {
  console.log('Running Agent OS installation...\n');
  execSync(`bash ${scriptPath}`, { stdio: 'inherit', cwd: __dirname });
} catch (error) {
  console.error('Installation failed:', error.message);
  process.exit(1);
}
