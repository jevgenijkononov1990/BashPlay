#!/bin/sh

#GLOBAL VARIABLES DECLARATION
export TRUE=1 
export FALSE=0
export LOG_IS_ENABLED=$TRUE # used for log enable/disable
export LOGGER= #used for logfilename
export USER_CSV_AR_POINTER=() # used for csv values
export USER_MAIN_DIR= # used for storing user main dir
export USER_FOLDERS_TO_CREATE= # used for storing user folders to create
export SPLIT_ITEMS_COUNTER=4
export SPLIT_DELIMETER=,
#GLOBAL VARIABLES DECLARATION END


#EXCEPTION CODES DECLARATION
export ProgramTermination_Success=0
export ProgramTermination_Failure=1
export GeneralException=100
export CSVFileReadException=101
export UserAccountCreationException=102
export NullInputError=103
export DataExtracationError=104
export DataTransformationError=105
export ProcessManagementError=106
export UnknownCommand=107
export CommandIsNotImplemented=108
export ConfigFileError=109
#EXCEPTION CODES DECLARATION END


#GENERAL DECLARATION
export GENERAL_CMD_MESSAGE_STRING="==========HELP========> COMMANDS EXPLANATION:"
export COMMAND_START_ERROR_SCENARIO="When script is invoked with no arguments program leads to termination!"
export COMMAND_TYPE_UNKNOWN=0

#export COMMAND_LIST="Possible commands: users, file, process"
export COMMAND_LIST_ARR=("users" "file" "process")
export LAST_CSV_FILE="lastcsv.nameholder"
export WELCOME_FILE_NAME="Welcome.txt"

# Provision of simple help 
#This command should be called If the wrapper script is invoked with no arguments
export COMMAND_TYPE_HELP_ID=1

#Data extraction and transformation
#This command should be called when user command = 
#           [param1] [param2]
#command text: file <filename>.csv
export COMMAND_TYPE_CSV_FILE_DATA_EXTRACTION_ID=2
export COMMAND_TYPE_CSV_FILE_DATA_EXTRACTION_STRING_HELP="[param1] [param2] --> file <filename>.csv"

#User account creation 
#this command should be user when csv file read success
#then input should look like 

#           [param1] [option]
# command text:[users] [new]
export COMMAND_TYPE_USER_ACCOUNT_CREATION_ID=3
export COMMAND_TYPE_USER_ACCOUNT_CREATION_STRING_HELP="[param1] [param2] --> users new"

#Process management
#[param1] [param2]
#command text: [process] [option]
export COMMAND_TYPE_PROCESS_MANAGMENT_ID=4
export COMMAND_TYPE_PROCESS_MANAGMENT_STRING_HELP="[param1] [param2] --> process account or kill or export"

export CURRENT_CMD_ID=$COMMAND_TYPE_HELP_ID # used for function return values

#GENERAL DECLARATION END