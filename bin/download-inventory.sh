#!/bin/bash

INVENTOPY_CLI_PATH="bin/inventorpy-cli/"

while getopts v:s:n:h flag; do
  case $flag in
    n) network="$OPTARG";
      ;;
    s) server=$OPTARG;
      ;;
    v) virtualserver=$OPTARG;
      ;;
    h) help=1;
      ;;

    ?)
      exit;
      ;;
  esac
done

server_hostname=""
if [ "x$server" != "x" ] ; then
  server_json=$(cd $INVENTOPY_CLI_PATH ; ./inventorpy-get-item-by-id.sh server "$server" 2>/dev/null | jq . )
  server_hostname=$(echo $server_json | jq .hostname | sed 's/\"//ig')
  if [ "x$server_hostname" != "x" ] ; then
    echo "$server_json" > "configs/${server_hostname}-server.json"
    echo "updated: configs/${server_hostname}-server.json"
  else
    echo "failed to get server config"
    exit -1
  fi
  network=$(echo $server_json | jq .network_id | sed 's/\"//ig')

fi


if [ "x$virtualserver" != "x" ] ; then
  vserver_json=$(cd $INVENTOPY_CLI_PATH ; ./inventorpy-get-item-by-id.sh virtual_server "$virtualserver" 2>/dev/null | jq . )
  vserver_hostname=$(echo $vserver_json | jq .hostname | sed 's/\"//ig')
  if [ "x$vserver_hostname" != "xnull" ] ; then
    echo "$vserver_json" > "configs/${vserver_hostname}-server.json"
    echo "updated: configs/${vserver_hostname}-server.json"
  else
    echo "failed to get server config"
    exit -1
  fi
  network=$(echo $vserver_json | jq .network_id | sed 's/\"//ig')
  server_hostname="${vserver_hostname}"

fi

if [ "x$network" != "x" ] ; then

  network_json=$(cd $INVENTOPY_CLI_PATH ; ./inventorpy-get-item-by-id.sh network "$network" 2>/dev/null | jq . )
  if [ "x$network_json" != "x" ] ; then
    echo "$network_json" > "configs/${server_hostname}-network.json"
    echo "updated: configs/${server_hostname}-network.json"
  else
    echo "failed to get network config"
    exit -1
  fi
fi

if [ "x$help" != "x" ] ; then
  echo "call with -s server-id from inventory to download server conf"
  echo "call with -v virtualserver-id from inventory to download server conf"
  echo "call with -n network-id from inventory to download network conf"
fi
