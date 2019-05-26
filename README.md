# mongo-backup
Docker image for continuously taking backups of mongoDB and copying the same to S3


## Environment variables

* RETRY_INTERVAL (s)  
    Mongo Dump retry interval (if failed)  
    *Default: 5*

* HOST  
    Mongo host Url. Fully supports official mongo host urls  
    *Default: localhost*

* BUCKET   
    S3 Bucket for backup destination  
    *Default: mongo-backup*

* OTHER_OPTIONS (optional)  
    > mongodump \<our options> \<other options>  

    If you need any custom options to be passed during mongodump, then this is the place for you.  
    For ex: If you would like to specify a particular DB to be backed then pass `--db my_db`

AWS-Cli Options (Mandatory)
* AWS_ACCESS_KEY_ID
* AWS_SECRET_ACCESS_KEY
* AWS_DEFAULT_REGION

## Swarm Deployment
Please use the image in association with a swarm cron scheduler such as [swarm-cronjob](https://github.com/crazy-max/swarm-cronjob). Please look into it for usage details.

```yml
version: '3.7'

services:
  cron:
    image: crazymax/swarm-cronjob
    volumes:
      - "/var/run/docker.sock:/var/run/docker.sock"
    environment:
      - "LOG_LEVEL=info"
      - "LOG_JSON=false"
    deploy:
      placement:
        constraints:
          - node.role == manager

  mongo_bkup:
    image: mongo-bkup
    deploy:
      labels:
        - "swarm.cronjob.enable=true"
        - "swarm.cronjob.schedule=0 * * * * *"
        - "swarm.cronjob.skip-running=false"
      replicas: 0
      restart_policy:
        condition: none
    environment: 
      - "INTERVAL=5"
      - "HOST=mongo:27017"
      - "BUCKET=<s3 bucket name>"
      - "AWS_SECRET_ACCESS_KEY=<aws secret access key>"
      - "AWS_ACCESS_KEY_ID=<aws access key>"
      - "AWS_DEFAULT_REGION=<region>"
```

## Restore
Get `dump.tar` file from S3 and then run the following commands:  
> tar xvf dump.tar  
> mongorestore --gzip dump/

## Contributions
All PRs are welcome

## Licence
MIT