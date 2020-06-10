#!/bin/bash


# cleanup

docker stop ton-node-n0
docker rm ton-node-n0
docker volume rm tondb0

docker stop ton-node-n1
docker rm ton-node-n1
docker volume rm tondb1

docker stop ton-node-n2
docker rm ton-node-n2
docker volume rm tondb2

docker stop ton-node-n3
docker rm ton-node-n3
docker volume rm tondb3

