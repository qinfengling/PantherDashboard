#!/bin/bash
name="clear-blockchain"
service=$(cat /var/dashboard/services/$name | tr -d '\n')

if [[ $service == 'start' ]]; then
  echo 'running' > /var/dashboard/services/$name
  echo 'Stopping currently running docker...' > /var/dashboard/logs/$name.log
  docker kill helium-miner >> /var/dashboard/logs/$name.log
  currentdockerstatus=$(sudo docker ps -a -f name=helium-miner --format "{{ .Status }}")
  if [[ ! $currentdockerstatus =~ 'Up' || $currentdockerstatus == '' ]]; then
    echo 'Clearing Blockchain folders...' >> /var/dashboard/logs/$name.log
    for f in /opt/miner_data/blockchain.db/*;
    do
      rm -rfv "$f" >> /var/dashboard/logs/$name.log;
    done

    for f in /opt/miner_data/ledger.db/*;
    do
      rm -rfv "$f" >> /var/dashboard/logs/$name.log;
    done

    docker start helium-miner
    currentdockerstatus=$(sudo docker ps -a -f name=helium-miner --format "{{ .Status }}")
    if [[ $currentdockerstatus =~ 'Up' ]]; then
      echo 'stopped' > /var/dashboard/services/$name
      echo '------------------------------------------' >> /var/dashboard/logs/$name.log
      echo 'Task completed.' >> /var/dashboard/logs/$name.log
    else
      echo 'stopped' > /var/dashboard/services/$name
      echo '------------------------------------------' >> /var/dashboard/logs/$name.log
      echo 'Miner docker failed to start.  Check logs to investigate.' >> /var/dashboard/logs/$name.log
    fi
  else
    echo 'stopped' > /var/dashboard/services/$name
    echo '------------------------------------------' >> /var/dashboard/logs/$name.log
    echo 'Error: Could not stop docker.' >> /var/dashboard/logs/$name.log
  fi
fi
