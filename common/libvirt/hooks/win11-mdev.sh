#!/bin/bash

if [[ $1 == "win11" ]] && [[ $2 == "start" || $2 == "stopped" ]]
then
  if [[ $2 == "start" ]]
  then
    mdevctl start -u 764d3e0f-ede8-42c9-b9b1-a866f2678039
  else
    mdevctl stop -u 764d3e0f-ede8-42c9-b9b1-a866f2678039
  fi
fi
