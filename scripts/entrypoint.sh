#!/bin/bash

. /kb/deployment/user-env.sh

python ./scripts/prepare_deploy_cfg.py ./deploy.cfg ./work/config.properties

if [ -f ./work/token ] ; then
  export KB_AUTH_TOKEN=$(<./work/token)
fi

if [ $# -eq 0 ] ; then
  sh ./scripts/start_server.sh
elif [ "${1}" = "test" ] ; then
  echo "Run Tests"
  make test
elif [ "${1}" = "async" ] ; then
  sh ./scripts/run_async.sh
elif [ "${1}" = "init" ] ; then
  echo "Initialize module"
  cd /data/checkm_data # There is 1.3G data
  curl -s https://data.ace.uq.edu.au/public/CheckM_databases/checkm_data_v1.0.7.tar.gz|tar xzf -
  cd /kb/module
  checkm data setRoot "/data/checkm_data"
  checkm data update # ensure you have the latest (32) data files from the ACE server
  if [ -d "/data/checkm_data/genome_tree" ] ; then
        touch __READY__
  else
    echo "Init failed"
  fi
elif [ "${1}" = "bash" ] ; then
  bash
elif [ "${1}" = "report" ] ; then
  export KB_SDK_COMPILE_REPORT_FILE=./work/compile_report.json
  make compile
else
  echo Unknown
fi
