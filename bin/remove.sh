#!/bin/bash

for var in "$@"; do
  docker kill $var
  docker rm $var
done