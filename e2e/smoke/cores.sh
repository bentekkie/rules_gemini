#!/bin/env sh

echo "{"
echo "  \"cores:\" : "
nproc --all
echo "}"
