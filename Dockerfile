FROM mongo

ARG FILE='mongo_backup.sh'

WORKDIR /var/www

RUN apt update
RUN apt install awscli -y

COPY ${FILE} .

RUN chmod +x ${FILE}

ENV EXEC_FILE=${FILE}

ENTRYPOINT ./$EXEC_FILE