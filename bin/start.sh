#!/bin/bash

for var in "$@"; do
  docker-compose up -d $var
done
