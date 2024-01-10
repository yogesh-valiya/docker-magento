#!/bin/bash

for var in "$@"; do
  docker kill $var
done