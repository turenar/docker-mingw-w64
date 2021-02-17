#!/bin/bash -eux
docker build -t turenar/mingw-w64:amd64 . --pull
docker build -t turenar/mingw-w64:i686 . --build-arg TARGET_BITS=32 --pull
