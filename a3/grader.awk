# Assignmnet 3 - Learn how to build a complex awk application.

# BEGIN block: set value to the specific variables for
# field seperator, highest score, and lowest score
BEGIN {
    FS = ","    # Set the field separator as ","                     
    score_highest = 0       # Default value of the highest score to 0 
    score_lowest = 100000   # Default value of the lowest score to 100000                 
}

# Main block: To capture the value for each student's record in the CSV dataset, 
# And find out value of total score, average socre, pass/fail, top score student and low score student
{
    if (NR == 1) { next }  # if-statement to skip the first line and move to the next line
    st_name = $2           # To capture the value in the 2nd column to variable "st_name"
    student_id[st_name] = $1  # To assign the value of the 1st column to the array "student_id"

    total = 0
    num_course = 0
    # For-loop to count the total score and the number of course
    for ( i=3; i <= NF; i++) {    
        total += $i   # Sum up all values of columns containing student's scores
        num_course ++;   # Count the number of course
    }
    total_score[st_name] = total    # Store total scores in associative array, using "st_name" as the key
    
    average = AverageCalculation(total, num_course)  # User-defined function for average calcuation (pass total score and num_course)
    average = sprintf("%.2f", average)   # Format the average score to exactly 2 decimal places
    score_average[st_name] = average     # Store average score in associative array named "score_average" along with the key
  
    StatusCheck(st_name, average)    # User-defined function for verifying student's performance by passing parameters name and average score      

    TopScoreStudent(total, st_name)   # User-defined function for looking the student who has the highest score 
    LowScoreStudent(total, st_name)   # User-defined function for looking the student who has the lowest score 
}

# END block: To print the final results for each student, and display top scoring student and lowest scoring student
# To construct the outline by adding the title and headers 
END {   
    print "\n \t << Student Grade Report >> "
    print "====================================================================================================="
    printf "%-16s %-30s %-16s %-16s %-16s \n", "Student ID", "Student Name", "Total Score", "Average Score", "Status(Pass/Fail)"
    # Given extra space of the column for students who have long name. 
    print "-----------------------------------------------------------------------------------------------------"   
   
   # For-loop prints out all value stored as a key in the associative arrays, 
   # such as student_id, name, total_score, score_average, and evaluation. 
   for (s in total_score) {
        printf "%-16s %-30s %-16s %-16s %-16s \n", \
                student_id[s], s, total_score[s], score_average[s], evaluation[s]
       print "-----------------------------------------------------------------------------------------------------"
    }

    # Print out the student who has highest score and the one who has lowest score.
    print "\n- The student with the highest score:", top_student, "(", score_highest, "points", ")" 
    print "\n- The student with the lowest score:", low_student, "(", score_lowest, "points", ") \n\n"
}


# User-defined function "AverageCalculation": Calculate the average of score for each student
function AverageCalculation(total, num) {
    return total / num
}

# User-defined function "StatusCheck" 
# Verifying if the average score of student based on the specific score (70)
# if it is greater than or equal to 70, then pass; otherwise, it fails 
function StatusCheck(st_name, average) {
     if (average >= 70)
        evaluation[st_name] = "Pass"
    else
        evaluation[st_name] = "Fail"
}

# User-defined function: "TopScoreStudent" to find the highest scoring student
# Once it's found, then assign the value to variables "score_highest" and "top_student"
function TopScoreStudent(total, st_name) {
    if (total > score_highest) {
        score_highest = total
        top_student = st_name
    }
}

# User-defined function: "LowScoreStudent" to find the lowest scoring student
# Once it's found, then assign the value to variables "score_lowest" and "low_student"
function LowScoreStudent(total, st_name) {
    if (total < score_lowest) {
        score_lowest = total
        low_student = st_name
    }
}

