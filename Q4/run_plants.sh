#!/bin/bash

if [ -z "$1" ]; then
  echo "Please provide the path to the CSV file!"
  exit 1
fi

CSV_FILE="$1"

while IFS=, read -r plant height leaf_count dry_weight
do
  if [ "$plant" != "plant" ] && [ ! -z "$plant" ]; then
    echo "Processing plant: $plant"
    mkdir -p "4_1/$plant"
    
    if [ -f "4_1/${plant}_histogram.png" ]; then
      mv "4_1/${plant}_histogram.png" "4_1/$plant/"
    fi
    
    if [ -f "4_1/${plant}_line_plot.png" ]; then
      mv "4_1/${plant}_line_plot.png" "4_1/$plant/"
    fi
    
    if [ -f "4_1/${plant}_scatter_plot.png" ]; then
      mv "4_1/${plant}_scatter_plot.png" "4_1/$plant/"
    fi
    
    echo "Images for $plant saved to 4_1/$plant/"
  fi
done < "$CSV_FILE"

echo "Script finished."

