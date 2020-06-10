#!/bin/bash

SC=../../scripts

# cleanup

cd node0
$SC/docker_clean.sh y y n
cd ..

cd node1
$SC/docker_clean.sh y y n
cd ..

cd node2
$SC/docker_clean.sh y y n
cd ..

cd node3
$SC/docker_clean.sh y y n
cd ..

