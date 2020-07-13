#!/bin/sh

#usage ./main.sh [param1] [param2]
#where param1 cmdType
#where param2 cmdOption

echo "help libraries load"
source $(dirname $0)/trycatch.sh
source $(dirname $0)/programHelper.sh
source $(dirname $0)/variablesHolder.sh
source $(dirname $0)/programLogger.sh
source $(dirname $0)/commandService.sh
echo "help libraries load success"

function GeneralHelp() {
    echo ""
    echo $GENERAL_CMD_MESSAGE_STRING

    ##echo $COMMAND_LIST
    for i in "${COMMAND_LIST_ARR[@]}"
    do
        echo "======================> possible input command:  $i "
    # or do whatever with individual element of the array
    done

    echo ""
    echo $COMMAND_TYPE_USER_ACCOUNT_CREATION_STRING_HELP
    echo $COMMAND_TYPE_CSV_FILE_DATA_EXTRACTION_STRING_HELP
    echo $COMMAND_TYPE_PROCESS_MANAGMENT_STRING_HELP
    echo $COMMAND_START_ERROR_SCENARIO
}

function ProgramWrapperHandler() {

    echo "Program start"
    HandleLogging
    DEBUG "Program init"
    #GeneralHelp
    currentCmdType=$1
    currentCmdOption=$2
    
    echo ""
    echo "Pres CTRL + C to stop!"
    echo ""

    try
    ( 
        #for (( ; ; ))
        foreverLoopCounter=0 
        #setup forever loop
        ##in normal forever loop for some reason impossible to update counter value 
        #that is why solution was to hack this part and create this forever loop which allows incremention  
        for (( foreverLoopCounter=1; foreverLoopCounter<=3; foreverLoopCounter++ ))
        do
             try
             ( 
                DEBUG "HANDLER_ID: $foreverLoopCounter"
                 ## means program first time start 
                #read params or give options to process
                if [ $foreverLoopCounter -eq 1 ]; then

                    echo "Entered command type:" $currentCmdType 
                    echo "Entered command option:" $currentCmdOption 

                elif [ $foreverLoopCounter -eq 2 ]; then
                        foreverLoopCounter=1

                    echo "Enter command type:"  
                    read currentCmdType
                    echo "Enter command option:"
                    read currentCmdOption
                    DEBUG "user input data:$currentCmdType $currentCmdOption"
                
                elif [ $foreverLoopCounter -eq 3 ]; then
                    break;
                fi

                IsInputParameterValidToProcced_ThrowsExceptionIfNot $currentCmdType
                IsInputParameterValidToProcced_ThrowsExceptionIfNot $currentCmdOption    
                TryToProcessInput_ThrowsExceptionIfNot $currentCmdType $currentCmdOption    

                DEBUG "Job done"
                break 
                
             )
             catch || {
                 case $ex_code in
                     $ConfigFileError)
                         DEBUG "ConfigFileError"
                     ;;
                     $CommandIsNotImplemented)
                         DEBUG "CommandIsNotImplemented"
                     ;;
                     $GeneralException)
                         DEBUG "GeneralException"
                     ;;
                     $UnknownCommand)
                         DEBUG "UnknownCommand"
                     ;;
                     $CSVFileReadException)
                         DEBUG "CSVFileReadException"
                     ;;
                     $UserAccountCreationException)
                         DEBUG "UserAccountCreationException"
                     ;;
                     $NullInputError)
                        DEBUG "NullInputError"   
                        GeneralHelp 
                        sleep 3 
                        #without this condition program will continue to work even 
                        #TerminationWithCondition_Because_Of_Exp 1
                        #foreverLoopCounter = 1  program was started first time
                        #by requirment when we have exception we need to terminate 
                        #but it is good to have another option and in case do not rewrite software if we have different requirment 
                         TerminationWithCondition_Because_Of_Exp_With_Custom_Error_Id $foreverLoopCounter  $NullInputError
                     ;;
                     $DataExtracationError)
                         DEBUG "DataExtracationError"
                     ;;
                     $DataTransformationError)
                         DEBUG "DataTransformationError"
                     ;;
                     $ProcessManagementError)
                         DEBUG "ProcessManagementError"
                     ;;
                     *)
                         DEBUG "An unexpected exception was thrown in main program loop"
                         throw $ex_code # rethrow the "exception" causing the script to exit if not caught
                     ;;
                 esac
           
                 DEBUG "process failure id: $foreverLoopCounter, cmdType:$currentCmdType, cmdOption: $currentCmdOption"
                 foreverLoopCounter=1
                 GeneralHelp
            }
        done

        DEBUG "close 0"
        sleep 1
        Termination_OnSuccess
    )
    catch || {
        # now you can handle
         DEBUG $currentCmd $currentCmdOption 
         Termination_OnFailure
    }
}
 

# Read the user input    
ProgramWrapperHandler $1 $2
