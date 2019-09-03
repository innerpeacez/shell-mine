#! /bin/bash
# 远程节点信息
nodes=`cat node.txt`
# 需要远程执行的脚本文件
script=$1
# 远程节点存放脚本的路径
script_path=$2

scp_script() {
  local _node=$1
  ssh $_node  "mkdir -p ${script_path}"
  scp ./$script $_node:${script_path}/${script}
}

run_script() {
  local _node=$1
  ssh $_node "/bin/bash ${script_path}/${script}"
}

remove_remote_script() {
  local _node=$1
  ssh $_node "sudo rm -rf ${script_path}/"
}

log() {
  echo `date "+%Y-%m-%d %H:%M:%S"` ':' $1
}

start_job() {
  if [ -z "$nodes" ] 
  then
    log "node is empty"
    exit 1
  fi

  if [ -z "$script" ]
  then 
    log "script is empty"
    exit 1
  fi

  if [ -z "$script_path" ]
  then
    log "script_path is empty"
    exit 1
  fi

  local _nodes=$nodes
  for node in $_nodes;
  do
    scp_script $node
    run_script $node
    remove_remote_script $node
    echo "$node success"
  done
}

start_job