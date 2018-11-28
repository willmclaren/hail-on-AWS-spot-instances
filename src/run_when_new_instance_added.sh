#!/bin/bash -x -e

sudo grep -i privateip /mnt/var/lib/info/*.txt | sort -u | cut -d "\"" -f 2 > /tmp/t2.txt

if [ -z "`diff /tmp/t1.txt /tmp/t2.txt`" ]
then
      # echo "No Instances added"
else
  for WORKERIP in `diff /tmp/t1.txt /tmp/t2.txt | grep "> " | sed 's/> //'`
  do
     # Distribute keys to workers for account hadoop
     scp -o "StrictHostKeyChecking no" ~/.ssh/id_rsa ${WORKERIP}:/home/hadoop/.ssh/id_rsa
     scp ~/.ssh/authorized_keys ${WORKERIP}:/home/hadoop/.ssh/authorized_keys
     # Install Python 3
     scp /home/hadoop/hail-* ${WORKERIP}:/home/hadoop/
     scp install_python36.sh hadoop@${WORKERIP}:/tmp/install_python36.sh
     ssh hadoop@${WORKERIP} "sudo ls -al /tmp/install_python36.sh"
     ssh hadoop@${WORKERIP} "sudo /tmp/install_python36.sh"
     ssh hadoop@${WORKERIP} "python3 --version"
     # Distribute Hail files
     scp /home/hadoop/hail-* $WORKERIP:/home/hadoop/
     sudo grep -i privateip /mnt/var/lib/info/*.txt | sort -u | cut -d "\"" -f 2 > /tmp/t1.txt
  done
fi
