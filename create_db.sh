#!/usr/bin/env bash

./bin/cockroach sql --echo-sql --insecure --host 192.168.63.21 --port 20656 < ./jalgoarena.sql