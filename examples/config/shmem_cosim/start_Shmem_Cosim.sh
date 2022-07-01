#!/bin/bash

set -x

_stop() {
	echo "Caught SIGTSTP signal!"
	kill -TSTP ${CHILD0} ${CHILD1} 2>/dev/null
}

_cont() {
	echo "Caught SIGCONT signal!"
	kill -CONT ${CHILD0} ${CHILD1} 2>/dev/null
}

_term() {
	echo "Caught SIGTERM signal!"
	kill -TERM ${CHILD0} ${CHILD1} 2>/dev/null
}

_kill() {
	echo "Caught SIGKILL signal!"
	kill -KILL ${CHILD0} ${CHILD1} 2>/dev/null
}

trap _stop SIGTSTP
trap _cont SIGCONT
trap _term SIGTERM
trap _kill SIGKILL

CHILDS=""

# Start time
# TIME=$(date -d "+10 seconds" +%Y%m%dT%H%M%S) #-Iseconds
# echo "Start simulation at: $TIME"

# Simulation params
# OPTS="--timestep 1 --duration $((300)) --system-freq 50 --start-at $TIME --solver-domain SP --solver-type NRP"
# echo "Simulation params: $OPTS"

OPTS0="0"
OPTS1="1"

CPS_LOG_PREFIX0="[Sys ] " \
/build/Examples/Cxx/ShmemDistributedDirect $OPTS0 & P0=$!

echo "Process 0 ID: $P0"

CPS_LOG_PREFIX1="[Sys ] " \
/build/Examples/Cxx/ShmemDistributedDirect $OPTS1 & P1=$!

CHILD0=$P0
CHILD1=$P1

sleep 2

# if true; then
# 	VILLAS_LOG_PREFIX="[Pipe] " \
# 	#villas-pipe Configs/Shmem_CIGRE_MV.conf dpsim1
# 	villas-node build/_deps/villas-dpsim-src/examples/config/shmem_CIGRE_MV_PF/Shmem_CIGRE_MV.conf
# else
# 	VILLAS_LOG_PREFIX="[Node] " \
# 	villas-node build/_deps/villas-dpsim-src/examples/config/shmem_CIGRE_MV_PF/Shmem_CIGRE_MV.conf & VN=$!
# fi

# Wait until all child processed finished
while (( $(ps --no-headers -o pid --ppid=$$ | wc -w) > 1 )); do
	wait
done
