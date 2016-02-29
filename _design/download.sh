#!/bin/bash

curl -sX GET http://127.0.0.1:5984/lurker/_design/analysis |jq . > analysis.json
