#!/bin/bash
sed --regexp-extended "s/}\" TargetNetId=\"[0-9.]+\"/}\" /g" "$@"