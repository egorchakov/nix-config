set shell := ["nu", "-c"]
set script-interpreter := ["nu"]
set lazy

_default:
    @just --choose --chooser sk

deploy *ARGS:
    deploy {{ ARGS }} -- --log-format internal-json o+e>| nom --json
