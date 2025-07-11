#!/usr/bin/env node

const chalk = require('chalk');
const { execSync } = require('child_process');
const fs = require('fs');
const path = require('path');

console.log(chalk.blue.bold('🚀 Three Horizons AI Platform - DevBox Setup'));
console.log(chalk.gray('Setting up your development environment...\n'));

// Check if we're in a devcontainer
const isDevContainer = process.env.THREE_HORIZONS_ENV === 'devbox';

if (!isDevContainer) {
    console.log(chalk.yellow('⚠️  This script is designed to run inside a DevBox container'));
    console.log(chalk.gray('Consider running this in VS Code with the DevContainer extension\n'));
}

// Environment setup
console.log(chalk.green('📋 Environment Configuration'));

// Check for required environment variables
const requiredEnvVars = [
    'AZURE_SUBSCRIPTION_ID',
    'DEVELOPER_NAME',
    'TEAM',
    'GITHUB_TOKEN'
];

const missingVars = requiredEnvVars.filter(varName => !process.env[varName]);

if (missingVars.length > 0) {
    console.log(chalk.red('❌ Missing required environment variables:'));
    missingVars.forEach(varName => {
        console.log(chalk.red(`   - ${varName}`));
    });
    console.log(chalk.yellow('\n💡 Please set these variables in your .env file or environment\n'));
} else {
    console.log(chalk.green('✅ All required environment variables are set'));
}

// Create .env file if it doesn't exist
const envPath = path.join(process.cwd(), '.env');
const envTemplatePath = path.join(process.cwd(), '.env.template');

if (!fs.existsSync(envPath) && fs.existsSync(envTemplatePath)) {
    console.log(chalk.yellow('📝 Creating .env file from template...'));
    fs.copyFileSync(envTemplatePath, envPath);
    console.log(chalk.green('✅ .env file created. Please update with your values.'));
}

// Check tool availability
console.log(chalk.green('\n🔧 Tool Verification'));

const tools = [
    { name: 'Azure CLI', command: 'az --version' },
    { name: 'kubectl', command: 'kubectl version --client' },
    { name: 'Docker', command: 'docker --version' },
    { name: 'GitHub CLI', command: 'gh --version' },
    { name: 'Node.js', command: 'node --version' },
    { name: 'Python', command: 'python3 --version' },
    { name: 'Git', command: 'git --version' }
];

tools.forEach(tool => {
    try {
        execSync(tool.command, { stdio: 'ignore' });
        console.log(chalk.green(`✅ ${tool.name} is available`));
    } catch (error) {
        console.log(chalk.red(`❌ ${tool.name} is not available`));
    }
});

// Check authentication status
console.log(chalk.green('\n🔐 Authentication Status'));

// Azure CLI
try {
    execSync('az account show', { stdio: 'ignore' });
    const account = execSync('az account show --query name -o tsv', { encoding: 'utf8' }).trim();
    console.log(chalk.green(`✅ Azure CLI authenticated (${account})`));
} catch (error) {
    console.log(chalk.yellow('⚠️  Azure CLI not authenticated. Run: npm run azure:login'));
}

// GitHub CLI
try {
    execSync('gh auth status', { stdio: 'ignore' });
    console.log(chalk.green('✅ GitHub CLI authenticated'));
} catch (error) {
    console.log(chalk.yellow('⚠️  GitHub CLI not authenticated. Run: gh auth login'));
}

// Kubernetes
try {
    execSync('kubectl cluster-info', { stdio: 'ignore' });
    const context = execSync('kubectl config current-context', { encoding: 'utf8' }).trim();
    console.log(chalk.green(`✅ Kubernetes connected (${context})`));
} catch (error) {
    console.log(chalk.yellow('⚠️  Kubernetes not configured. Set up cluster access.'));
}

// Create workspace directories
console.log(chalk.green('\n📁 Workspace Setup'));

const directories = [
    'playground',
    'projects', 
    'scripts',
    'docs',
    'temp'
];

directories.forEach(dir => {
    const dirPath = path.join(process.cwd(), dir);
    if (!fs.existsSync(dirPath)) {
        fs.mkdirSync(dirPath, { recursive: true });
        console.log(chalk.green(`✅ Created directory: ${dir}`));
    } else {
        console.log(chalk.gray(`📁 Directory exists: ${dir}`));
    }
});

// Final instructions
console.log(chalk.blue.bold('\n🎉 Setup Complete!'));
console.log(chalk.gray('Your Three Horizons AI DevBox is ready for development.\n'));

console.log(chalk.yellow('Next Steps:'));
console.log(chalk.gray('1. Review and update your .env file with your specific values'));
console.log(chalk.gray('2. Authenticate with Azure: npm run azure:login'));
console.log(chalk.gray('3. Authenticate with GitHub: gh auth login'));
console.log(chalk.gray('4. Set up Kubernetes access to your AKS cluster'));
console.log(chalk.gray('5. Start developing with H1, H2, or H3 templates\n'));

console.log(chalk.blue('Useful Commands:'));
console.log(chalk.gray('• three-horizons-help - View comprehensive development guide'));
console.log(chalk.gray('• h1 / h2 / h3 - Navigate to horizon templates'));
console.log(chalk.gray('• npm run azure:status - Check Azure authentication'));
console.log(chalk.gray('• npm run k8s:status - Check Kubernetes connection'));
console.log(chalk.gray('• npm run github:status - Check GitHub authentication\n'));

console.log(chalk.green('Happy coding! 🚀'));
