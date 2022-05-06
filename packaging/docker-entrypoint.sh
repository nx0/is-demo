#!/bin/bash -i

export NVM_DIR="$HOME/.nvm"
. "$NVM_DIR/nvm.sh"

# Application warm up
cd /opt/instant-search-demo
nvm install 9.11.2
nvm use
npm install
npm start
open http://localhost:3000
