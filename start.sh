#!/bin/bash

unicorn -c /usr/src/app/unicorn.rb -D
service amplify-agent start
nginx