![Le Wagon x Advent of Code](public/thumbnail.png)

```
Ruby    2.7.4  
Rails   6.1.4.1
```

## Advent of Code API

On `adventofcode.com`, a user can create one (and only one) private leaderboard. Up to 200 other users can join it using the generated code. A first room was already generated from the generic account `lewagon-aoc`.  

A JSON object containing scores can be fetched from a `GET` request that needs a session cookie to succeed. This session cookie is stored in the `SESSION_COOKIE` environment variable (valid ~ 1 month).

If this first room is filled and more than 200 people enter the contest, here is the "bypass" strategy:
  1. Create a new private leaderboard on Advent of Code, from another account
  2. Invite the `lewagon-aoc` account to that leaderboard
  3. Append the new leaderboard code (format: `9999999-a0b1c2d3`) to the `AOC_ROOMS` environment variable, comma-separated

## How to contribute

Found a bug? Have a feature request? Do not hesitate to [open an Issue](/../../issues/new).

If you want to help me fix a bug or implement a new requested feature:
1. Make sure [an Issue exists](/../../issues) for it
2. Fork the project
3. Code changes on your fork
4. Create a Pull Request here from your fork

### Overmind

Overmind is a tool to run the processes defined in a `Procfile` in different `tmux` sessions.
You can install the tool on your machine [following these instructions](https://github.com/DarthSim/overmind#installation).

Add these lines to your local `.env` file:
``` sh
OVERMIND_PROCFILE=Procfile.dev
OVERMIND_PORT=3000
```

Then, instead of the usual `rails s`, you can run `overmind s`.

### `.env` file

This file is used for development purposes. It is _not_ versioned and never should.

You can add an announcement banner with the `ANNOUNCEMENT` environment variable. Write the announcement text into the variable to make the banner appear:
```
ANNOUNCEMENT=We are aware of an issue regarding XXX. Work is in progress.
```
Let the variable *empty* to make the banner disappear.
