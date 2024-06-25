#!/bin/bash

git branch --merged develop | egrep -v "(^\*|master|develop|release)" | xargs git branch -d
