#!/bin/bash

COMMAND_OPTIONS="-master ${JENKINS_MASTER_ADDRESS} -username ${JENKINS_SWARM_USERNAME} -password ${JENKINS_SWARM_PASSWORD} -name ${JENKINS_SWARM_EXECUTOR_NAME} -labels ${JENKINS_SWARM_LABELS} ${JENKINS_SWARM_OTHER_OPTIONS}"

if [ -f "${USER_NAME_SECRET}" ]; then
    read USR < ${USER_NAME_SECRET}    
    COMMAND_OPTIONS="${COMMAND_OPTIONS} -username $USR"
fi

if [ -f "${PASSWORD_SECRET}" ]; then
    read PSS < ${PASSWORD_SECRET}
    export PSS
    COMMAND_OPTIONS="${COMMAND_OPTIONS} -passwordEnvVariable PSS"
fi

# GROUP=$(stat -c %G /var/run/docker.sock)
# if [ ! $(grep ^$GROUP: /etc/group) ]; then
#     addgroup -G $(stat -c %g /var/run/docker.sock) $GROUP
# fi
# adduser jenkins $GROUP

#echo "$JENKINS_MASTER_IP $JENKINS_MASTER_ADDRESS" >> /etc/hosts
sleep 10
exec su jenkins -c "exec java -jar /home/jenkins/jenkins-swarm.jar ${COMMAND_OPTIONS}"
#java -jar /home/jenkins/swarm-client-${SWARM_CLIENT_VERSION}.jar ${COMMAND_OPTIONS}