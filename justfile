set script-interpreter := ["nu"]
set shell := ["nu", "-c"]
# set default-script # TODO
set lazy

_default:
    @just --choose --chooser sk

deploy *ARGS:
    deploy {{ ARGS }} -- --log-format internal-json o+e>| nom --json
