#!/bin/sh

source $(dirname $0)/programHelper.sh
source $(dirname $0)/programLogger.sh
source $(dirname $0)/variablesHolder.sh
source $(dirname $0)/trycatch.sh


function IsInputParameterValidToProcced_ThrowsExceptionIfNot() {

    DEBUG "IsInputParameterValidToProcced_ThrowsExceptionIfNot start"

    inputParameter_1=$1

    nullCommandBool="$(IsValueNull $inputParameter_1)"

    intputCommnd=$?
    case $intputCommnd in

        $TRUE)
            DEBUG "InputParameterIsInValid: $inputParameter_1"
            throw $NullInputError
            #return $FALSE
        ;;
        $FALSE)
            DEBUG "InputParameterIsValid: $inputParameter_1"
            return $TRUE
        ;;
        *)
            DEBUG "EXCEPTION: $inputParameter_1"
            throw $GeneralException
        ;;
    esac
}

function TryToProcessInput_ThrowsExceptionIfNot() {

    DEBUG "InputParameterConvertionToCommnd_ThrowsExceptionIfNot start"
    currentCmd=$1
    currentCmdOption=$2
    matchFound=$FALSE
    
    #command validation
    for cmd in "${COMMAND_LIST_ARR[@]}"
    do
        DEBUG "LOOP CMD: $cmd"
        if [ "$currentCmd" = "$cmd" ]; then
            DEBUG "Command match: $cmd"
            matchFound=$TRUE
            break 
        fi
    done

    if [ $matchFound -eq $FALSE ]; then
        DEBUG "No match found for: $currentCmd"
        throw $UnknownCommand
    fi

    DEBUG "Command <=== $currentCmd ==> procces is started, please wait"
   
    case $currentCmd in
        "file")
            
            ReadConfigSettings
            ReadCsVFile $currentCmdOption
       ;;
       "users")
            DEBUG "start"
            #check if file exists in directory
            if [ "$currentCmdOption" = "new" ]; then

                Create_Users_Using_Csv_Array
            else 
            
                DEBUG "USERS wrong cmdOption: $currentCmdOption"
                throw $UserAccountCreationException    
            
            fi

       ;;
       "process")
            DEBUG "start"
            sleep 10 
       ;;
       *)
            DEBUG "EXCEPTION: $currentCmd"
            throw $CommandIsNotImplemented
       ;;
    esac
    
}

function ReadConfigSettings() {

    DEBUG "ReadConfigSettings"
    checkConfigFile="$(CheckIfFileExist config.json)"
    boolOutput=$?
    DEBUG "CheckConfigFile: $boolOutput"
    if [ $boolOutput -eq 0 ]; then
        DEBUG "config file read error. Process termination"
        throw $ConfigFileError
    fi


    cat config.json | grep name #| cut -d ':' -f2

    declare -a values # declare the array                                                                                                                                                                  

    # Read each line and use regex parsing (with Bash's `=~` operator)
    # to extract the value.
    while read -r line; do
    # Extract the value from between the double quotes
    # and add it to the array.
    [[ $line =~ :[[:blank:]]+\"(.*)\" ]] && values+=( "${BASH_REMATCH[1]}" )
    done < config.json                                                                                                                                          

    #declare -p values # print the array

    declare -a userFolderNames # declare the array   
    mainUserFolder=""
    USER_FOLDERS_TO_CREATE=()
    counter=0
    #counter = 0 
    for i in "${values[@]}"
    do
        if [ $counter -ne 0 ]; then
            userFolderNames+=( "${i}" )
            USER_FOLDERS_TO_CREATE+=( "${i}" )

        else
            mainUserFolder="$i"
        fi
        ((counter++))
    done
            
    USER_MAIN_DIR=$mainUserFolder
    #USER_FOLDERS_TO_CREATE=$userFolderNames
    CreateFolder $USER_MAIN_DIR
    
    DEBUG "USER_MAIN_DIR: $USER_MAIN_DIR"
    DEBUG "ReadConfigSettings success"
}

function CheckCSVFileLineLeght() {
    varItem=$1
    
    arrIN=(${varItem//,/ })
    len=${#arrIN[@]}

    return $len
}

function ReadCsVFile() {

    fileName=$1
    DEBUG "ReadCsVFile start"
    checkCsvFile="$(CheckIfFileExist $fileName)"
    boolOutput=$?
    DEBUG "ReadCsVFile: $boolOutput"

    if [ $boolOutput -eq 0 ]; then
        DEBUG "$fileName read error. Process termination"
        throw $CSVFileReadException
    fi

    USER_CSV_AR_POINTER=()
    i=0
    # reading file in row mode, insert each line into array

    varFirstLineDescription=""

    while IFS= read -r line; do
      if [ $i -eq 0 ]; then
            varFirstLineDescription=$line
      else
            USER_CSV_AR_POINTER[i]=$line
      fi
        #POINTER[i]=$line
      let "i++"
    done < "$fileName"                                                                                                                                

    DEBUG "CSV first line: $varFirstLineDescription"
    firstLineItemsBool="$(CheckCSVFileLineLeght $varFirstLineDescription)"
    firstLineItemsLenght=$?
    DEBUG "CSV first line decode items count: $firstLineItemsLenght"
    SPLIT_ITEMS_COUNTER=$firstLineItemsLenght
    lineCounter=0

    for val in "${USER_CSV_AR_POINTER[@]}"
    do

        itemBool="$(CheckCSVFileLineLeght $varFirstLineDescription)"
        itemLenght=$?
        if [ $itemLenght -eq $firstLineItemsLenght ]; then
            DEBUG "value[$lineCounter] CHECK SUCCESS."
        else
            DEBUG "value[$lineCounter] CHECK FAILURE. Not enought values inside line to parse"
        fi

        ((lineCounter++))

    done 
    
    # all checks correct
    #store for future filenam name
    echo "$fileName" > "$LAST_CSV_FILE"

    DEBUG "ReadCsvFile success"
}



function Create_Users_Using_Csv_Array() {

    DEBUG "Create_Users_Using_Csv_Array start"

    #check USER_CSV_AR_POINTER NULL or lengh 0 ==> block 
    #check USER_MAIN_DIR NULL OR NOT EXISTS ==> block
    #check USER_FOLDERS_TO_CREATE_AR is null or lengh 0
    #any of this items null or empty throw exception ==> UserAccountCreationException
    
    ##read again config settings -> this will prevent from nulls
    #read again file
    ReadConfigSettings
    line=$(head -n 1 "$LAST_CSV_FILE")
    DEBUG "last csv file: $line"
    ReadCsVFile $line

    #check USER_MAIN_DIR NULL 
    bool="$(IsValueNull $USER_MAIN_DIR)"
    boolCheck=$?
    if [ $boolCheck -eq $TRUE ]; then
        echo $USER_MAIN_DIR
        DEBUG "Users creation path error: USER_MAIN_DIR value is empty"
        throw $UserAccountCreationException
    fi

    #check USER_MAIN_DIR IS EXISTS 
    bool="$(CheckIfDirectoryExist $USER_MAIN_DIR)"
    boolCheck=$?
    if [ $boolCheck -eq $FALSE ]; then

        DEBUG "Users creation path error: USER MAIN FOLDER DO NOT EXIST"
        throw $UserAccountCreationException
    fi
    #----------------------------------------------


    bool="$(IsValueNull $USER_FOLDERS_TO_CREATE)"
    boolCheck=$?
    if [ $boolCheck -eq $TRUE ]; then

        DEBUG "Users folder structure error: USER_FOLDERS_TO_CREATE value is NULL"
        throw $UserAccountCreationException
    fi

    if [ ${#USER_FOLDERS_TO_CREATE[@]} -eq 0 ]; then

        DEBUG "Users folder structure error: USER_FOLDERS_TO_CREATE value is empty"
        throw $UserAccountCreationException
    fi

    #----------------------------------------------
    
    bool="$(IsValueNull ${#USER_CSV_AR_POINTER[@]})"
    boolCheck=$?
    if [ $boolCheck -eq $TRUE ]; then

        DEBUG "Users csv file zero output: CSV ARRAY IS NULL"
        throw $UserAccountCreationException
    fi


    if [ ${#USER_CSV_AR_POINTER[@]} -eq 0 ]; then

        DEBUG "Users csv file zero output: CSV ARRAY IS NULL"
        throw $UserAccountCreationException
    fi
    
    #----------------------------------------------
    DEBUG "ALL CONFIGURATIONS CORRECT. READY FOR USERS STRUCTURE CREATION"
    

    for val in "${USER_CSV_AR_POINTER[@]}"
    do
        try
        (
            arrIN=(${val//,/ })
            len=${#arrIN[@]}
            #echo $len
            if [ $len -eq $SPLIT_ITEMS_COUNTER ]; then
            
                userName="${arrIN[0]}"
                #echo $userName
                userEmail="${arrIN[0]}"
                userDepartment="${arrIN[0]}"
                userManager="${arrIN[0]}"
                #userFolder="/$USER_MAIN_DIR/$userName"
                mkdir "$USER_MAIN_DIR/$userName"
                for item in "${USER_FOLDERS_TO_CREATE[@]}"
                do
                    newDir="$USER_MAIN_DIR/$userName/$item"
                    mkdir $newDir

                    if [ "$item" = "Documents" ]; then

                        newFilePath=$newDir/$WELCOME_FILE_NAME
                        echo "Welcome to the business, $userName" > "$newFilePath"
                        echo "We are pleased to have you working in the $userDepartment department" >> "$newFilePath"
                        echo "If you have any questions, please speak to your manager, $userManager" >> "$newFilePath"
                        echo "Your email address is $userEmail" >> "$newFilePath"
                    fi

                done

            else
                DEBUG "SKiP structure creation for this client $val"
            fi
        )
        catch || {
                DEBUG "error in user creation for this value: $val"
        }

    done 

    DEBUG "Create_Users_Using_Csv_Array FINISH"
}


