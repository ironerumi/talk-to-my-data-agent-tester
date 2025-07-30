#!/bin/bash

# Package script for DataRobot Automated Testing Project
# Creates a distributable zip file with all necessary files

set -e  # Exit on any error

# Configuration
PROJECT_NAME="talk-to-my-data-agent-tester"
VERSION="1.0.0"
OUTPUT_DIR="dist"
PACKAGE_NAME="${PROJECT_NAME}-v${VERSION}.zip"

echo "📦 Packaging DataRobot Automated Testing Project..."
echo "=================================================="

# Create output directory
if [ -d "$OUTPUT_DIR" ]; then
    echo "🗑️  Cleaning existing dist directory..."
    rm -rf "$OUTPUT_DIR"
fi

mkdir -p "$OUTPUT_DIR"
echo "✅ Created output directory: $OUTPUT_DIR"

# Create temporary staging directory
STAGING_DIR="$OUTPUT_DIR/staging"
mkdir -p "$STAGING_DIR"

echo ""
echo "📋 Copying essential files..."

# Define files to include in the package
ESSENTIAL_FILES=(
    "package.json"
    "package-lock.json"
    "sample.spec.js"
    "run_tests.sh"
    "setup.sh"
    "sample_url.txt"
    "market_share_history.csv"
    ".gitignore"
    "README.ja.md"
    "GEMINI.md"
)

# Copy essential files
for file in "${ESSENTIAL_FILES[@]}"; do
    if [ -f "$file" ]; then
        cp "$file" "$STAGING_DIR/"
        echo "✅ Copied: $file"
    else
        echo "⚠️  Warning: File not found: $file"
    fi
done

# Create a README for the distribution
echo ""
echo "📝 Creating distribution README..."
cat > "$STAGING_DIR/README.md" << 'EOF'
# Talk To My Data Agent Testing Project

This is a distributable package for automated DataRobot application testing using Playwright.

## Quick Start

1. **Extract the package** to your desired location
2. **Run the setup script** to install dependencies:
   ```bash
   sh setup.sh
   ```
3. **Configure your URLs** in `sample_url.txt`
4. **Run the tests**:
   ```bash
   sh run_tests.sh
   ```

## Requirements

- Node.js (v14 or higher)
- npm
- Internet connection (for downloading dependencies and Playwright browsers)

## Files Included

- `package.json` - Project dependencies and configuration
- `sample.spec.js` - Main test script
- `run_tests.sh` - Test execution script
- `setup.sh` - Environment setup script
- `sample_url.txt` - URLs to test (configure as needed)
- `market_share_history.csv` - Test data file
- `README.ja.md` - Japanese documentation
- `GEMINI.md` - Project background and details

## Support

For detailed documentation in Japanese, see `README.ja.md`.
For project background and technical details, see `GEMINI.md`.

## Version

Version: 1.0.0
Package created: $(date)
EOF

echo "✅ Created distribution README.md"


# Create the zip package
echo ""
echo "🗜️  Creating zip package..."
cd "$OUTPUT_DIR"
zip -r "$PACKAGE_NAME" staging/ > /dev/null
cd ..

# Clean up staging directory
rm -rf "$STAGING_DIR"

# Get file size
PACKAGE_SIZE=$(du -h "$OUTPUT_DIR/$PACKAGE_NAME" | cut -f1)

echo ""
echo "🎉 Package created successfully!"
echo "=============================="
echo "📁 Package: $OUTPUT_DIR/$PACKAGE_NAME"
echo "📏 Size: $PACKAGE_SIZE"
echo ""

# Show package contents
echo "📋 Package contents:"
unzip -l "$OUTPUT_DIR/$PACKAGE_NAME" | grep -E "^\s*[0-9]+" | awk '{print "   " $4}'

echo ""
echo "✨ Distribution package is ready!"
echo ""
echo "🚀 To use this package:"
echo "1. Extract $PACKAGE_NAME to a new directory"
echo "2. Run 'sh setup.sh' to install dependencies"
echo "3. Configure URLs in sample_url.txt"
echo "4. Run 'sh run_tests.sh' to execute tests"
echo ""
echo "📧 Share the file: $OUTPUT_DIR/$PACKAGE_NAME"
