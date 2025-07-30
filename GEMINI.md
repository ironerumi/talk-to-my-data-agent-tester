# Gemini Code Assistant Project: Automated DataRobot Testing

This project contains an automated test script created by the Gemini Code Assistant to test a DataRobot application. The script is designed to run in parallel against multiple URLs, simulating a batch testing scenario.

## Project Structure

- `sample_url.txt`: A text file containing the URLs to be tested.
- `market_share_history.csv`: The test data used for the file upload.
- `sample.spec.js`: The main Playwright test script.
- `run_tests.sh`: A shell script to execute the test suite.
- `package.json`: The project's configuration file.

## Setup and Execution

To run the tests, follow these steps:

1. **Install Dependencies:**

   ```bash
   sh setup.sh
   ```

2. **Run the Tests:**

   ```bash
   sh run_tests.sh
   ```

## Test Script Overview

The `sample.spec.js` script performs the following actions for each URL:

1. **Navigates** to the specified URL.
2. **Uploads** the `market_share_history.csv` file using a drag-and-drop interaction.
3. **Waits** for the file to be processed.
4. **Navigates** to the "Chats" tab.
5. **Asks** a question in the chat and waits for a response.
6. **Navigates** to the "More insights" tab and interacts with the content.
7. **Records** and prints the response times for each major action.

## Key Features

- **Parallel Execution:** The tests are configured to run in parallel for each URL, providing faster feedback.
- **Reliable File Upload:** The script uses a robust drag-and-drop method to ensure consistent file uploads.
- **Dynamic Waits:** The script includes dynamic waits to handle variations in processing and response times.
- **Response Time Measurement:** The script records and logs the time taken for each critical action, allowing for performance analysis.
