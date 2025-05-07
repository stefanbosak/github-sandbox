#!/bin/bash
cwd=$(dirname $(realpath "${0}"))

# stop all standalone Docker containers
docker container stop $(docker container ls --filter "name=runner-*" -q)
