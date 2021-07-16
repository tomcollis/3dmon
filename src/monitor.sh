#monitor.sh
#make sure a process is always running.

WORK_PATH=$PWD
PING_HOST=8.8.8.8
WIFI_FILE=wifi.sh

# Quit if the process is still running, no need to do anything!
if pgrep -f "python main.py" &>/dev/null;
then
        echo "Still running...";
        exit
fi

# Check if device internet connection is most likely wireless or wired
if [ -f "$WIFI_FILE" ]; then
        echo "This device probably has a wireless internet connection."
        WIFI_STATUS=1
else
        echo "This device probably has a wired internet connection."
        WIFI_STATUS=0
fi

# If there is no internet connection, stop and wait for next minute!
INTERNET_CHECK=$(curl -s --max-time 2 -I http://google.com | sed 's/^[^ ]*  *\([0-9]\).*/\1/; 1q')

if [ $INTERNET_CHECK -eq 2 ] || [ $INTERNET_CHECK -eq 3 ]
        then
        echo "The network is up"
elif [ $WIFI_STATUS -eq 1 ]
        then
        echo "The network is down. Trying to reconnect..."
        sudo wifi.sh -a
        exit 1
else
        echo "The network is down. Waiting for it to return..."
        exit 1
fi

nohup $WORK_PATH/main.py 2>&1 > $WORK_PATH/3dmon.log
