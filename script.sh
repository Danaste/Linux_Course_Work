#!/bin/bash

while true; do
    echo "Choose an option:"
    echo "1. Create CSV by name"
    echo "2. Display all CSV data with row index"
    echo "3. Read user input for new row"
    echo "4. Read species and display all items + average weight"
    echo "5. Read species sex and display all items"
    echo "6. Save last output to new CSV file"
    echo "7. Delete row by row index"
    echo "8. Update weight by row index"
    echo "9. Exit"

    read -p "Enter your choice: " choice

    case $choice in
        1)
            filename="test.csv"
            if [[ -f "$filename" ]]; then
                read -p "File already exists. Overwrite? (y/n): " confirm
                if [[ "$confirm" != "y" ]]; then
                    echo "Operation canceled." | tee -a 5_output.txt
                else
                    echo "Data Collected,Specie,Sex,Weight" > "$filename"
                    echo "File '$filename' overwritten with headers." | tee -a 5_output.txt
                fi
            else
                echo "Data Collected,Specie,Sex,Weight" > "$filename"
                echo "File '$filename' created successfully." | tee -a 5_output.txt
            fi
            echo "$filename" > last_filename.txt
            ;;
        
        2)
            read -p "Enter CSV file name: " filename
            if [[ ! -f "$filename" ]]; then
                echo "Error: File '$filename' not found!" | tee -a 5_output.txt
            else
                echo "Displaying contents of $filename:" | tee -a 5_output.txt
                nl -w2 -s". " "$filename" | tee -a 5_output.txt
            fi
            ;;

        3)
            if [[ ! -f "$filename" ]]; then
                echo "Error: File '$filename' not found!" | tee -a 5_output.txt
            else
                read -p "Enter Data Collected (YYYY-MM-DD): " date
                read -p "Enter Specie: " specie
                read -p "Enter Sex (M/F): " sex
                read -p "Enter Weight: " weight

                if [[ -z "$date" || -z "$specie" || -z "$sex" || -z "$weight" ]]; then
                    echo "Error: One or more fields are empty!" | tee -a 5_output.txt
                elif ! [[ "$weight" =~ ^[0-9]+(\.[0-9]+)?$ ]]; then
                    echo "Error: Weight must be a number!" | tee -a 5_output.txt
                else
                    echo "$date,$specie,$sex,$weight" >> "$filename"
                    echo "New row added successfully to '$filename'." | tee -a 5_output.txt
                fi
            fi
            ;;

        4)
            filename=${filename:-"test.csv"}

            if [[ ! -f "$filename" ]]; then
                if [[ -f "last_filename.txt" ]]; then
                    filename=$(cat last_filename.txt)
                else
                    echo "Error: No file specified and no previous file found!" | tee -a 5_output.txt
                    exit 1
                fi
            fi

            if [[ ! -f "$filename" ]]; then
                echo "Error: File '$filename' not found!" | tee -a 5_output.txt
                exit 1
            fi

            read -p "Enter species (NA, OT, PF): " species
            if [[ "$species" != "NA" && "$species" != "OT" && "$species" != "PF" ]]; then
                echo "Error: Invalid species. Please enter NA, OT, or PF." | tee -a 5_output.txt
            else
                echo "Filtering data for species: $species" | tee -a 5_output.txt
                awk -F',' -v species="$species" 'NR==1 || $2 == species {print $0}' "$filename" | tee -a 5_output.txt
                avg_weight=$(awk -F',' -v species="$species" '$2 == species {sum+=$4; count++} END {if (count>0) print sum/count; else print "No data"}' "$filename")
                echo "Average weight for $species: $avg_weight" | tee -a 5_output.txt
            fi
            ;;
        
        5)
            read -p "Enter species (NA, OT, PF): " species
            if [[ "$species" != "NA" && "$species" != "OT" && "$species" != "PF" ]]; then
                echo "Error: Invalid species. Please enter NA, OT, or PF." | tee -a 5_output.txt
                continue
            fi

            read -p "Enter sex (M/F): " sex
            if [[ "$sex" != "M" && "$sex" != "F" ]]; then
                echo "Error: Invalid sex. Please enter M or F." | tee -a 5_output.txt
                continue
            fi

            filename="test.csv"
            if [[ ! -f "$filename" ]]; then
                echo "Error: File '$filename' not found!" | tee -a 5_output.txt
                continue
            fi

            echo "Filtering data for species: $species and sex: $sex" | tee -a 5_output.txt
            awk -F',' -v species="$species" -v sex="$sex" 'NR==1 || ($2 == species && $3 == sex) {print $0}' "$filename" | tee -a 5_output.txt
            ;;
        
        6)
            if [[ ! -s 5_output.txt ]]; then
                echo "Error: No previous output found to save!" | tee -a 5_output.txt
                continue
            fi

            output_file="last_output.csv"
            cp 5_output.txt "$output_file"

            echo "Last output saved to '$output_file' successfully!" | tee -a 5_output.txt
            ;;
        
        7)
            filename="test.csv"
            [[ ! -f "$filename" ]] && echo "Error: File not found!" | tee -a 5_output.txt && continue

            nl -ba "$filename" | tee -a 5_output.txt
            read -p "Enter row index to delete: " row_index

            [[ ! "$row_index" =~ ^[0-9]+$ ]] && echo "Error: Invalid index!" | tee -a 5_output.txt && continue
            [[ "$row_index" -lt 2 ]] && echo "Error: Cannot delete header or invalid row!" | tee -a 5_output.txt && continue

            sed -i "${row_index}d" "$filename"
            echo "Row $row_index deleted successfully!" | tee -a 5_output.txt
            ;;
        
        8)
            echo "Option 8 selected - Updating weight by index" | tee -a 5_output.txt
            filename="test.csv"

            read -p "Enter row index to update: " row_index

            if [[ ! "$row_index" =~ ^[0-9]+$ ]]; then
                echo "Error: Invalid index!" | tee -a 5_output.txt
                continue
            fi

            if [[ "$row_index" -lt 2 ]]; then
                echo "Error: Cannot update header or invalid row!" | tee -a 5_output.txt
                continue
            fi

            read -p "Enter new weight: " new_weight

            if ! [[ "$new_weight" =~ ^[0-9]+(\.[0-9]+)?$ ]]; then
                echo "Error: Weight must be a valid number!" | tee -a 5_output.txt
                continue
            fi

            awk -F',' -v row_index="$row_index" -v new_weight="$new_weight" 'BEGIN{OFS=","} 
            NR==row_index {$4=new_weight} {print $0}' "$filename" > temp.csv && mv temp.csv "$filename"

            echo "Weight updated successfully at row $row_index!" | tee -a 5_output.txt
            ;;
        
        9)
            echo "Exiting..."
            exit 0
            ;;
        
        *)
            echo "Invalid choice, try again."
            ;;
    esac
done

