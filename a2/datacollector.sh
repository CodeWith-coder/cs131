#!/bin/bash

echo "Enter the URL of the CSV dataset: " 
read url

echo
if [[ "$url" == http* ]]; then
    echo "Downloading ..."
    curl -s "$url" > csv.zip
else
    cat "$url" > csv.zip
fi
echo

echo "Unzip the ZIP file...."
unzip -o csv.zip
echo


echo "Choose the CSV file you want to analyze: "
echo "1) Red wine - winequality-red.csv"
echo "2) White wine - winequality-white.csv"
echo -n "What is your choice? (1 or 2)? " 
read chosen_wine


if [[ "$chosen_wine" == "1" ]]; then
	filename=$(unzip -Z1 csv.zip | grep 'winequality-red.csv')
elif [[ "$chosen_wine" == "2" ]]; then
	filename=$(unzip -Z1 csv.zip | grep 'winequality-white.csv')
else
    echo "Looks like you didn't choose. Let go with red wine."
    filename=$(unzip -Z1 csv.zip | grep 'winequality-red.csv')
fi

feature=$(head -n 1 "$filename" | sed 's/"//g')


echo ""
echo "## List of features for $filename: "

# Print the index and feature on console
echo "$feature" | awk -F';' '{
  for (i = 1; i <= NF; i++) {
    printf "%d. %s\n", i, $i
  }
}'


echo " " >> "summary.md"
echo "-----------------------------------------------" >> "summary.md"
echo "# Feature Summary for $filename" >> "summary.md"
echo "-----------------------------------------------" >> "summary.md"
echo " " >> "summary.md"
echo "## Feature Index and Names" >> "summary.md"


# Print the feature index and names, and save to summary.md
echo "$feature" | awk -F';' '{
  for (i = 1; i <= NF; i++) {
    printf "%d. %s\n", i, $i
  }
}' >> "summary.md"
echo "" >> "summary.md"



echo "## Statistics (Numerical Features)" >> "summary.md"
printf "| %-7s | %-22s | %-7s | %-7s | %-7s | %-7s |\n" "Index" "Feature" "Min" "Max" "Mean" "StdDev" >> "summary.md"
printf "|---------|------------------------|---------|---------|---------|---------|\n" >> "summary.md"


echo
echo "Please enter column numbers for analysis (space-separated): "
read num_cols

# Contents of table
for id in $num_cols; do
col_name=$(echo "$feature" | awk -F';' -v col="$id" '{print $col}')
    
    stats=$(tail -n +2 "$filename" | awk -F';' -v col="$id" '
    {
    current_value = $col + 0
    if (NR == 2) {
        min = current_value
        max = current_value
    } else {
        if (current_value < min) 
            min = current_value
        if (current_value > max) 
           max = current_value
    }
    total_sum += current_value
    sum_square += (current_value ^ 2)     
    total++ 
    
    }
    END {
        mean = total_sum / total
        variance = (sum_square / total) - (mean * mean) 
        stddev = sqrt(variance)
        printf "%.3f %.3f %.3f %.3f", min, max, mean, stddev
    }' "$filename")

    echo "$stats" | while read -r min max mean stddev; do
    printf "| %-7s | %-22s | %-7s | %-7s | %-7s | %-7s |\n"  "$id" "$col_name" "$min" "$max" "$mean" "$stddev" >> "summary.md"
    done
done

echo "============================================================================ " >> "summary.md"
echo
echo "The result is saved to summary.md"


