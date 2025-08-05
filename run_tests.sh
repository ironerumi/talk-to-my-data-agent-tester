#!/bin/bash
# Count the number of lines in sample_url.txt and use as workers
WORKERS=$(wc -l < sample_url.txt)
npx playwright test sample.spec.js --headed --workers=$WORKERS
# grep 'Cleanup successful.' result.txt | grep -o 'Total: [0-9]\+ms'