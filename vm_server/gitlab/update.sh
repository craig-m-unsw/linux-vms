#!/usr/bin/env sh

# update gitlab image
docker compose pull
docker compose up -d --remove-orphans
docker image prune