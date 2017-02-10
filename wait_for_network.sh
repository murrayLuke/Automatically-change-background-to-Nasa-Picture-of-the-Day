#!/bin/bash

# Include rc.common which has startup scripts written by apple
. /etc/rc.common

# check to see if we are connected to a network
CheckForNetwork

# set a counter so we don't do this forever
COUNTER=0

# while we don't have an internet connection
while [ "${NETWORKUP}" != "-YES-" ]
do
		# wait for ten seconds
        sleep 10

        # check again
        NETWORKUP=
        CheckForNetwork

        # increment the counter
		let COUNTER=COUNTER+1 

		# if we haven't found it in 200 seconds
		# give up
        if [ $COUNTER == 20 ] 
        then
        	# let the user know that we failed
        	echo "Could not find an internet connection"
        	exit 1
		fi
done

# let the user know that we succeeded
echo "found an internet connection"