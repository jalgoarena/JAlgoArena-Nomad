#!/usr/bin/env bash
cockroach sql --echo-sql --insecure --host $(hostname -I | awk '{print $1}') --port specify_port < ./jalgoarena.sql