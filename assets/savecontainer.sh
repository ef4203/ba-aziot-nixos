#!/bin/bash

# Sets the script to fail if any subcommand fails
set -e

# Pulls the image from the registry
docker pull $1

# Saves the image to a tar file
docker save -o $(echo "$1" | sed 's/:/_/g').tar $1

# Compresses the tar file with gzip
gzip $(echo "$1" | sed 's/:/_/g').tar
