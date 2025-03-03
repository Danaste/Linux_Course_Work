#!/bin/bash

CSV_FILE="bugs.csv"

if [ ! -f "$CSV_FILE" ]; then
  echo "Error: CSV file not found in the current directory. Ensure the $CSV_FILE file is located in the same directory as the script."
  exit 1
fi

BRANCH_NAME=$(git symbolic-ref --short HEAD)

TASK=$(grep "$BRANCH_NAME" "$CSV_FILE")
if [ -z "$TASK" ]; then
  echo "No task found for branch $BRANCH_NAME in the CSV file."
  exit 1
fi

BUG_ID=$(echo "$TASK" | cut -d',' -f1)
DEV_NAME=$(echo "$TASK" | cut -d',' -f3)
PRIORITY=$(echo "$TASK" | cut -d',' -f4)
DESCRIPTION=$(echo "$TASK" | cut -d',' -f5)

DEV_DESCRIPTION=$1

CURRENT_TIME=$(date +"%Y-%m-%d %H:%M:%S")

if [ -z "$DEV_DESCRIPTION" ]; then
  COMMIT_MESSAGE="BugID:$BUG_ID:$CURRENT_TIME:$BRANCH_NAME:$DEV_NAME:$PRIORITY:$DESCRIPTION"
else
  COMMIT_MESSAGE="BugID:$BUG_ID:$CURRENT_TIME:$BRANCH_NAME:$DEV_NAME:$PRIORITY:$DESCRIPTION:$DEV_DESCRIPTION"
fi

git add .

git commit -m "$COMMIT_MESSAGE"
if [ $? -ne 0 ]; then
  echo "Error during commit."
  exit 1
fi

git push
if [ $? -ne 0 ]; then
  echo "Error during push."
  exit 1
fi

git log --oneline > commits.txt
echo "The script ran successfully. Commits are saved in commits.txt."

