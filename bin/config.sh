#!/usr/bin/env bash

# thanks accumulo for these resolutions snippets
if [ -z "${CLOUD_CASSANDRA_HOME}" ] ; then
  # Start: Resolve Script Directory
  SOURCE="${BASH_SOURCE[0]}"
  while [ -h "$SOURCE" ]; do # resolve $SOURCE until the file is no longer a symlink
     bin="$( cd -P "$( dirname "$SOURCE" )" && pwd )"
     SOURCE="$(readlink "$SOURCE")"
     [[ $SOURCE != /* ]] && SOURCE="$bin/$SOURCE" # if $SOURCE was a relative symlink, we need to resolve it relative to the path where the symlink file was located
  done
  bin="$( cd -P "$( dirname "$SOURCE" )" && pwd )"
  script=$( basename "$SOURCE" )
  # Stop: Resolve Script Directory

  CLOUD_CASSANDRA_HOME=$( cd -P ${bin}/.. && pwd )
  export CLOUD_CASSANDRA_HOME
fi

if [ ! -d "${CLOUD_CASSANDRA_HOME}" ]; then
  echo "CLOUD_CASSANDRA_HOME=${CLOUD_CASSANDRA_HOME} is not a valid directory. Please make sure it exists"
  return 1
fi

# [Tab] shell completion because i'm lazy
IFS=$'\n' complete -W "init start stop reconfigure clean help" cloud-cassandra.sh

function validate_config {
  return 0
}

function set_env_vars {
  echo "set env vars"
  export CASSANDRA_HOME="${CLOUD_CASSANDRA_HOME}/apache-cassandra-${pkg_cassandra_ver}"
}


if [[ -z "$JAVA_HOME" ]];then
  echo "ERROR: must set JAVA_HOME..."
  return 1
fi

# load configuration scripts
. "${CLOUD_CASSANDRA_HOME}/conf/cloud-cassandra.conf"
validate_config
set_env_vars


