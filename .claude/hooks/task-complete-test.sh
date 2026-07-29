#!/bin/bash
# Runs npm test before a task can be marked completed.
# Configured as a TaskCompleted hook. Exit 2 blocks completion.

echo "Running tests before completing task..." >&2
npm test 2>&1
TEST_EXIT=$?

if [ $TEST_EXIT -ne 0 ]; then
  echo "Tests failed. Fix failing tests before marking task complete." >&2
  exit 2
fi

exit 0
