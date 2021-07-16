#monitor.sh
#make sure a process is always running.

WORK_PATH=$PWD
LOG_FILE=$PWD/3dmon.log
INTERNET_HOST=http://google.com
WIFI_FILE=wifi.sh
LOG_LINES_LIMIT=100

#Tidy Log Files
tail -n "$LOG_LINES_LIMIT" "$LOG_FILE" >  "$LOG_FILE.tmp"
mv -f "$LOG_FILE.tmp" "$LOG_FILE"

# Quit if the process is still running, no need to do anything!
if pgrep -f "python main.py" &>/dev/null;
then
        echo "Still running..." | tee -a $LOG_FILE
        exit
fi

# Check if device internet connection is most likely wireless or wired
if [ -f "$WIFI_FILE" ]; then
        echo "This device probably has a wireless internet connection." | tee -a $LOG_FILE
        WIFI_STATUS=1
else
        echo "This device probably has a wired internet connection." | tee -a $LOG_FILE
        WIFI_STATUS=0
fi

# If there is no internet connection, stop and wait for next minute!
INTERNET_CHECK=$(curl -s --max-time 2 -I $INTERNET_HOST | sed 's/^[^ ]*  *\([0-9]\).*/\1/; 1q')

if [ $INTERNET_CHECK -eq 2 ] || [ $INTERNET_CHECK -eq 3 ]
        then
        echo "The network is up" | tee -a $LOG_FILE
elif [ $WIFI_STATUS -eq 1 ]
        then
        echo "The network is down. Trying to reconnect..." | tee -a $LOG_FILE
        sudo wifi.sh -a
        exit 1
else
        echo "The network is down. Waiting for it to return..." | tee -a $LOG_FILE
        exit 1
fi

date +"Date:%d-%m-%Y_%H:%M:%S" >> $LOG_FILE

nohup $WORK_PATH/main.py 2>&1 >> $LOG_FILE
