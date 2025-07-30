#!/bin/bash

# Setup script for DataRobot Automated Testing Project
# This script sets up the environment for automated DataRobot testing using Playwright

set -e  # Exit on any error

echo "🚀 Setting up DataRobot Automated Testing Project..."
echo "=================================================="

# Check if Node.js is installed
echo "📋 Checking prerequisites..."
if ! command -v node &> /dev/null; then
    echo "❌ Node.js is not installed. Please install Node.js first."
    echo "   Visit: https://nodejs.org/"
    exit 1
fi

echo "✅ Node.js version: $(node --version)"

# Check if npm is installed
if ! command -v npm &> /dev/null; then
    echo "❌ npm is not installed. Please install npm first."
    exit 1
fi

echo "✅ npm version: $(npm --version)"

# Install dependencies
echo ""
echo "📦 Installing dependencies..."
npm install

# Install Playwright browsers
echo ""
echo "🌐 Installing Playwright browsers..."
npx playwright install

# Update package.json scripts if needed
echo ""
echo "⚙️  Updating package.json scripts..."
npm pkg set scripts.test="playwright test"
npm pkg set scripts.test:headed="playwright test --headed"
npm pkg set scripts.test:debug="playwright test --debug"
npm pkg set scripts.report="playwright show-report"

# Make run_tests.sh executable if it exists
if [ -f run_tests.sh ]; then
    chmod +x run_tests.sh
    echo "✅ Made run_tests.sh executable"
fi

# Verify test files exist
echo ""
echo "🔍 Verifying project structure..."

required_files=("sample_url.txt" "market_share_history.csv")
missing_files=()

for file in "${required_files[@]}"; do
    if [ ! -f "$file" ]; then
        missing_files+=("$file")
    else
        echo "✅ Found: $file"
    fi
done

# Check for test spec file
if [ -f "sample.spec.js" ]; then
    echo "✅ Found test file: sample.spec.js"
else
    echo "⚠️  Warning: No test spec file found (expected sample.spec.js)"
fi

# Report missing files
if [ ${#missing_files[@]} -ne 0 ]; then
    echo ""
    echo "⚠️  Warning: Missing required files:"
    for file in "${missing_files[@]}"; do
        echo "   - $file"
    done
    echo ""
    echo "   Please ensure these files are present before running tests."
fi

echo ""
echo "🎉 Setup completed successfully!"
echo ""
echo "📋 Next steps:"
echo "1. Verify your URLs in sample_url.txt"
echo "2. Ensure market_share_history.csv contains appropriate test data"
echo "3. Run tests with: ./run_tests.sh or npm test"
echo "4. View test results with: npm run report"
echo ""
echo "🔧 Available npm scripts:"
echo "   npm test           - Run tests in headless mode"
echo "   npm run test:headed - Run tests with browser UI"
echo "   npm run test:debug  - Run tests in debug mode"
echo "   npm run report      - Show test report"
