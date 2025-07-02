# Script for Analyzing Data and Creating a Summary

This Mini project presents a Bash shell script that streamlines the process of downloading, extracting, and summarizing CSV datasets in tabular form. Developed with UCI Machine Learning Repository datasets, it allows users to input the URL of their dataset, choose numeric features, and generate a summary file. 

This file includes a list of attributes along with basic statistics (minimum, maximum, mean, standard deviation) for the chosen numerical columns. To ensure compatibility and ease-of-use, this tool uses commonly found Unix utilities such as awk, sed, and other significant commands.

<br>

## CSV Dataset

The utilized dataset at this URL: https://archive.ics.uci.edu/static/public/186/wine+quality.zip

The data sourced from the UCI Machine Learning Repository, which is known for offering an array of datasets suitable for machine learning tasks and predictive analytics.

<br>

## This script performs several actions:

- It prompts the user to enter a URL that links to a ZIP file containing one or more CSV files.
- The script then downloads the file and, if necessary, extracts it.
- Lists the feature (column) names with index numbers.
- The script prompts the user to input column index numbers for numerical columns.
- Using the `awk` command, it calculates statistical summaries such as Minimum, Maximum, Mean, and Standard Deviation.
- Finally, it saves the results in a file named `summary.md`.

<br>

## Bash Script for Processing and Summarizing CSV Files (datacollector.sh)

* **Ask user to provide the URL of the CSV dataset** 

```bash
echo "Enter the URL of the CSV dataset: " 
read url
```
`echo` showing the prompt to ask user.

`read` capture the URL provided from the user.

* *Execution Result*
```bash
Enter the URL of the CSV dataset: 
https://archive.ics.uci.edu/static/public/186/wine+quality.zip
```

<br><br>

* **Check the variable url is valid and download the file** 

```bash
if [[ "$url" == http* ]]; then
    echo "Downloading ..."  
    curl -s "$url" > csv.zip
else
    cat "$url" > csv.zip
fi
```
If url does start with “http”, it downloads process using the command tool `url`.

And it saves the content at the provided URL into a file named ‘csv.zip’ (curl -s "$url" > csv.zip). 

The `-s` tells curl to silence the progress. Otherwise, it copies its contents directly into a new file `csv.zip`.

* *Execution Result*
```bash
Downloading ...

Unzip the ZIP file....
Archive:  csv.zip
  inflating: winequality-red.csv     
  inflating: winequality-white.csv   
  inflating: winequality.names
```



<br><br>

* **Ask user to choose the specific CSV file by selecting 1 (Red wine) or 2 (White wine)** 
```bash
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
```
 A conditional statement that decides which CSV file from the unzipped archive to assign to the variable ‘filename’, based on the value of the variable `chosen_wine`.
 
 `unzip -Z1 csv.zip` The output of the unzip command to extracts files from a zip.

 `-Z1` To list the contents of zip file in simple format.
 
 `grep 'winequality-red.csv'` The grep command to search for specific filenames within the extracted files.
 
 Otherwise, the program will choose the csv file - winequality-red.csv automatically if the user doesn't offer the choice.

 * *Execution Result*
```bash
Choose the CSV file you want to analyze: 
1) Red wine - winequality-red.csv
2) White wine - winequality-white.csv
What is your choice? (1 or 2)? 1
```

<br><br>

* **Extracting feature names from the CSV file**

```bash
feature = $(head -n 1 “$filename” | sed ‘s/"//g’)
```
`head -n 1 "$filename"`  Prints the first line of CSV file of the contents found in the file. 

`sed 's/"//g'`  Use `sed` (stream editor) command to remove all double quotes from that single line.

Then, assign the result to the variable "feature".



<br><br>


* **Display the index number and features present within selected CSV file**
```bash
echo "## List of features for $filename: "
echo "$feature" | awk -F';' '{
  for (i = 1; i <= NF; i++) {
    printf "%d. %s\n", i, $i
  }
}'
```
`echo "$feature"`  Prints the contents of variable `feature`.

`| awk -F ';' ` Connect with pipe, which pass the previous output and use awk to use `;` as field separator. 

`NF` is awk built-in variable, which number of field in the current record. 

`printf "%d. %s\n", i, $i` Repeat each field in the row and print out its index number along with its corresponding name `$i`

 * *Execution Result*
```bash
## List of features for winequality-red.csv: 
1. fixed acidity
2. volatile acidity
3. citric acid
4. residual sugar
5. chlorides
6. free sulfur dioxide
7. total sulfur dioxide
8. density
9. pH
10. sulphates
11. alcohol
12. quality
```

<br><br>

* **Require the user to enter index number for further analysis** 

```bash
echo "Please enter column numbers for analysis (space-separated): "
read num_cols
```
Ask the user for input the number of column, and save it in a variable called num_cols.

 * *Execution Result*
```bash
Please enter column numbers for analysis (space-separated): 
1 2 3 4 5 6 7 8 9 10 11 12
```

<br><br>



* **Further analysis based on the user's request** 

```bash
for id in $num_cols; do
col_name=$(echo "$feature" | awk -F';' -v col="$id" '{print $col}')
```
To print out the name of each column in the $feature string for each value in $num_cols. 

Ex: 1. fixed acidity    2. volatile acidity.

For loop to iterate over the values in the variable "num_cols" and assign them to id.

`echo "$feature"`  To retrieve the name of the $feature by echo command.

`-F';'`  To split the input string on semicolons. 

`-v col="$id"`  To pass in the current value of id to variable "col".

`{print $col}`  (instructs) awk to display the column with that name from the feature.


<br><br>

* **Computing statistical information on columns of data by using awk**

```bash
 stats=$(tail -n +2 "$filename" | awk -F';' -v col="$id" ' {   }
```
To capture data begining from line 2 of a file named $filename, and calculate various for the column indicated by $id.


```bash
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
```
<br>

* **The mainb block {...} repeats for each row of data and keeps track of finding the minimum and maximum values within the dataset with awk operation**

`NR == 2` is second line.

`if (NR == 2)` To check if the current row number (NR) is equal to 2, according to the dataset, the value starts from the second line.

`min = current_value`  It will assign the current values to min and max if the previous condition is true.

Later on, the second if condition to check the current value is minimum or maximum.

`if (current_value < min) min = current_value`  If current_value is smaller than the current min, then updates min with current_value.

The goal to to make sure to ensure the value of minimum and maximum.

`total_sum += current_value`  To add the value of the current column and save to total_sum

`sum_square += (current_value ^ 2)`  To calculates the square of the current_value.

<br><br>

* **The END block {...} is to calcualte the value of mean and standard deviation**  

Standard deviation determines the extent to which values in a dataset deviate from the Mean (average)

Formula:

$$
\text{StdDev} = \sqrt{\frac{\sum x^2}{n} - (\text{mean})^2}
$$

`mean = total_sum / total`  Mean/average is resulted the sum dividing by total elements.

`variance = (sum_square / total) - (mean * mean)`  This shows how data spread out in relation to the mean.

`stddev = sqrt(variance)`   Standard deviation is the square root of variance.

<br><br>

* **A loop reads lines of vale and save into variable: min, max, mean, sttdev**  
```bash
echo "$stats" | while read -r min max mean stddev; do ... done
```
To print the computed statistics and formats them to be displayed in a table by using the "while-loop" looping structure.

`echo "$stats"`  Print out th contentx of variable "stats".

`read -r`  Read text from input, and `-r` to stop backslashes as escape characters.


 * *Execution Result*
```bash
 ## Statistics (Numerical Features)
| Index   | Feature                | Min     | Max     | Mean    | StdDev  |
|---------|------------------------|---------|---------|---------|---------|
| 1       | fixed acidity          | 4.600   | 15.900  | 8.314   | 1.752   |
| 2       | volatile acidity       | 0.120   | 1.580   | 0.527   | 0.179   |
| 3       | citric acid            | 0.000   | 1.000   | 0.271   | 0.195   |
| 4       | residual sugar         | 0.900   | 15.500  | 2.537   | 1.410   |
| 5       | chlorides              | 0.012   | 0.611   | 0.087   | 0.047   |
| 6       | free sulfur dioxide    | 1.000   | 72.000  | 15.865  | 10.461  |
| 7       | total sulfur dioxide   | 6.000   | 289.000 | 46.439  | 32.895  |
| 8       | density                | 0.990   | 1.004   | 0.996   | 0.025   |
| 9       | pH                     | 2.740   | 4.010   | 3.309   | 0.175   |
| 10      | sulphates              | 0.330   | 2.000   | 0.658   | 0.170   |
| 11      | alcohol                | 8.400   | 14.900  | 10.416  | 1.096   |
| 12      | quality                | 3.000   | 8.000   | 5.633   | 0.819   |

```

<br><br>

* **Once the script finishing the calculation, the result is saved into summary.md**
```bash
echo "The result is saved to summary.md"
```

 * *Execution Result*
```bash
The result is saved to summary.md
```

<br><br><br>

************************************************************

## Demo - Execution of datacollector.sh

```bash

Enter the URL of the CSV dataset: 
https://archive.ics.uci.edu/static/public/186/wine+quality.zip

Downloading ...

Unzip the ZIP file....
Archive:  csv.zip
  inflating: winequality-red.csv     
  inflating: winequality-white.csv   
  inflating: winequality.names       

Choose the CSV file you want to analyze: 
1) Red wine - winequality-red.csv
2) White wine - winequality-white.csv
What is your choice? (1 or 2)? 1

## List of features for winequality-red.csv: 
1. fixed acidity
2. volatile acidity
3. citric acid
4. residual sugar
5. chlorides
6. free sulfur dioxide
7. total sulfur dioxide
8. density
9. pH
10. sulphates
11. alcohol
12. quality

Please enter column numbers for analysis (space-separated): 
1 2 3 4 5 6 7 8 9 10 11 12

The result is saved to summary.md

```

<br>

## Demo - Summary.md
```bash

-----------------------------------------------
# Feature Summary for winequality-red.csv
-----------------------------------------------
 
## Feature Index and Names
1. fixed acidity
2. volatile acidity
3. citric acid
4. residual sugar
5. chlorides
6. free sulfur dioxide
7. total sulfur dioxide
8. density
9. pH
10. sulphates
11. alcohol
12. quality

## Statistics (Numerical Features)
| Index   | Feature                | Min     | Max     | Mean    | StdDev  |
|---------|------------------------|---------|---------|---------|---------|
| 1       | fixed acidity          | 4.600   | 15.900  | 8.314   | 1.752   |
| 2       | volatile acidity       | 0.120   | 1.580   | 0.527   | 0.179   |
| 3       | citric acid            | 0.000   | 1.000   | 0.271   | 0.195   |
| 4       | residual sugar         | 0.900   | 15.500  | 2.537   | 1.410   |
| 5       | chlorides              | 0.012   | 0.611   | 0.087   | 0.047   |
| 6       | free sulfur dioxide    | 1.000   | 72.000  | 15.865  | 10.461  |
| 7       | total sulfur dioxide   | 6.000   | 289.000 | 46.439  | 32.895  |
| 8       | density                | 0.990   | 1.004   | 0.996   | 0.025   |
| 9       | pH                     | 2.740   | 4.010   | 3.309   | 0.175   |
| 10      | sulphates              | 0.330   | 2.000   | 0.658   | 0.170   |
| 11      | alcohol                | 8.400   | 14.900  | 10.416  | 1.096   |
| 12      | quality                | 3.000   | 8.000   | 5.633   | 0.819   |
============================================================================ 

```

