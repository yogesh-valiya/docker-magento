#!/bin/bash

for var in "$@"; do
  docker-compose build $var
done