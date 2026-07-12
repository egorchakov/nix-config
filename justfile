set script-interpreter := ["nu"]
set shell := ["nu", "-c"]
set default-script
set lazy

_default:
    just --list

deploy *ARGS:
    deploy {{ ARGS }} -- --log-format internal-json o+e>| nom --json
