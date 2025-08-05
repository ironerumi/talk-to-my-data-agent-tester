#!/bin/bash

# Concurrently sends HTTP requests using configuration from request_config.env
#
# Usage:
#   ./concurrent_requests_simple.sh [CONCURRENCY] [TOTAL_REQUESTS]
#
# Arguments:
#   CONCURRENCY     - Number of requests to run in parallel. Default: 4
#   TOTAL_REQUESTS  - Total number of requests to send. Default: 10
#
# Example:
#   ./concurrent_requests_simple.sh 8 100

set -e

# --- Configuration ---
CONFIG_FILE="request_config.env"
RESULTS_FILE="request_results.csv"

# --- Argument Parsing ---
CONCURRENCY=${1:-4}
TOTAL_REQUESTS=${2:-10}

# --- Validation ---
if ! [ -f "$CONFIG_FILE" ]; then
    echo "Error: Configuration file not found at '$CONFIG_FILE'"
    echo "Please create this file with URL, headers, and data."
    exit 1
fi

if ! [[ "$CONCURRENCY" =~ ^[0-9]+$ ]] || [ "$CONCURRENCY" -lt 1 ]; then
    echo "Error: Concurrency must be a positive integer."
    exit 1
fi

if ! [[ "$TOTAL_REQUESTS" =~ ^[0-9]+$ ]] || [ "$TOTAL_REQUESTS" -lt 1 ]; then
    echo "Error: Total requests must be a positive integer."
    exit 1
fi

# --- Load Configuration ---
echo "Loading configuration from '$CONFIG_FILE'..."

# Source the config file to load variables
source "$CONFIG_FILE"

# Collect all headers into an array
HEADERS=()
for var in $(grep '^HEADER_' "$CONFIG_FILE" | cut -d= -f1); do
    header_value=$(eval echo \$$var)
    HEADERS+=("$header_value")
done

# Validate required variables
if [ -z "$URL" ] || [ -z "$DATA" ] || [ ${#HEADERS[@]} -eq 0 ]; then
    echo "Error: Missing required configuration in '$CONFIG_FILE'"
    echo "Required: URL, DATA, and at least one HEADER_*"
    exit 1
fi

echo "✅ Configuration loaded successfully"
echo "   URL: $URL"
echo "   Headers: ${#HEADERS[@]} found"
echo "   Data length: ${#DATA} characters"

# --- Main Functions ---
execute_request() {
    local request_id=$1
    local start_time
    local end_time
    local elapsed_time

    start_time=$(date +%s.%N)

    # Build curl command with headers
    local curl_headers=()
    for header in "${HEADERS[@]}"; do
        curl_headers+=("-H" "$header")
    done

    # Execute curl request
    elapsed_time=$(curl -s -w "%{time_total}" -o /dev/null \
        -X POST \
        "${curl_headers[@]}" \
        -d "$DATA" \
        "$URL")

    end_time=$(date +%s.%N)

    # Save results to CSV
    echo "$request_id,$start_time,$end_time,$elapsed_time" >> "$RESULTS_FILE"
    echo "Request #$request_id completed in $elapsed_time seconds"
}

# --- Execution ---
echo ""
echo "Starting test with concurrency=$CONCURRENCY, total requests=$TOTAL_REQUESTS"
echo "=================================================================="

# Initialize results file
echo "request_id,start_time,end_time,elapsed_time" > "$RESULTS_FILE"

# Send requests with concurrency control
for i in $(seq 1 "$TOTAL_REQUESTS"); do
    execute_request "$i" &

    # Control concurrency by waiting when we hit the limit
    if (( $(jobs -r | wc -l) >= CONCURRENCY )); then
        wait # Wait for all current jobs to complete before starting more
    fi
done

# Wait for all remaining jobs to complete
wait

echo "=================================================================="
echo "✅ All $TOTAL_REQUESTS requests completed"
echo "Results saved to '$RESULTS_FILE'"
echo ""

# --- Display Summary ---
if [ -f "$RESULTS_FILE" ]; then
    echo "--- Performance Summary ---"
    echo "First 10 results:"
    head -n 11 "$RESULTS_FILE" | column -t -s,
    
    echo ""
    echo "Statistics:"
    # Calculate min, max, average elapsed time (excluding header)
    tail -n +2 "$RESULTS_FILE" | cut -d, -f4 | awk '
    BEGIN { min=999999; max=0; sum=0; count=0 }
    { 
        if ($1 < min) min = $1
        if ($1 > max) max = $1
        sum += $1
        count++
    }
    END { 
        printf "  Min time: %.3f seconds\n", min
        printf "  Max time: %.3f seconds\n", max  
        printf "  Avg time: %.3f seconds\n", sum/count
        printf "  Total requests: %d\n", count
    }'
fi
