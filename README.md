# progress

This is a progress meter for unix pipelines, implemented in Gleam.

I made progress originally in C to solve a need I had 30 years ago.
Since then I have used it as a kind of "kata" and implemented
it in several languages.

## Development

```sh
nix-shell     # If you do not have gleam
gleam build   # Build the project
seq 1000000 | gleam run >/dev/null # Test run
```
