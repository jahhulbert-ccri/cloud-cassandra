#!/usr/bin/env bash

# thanks accumulo for these resolutions snippets
# Start: Resolve Script Directory
SOURCE="${BASH_SOURCE[0]}"
while [ -h "${SOURCE}" ]; do # resolve $SOURCE until the file is no longer a symlink
   bin="$( cd -P "$( dirname "${SOURCE}" )" && pwd )"
   SOURCE="$(readlink "${SOURCE}")"
   [[ "${SOURCE}" != /* ]] && SOURCE="${bin}/${SOURCE}" # if $SOURCE was a relative symlink, we need to resolve it relative to the path where the symlink file was located
done
bin="$( cd -P "$( dirname "${SOURCE}" )" && pwd )"
script=$( basename "${SOURCE}" )
# Stop: Resolve Script Directory

# Start: config
. "${bin}"/config.sh

# Check config
if ! validate_config; then
  echo "Invalid configuration"
  exit 1
fi

# check java home
if [[ -z "$JAVA_HOME" ]];then
  echo "must set JAVA_HOME..."
  exit 1
fi
# Stop: config

# import port checking
#. "${bin}"/check_ports.sh

function download_packages() {
  # get stuff
  echo "Downloading packages from internet..."
  mkdir ${CLOUD_CASSANDRA_HOME}/pkg # todo check to see if this exists
  
  local mirror
  if [ -z ${pkg_src_mirror+x} ]; then
    local mirror=$(curl 'https://www.apache.org/dyn/closer.cgi' | grep -o '<strong>[^<]*</strong>' | sed 's/<[^>]*>//g' | head -1)
  else
    local mirror=${pkg_src_mirror}
  fi
  echo "Using mirror ${mirror}"

  local maven=${pkg_src_maven}

  declare -a urls=("${mirror}/cassandra/${pkg_cassandra_ver}/apache-cassandra-${pkg_cassandra_ver}-bin.tar.gz")

  for x in "${urls[@]}"; do
      fname=$(basename "$x");
      echo "fetching ${x}";
      wget -c -O "${CLOUD_CASSANDRA_HOME}/pkg/${fname}" "$x";
  done 
}

function unpackage {
  echo "Unpackaging software..."
  (cd -P "${CLOUD_CASSANDRA_HOME}" && tar xvf "${CLOUD_CASSANDRA_HOME}/pkg/apache-cassandra-${pkg_cassandra_ver}-bin.tar.gz")
}

function configure {
  mkdir -p "${CLOUD_CASSANDRA_HOME}/tmp/staging"

  rm -rf ${CLOUD_CASSANDRA_HOME}/tmp/staging
}

function start_first_time {
  # check ports
#  check_ports
  echo
}

function start_cloud {
  # Check ports
#  check_ports
  echo 
}

function stop_cloud {
 echo
}

function clear_sw {
  rm -rf "${CLOUD_CASSANDRA_HOME}/apache-cassandra-${pkg_cassandra_ver}"
  rm -rf "${CLOUD_CASSANDRA_HOME}/tmp"
}

function clear_data {
  # TODO prompt
  echo
}

function show_help {
  echo "Provide 1 command: (init|start|stop|reconfigure|clean|help)"
}

if [ "$#" -ne 1 ]; then
  show_help
  exit 1
fi

if [[ $1 == 'init' ]]; then
  download_packages && unpackage && configure && start_first_time
elif [[ $1 == 'reconfigure' ]]; then
  echo "reconfiguring..."
  #TODO ensure everything is stopped? prompt to make sure?
  clear_sw && clear_data && unpackage && configure && start_first_time
elif [[ $1 == 'clean' ]]; then
  echo "cleaning..."
  clear_sw && clear_data
  echo "cleaned!"
elif [[ $1 == 'start' ]]; then
  echo "Starting cloud..."
  start_cloud
  echo "Cloud Started"
elif [[ $1 == 'stop' ]]; then
  echo "Stopping Cloud..."
  stop_cloud
  echo "Cloud stopped"
else
  show_help
fi



