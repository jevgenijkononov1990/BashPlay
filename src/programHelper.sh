#!/bin/sh

source $(dirname $0)/variablesHolder.sh

function CreateFolder() {
  dir=$1 
    #echo "Requested to create a new folderName ${dir}"
    if [[ ! -e $dir ]]; then
        mkdir $dir
        #echo "$dir folder created"
        return $TRUE

    elif [[ ! -d $dir ]]; then
        #DEBUG "$dir already exists but is not a directory" 1>&2
        return $FALSE
    fi
} 

function CreateFile() {
     mkdir -p -- "$1" && touch -- "$1"/"$2" 
 }

function CheckIfFileExist()
{
    FILE=$1 
    if [ -f "$FILE" ]; then
        #DEBUG "$FILE exists."
        return $TRUE
    else 
       #DEBUG  "$FILE does not exist."
        return $FALSE
    fi
}

function CheckIfDirectoryExist()
{
    DIR=$1 
    if [ -d "$DIR" ]; then
        #DEBUG "$DIR is a directory."
        return $TRUE
    fi
    
    return $FALSE
}

function IsValueNull() {

    my_var=$1
    if test -z "$my_var" 
    then
        #DEBUG "\$value is NULL"
        return $TRUE
    else
        #DEBUG "\$value is NOT NULL"
        return $FALSE
    fi
}

function IsFileCSVFormat() {

    file=$1

    if [ "$file" == "*.csv" ]; then 
        return $TRUE
    fi

    return $FALSE
}


function TerminationWithCondition_Because_Of_Exp() {
    condition=$1 

    if [ $condition -eq 1 ]; then  
        echo "Program termination. Code: $ProgramTermination_Failure"
        exit $ProgramTermination_Failure
    fi

    echo "Termination skip"
}

function TerminationWithCondition_Because_Of_Exp_With_Custom_Error_Id() {
    condition=$1 
    errorId=$2
    if [ $condition -eq 1 ]; then  
        echo "Program termination. Code: $errorId"
        exit $errorId
    fi

    echo "Termination skip"
}

function TerminationWith_With_Custom_Error_Id() {
    errorId=$1 
    echo "Program termination with. Code: $errorId"
    exit $errorId
}


function Termination_OnSuccess() {
    echo "Program termination on success: $ProgramTermination_Success"
    exit $ProgramTermination_Success
}

function Termination_OnFailure() {
    echo "Program termination on failure: $ProgramTermination_Failure"
    exit $ProgramTermination_Failure
}



#HELPFULL LINKS
#https://stackoverflow.com/questions/10929453/read-a-file-line-by-line-assigning-the-value-to-a-variable
#https://stackoverflow.com/questions/23564995/how-to-modify-a-global-variable-within-a-function-in-bash
#try catch
#https://stackoverflow.com/questions/22009364/is-there-a-try-catch-command-in-bash