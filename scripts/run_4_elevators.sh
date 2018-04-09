#!/usr/bin/env bash

nodes=( one two three four )
port=15657

for node in "${nodes[@]}"
do
    #linux
    gnome-terminal -x sh -c "cd ${PWD}/../apps; ./SimElevatorServer --port $port; exec bash"
    gnome-terminal -x sh -c "cd ${PWD}/..; rebar3 shell --config config/$node.config --sname $node --setcookie bananpose --apps elevator; exec bash"

    port=$((port+1))
done
