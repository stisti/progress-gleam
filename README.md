# progress

This is a progress meter for unix pipelines, implemented in Gleam.

## Development

```sh
nix-shell     # If you do not have gleam
gleam build   # Build the project
seq 1000000 | gleam run >/dev/null # Test run
```
