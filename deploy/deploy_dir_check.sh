#!/bin/bash

if [ -d "deploy" ]; then
echo "found deploy directory"
else
echo "mkdir deploy"
mkdir deploy
fi