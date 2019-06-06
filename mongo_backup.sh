#!/bin/bash

sleep 1;

if [ ! $HOST ]; then
    HOST='localhost'
fi

if [ ! $BUCKET ]; then
    BUCKET='mongo-backup'
fi

if [ ! $RETRY_INTERVAL ]; then
    RETRY_INTERVAL=5
fi

echo "Backing up $HOST to s3://$BUCKET/ on $(date)";

DEST=dump_$(date +"%Y-%m-%d_%H:%M:%S")
TAR=$DEST.tar

RESULT=1

RETRIES=0

# if failed then keep retrying with specified interval
while [ $RESULT -gt 0 -a $RETRIES -le 5 ]
do
    if [[ $RETRY -gt 0 ]]; then
        echo RETRY: $RETRIES
    fi

    RETRIES=`expr $RETRIES + 1`
    mongodump --host $HOST -o $DEST $OTHER_OPTIONS
    RESULT=$?
    sleep $RETRY_INTERVAL;
done

if [ $? == 0 ]; then
    if [[ ! -z "${TEST}" ]]; then
        echo "--------------------------"
        echo "TEST_MODE: Success"
        echo "--------------------------"
        exit 0
    fi

    # compress the dumped folder
    /bin/tar cvf $TAR $DEST/

    # Push the dump to S3
    /usr/bin/aws s3 cp $TAR s3://$BUCKET/

    if [ $? == 0 ]; then
        echo "--------------------------"
        echo "Backup status: Success"
        echo "--------------------------"
    else 
        echo "--------------------------"
        echo "Backup status: Failed!!!"
        echo "--------------------------"
    fi

else 
    echo "--------------------------"
    echo "Backup status: Failed!!!"
    echo "--------------------------"
fi


echo ""
echo ""
