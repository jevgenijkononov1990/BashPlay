#!/bin/sh

source $(dirname $0)/programHelper.sh
source $(dirname $0)/variablesHolder.sh

function HandleLogging () {

    LogFileName=$(date +%Y-%m-%d).log
    MainLogsFolder="Logs"
    CreateFolder $MainLogsFolder
    CreateFile $MainLogsFolder $LogFileName
    LOGGER="$MainLogsFolder"/"$LogFileName"
}

function DEBUG() {
   
    LogTimeCalendar=$(date +%d/%m/%Y)  
    LogTime=$(date +%H:%M:%S) 
    debugMessage=$1

    if [ $LOG_IS_ENABLED -ne 0 ]; then
        echo "[$LogTimeCalendar $LogTime]" "DEBUG: $debugMessage"
        echo "[$LogTimeCalendar $LogTime]" "DEBUG: $debugMessage" >> $LOGGER
    fi
}