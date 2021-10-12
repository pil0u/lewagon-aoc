![Le Wagon x Advent of Code](public/thumbnail.png)

```
Ruby    2.7.4  
Rails   6.1.4.1
```
## `.env` file

This file is mainly used for development purposes. It is _not_ versioned and never should.

## Overmind

Overmind is a tool to run the processes defined in a `Procfile` in different `tmux`.
You can install the tool on your machine [following these instructions](https://github.com/DarthSim/overmind#installation).

Add these lines to your local `.env` file:
``` sh
OVERMIND_PROCFILE=Procfile.dev
OVERMIND_PORT=3000
```

Then, instead of the usual `rails s`, you can run `overmind s`.

## Advent of Code API

On AoC platform, a user can create one (and only one) private leaderboard. Up to 200 other users can join it using the generated code. A first room is already generated (`1452182-0da1d2d6`) from the generic account `lewagon-aoc` and can be joined.  

A JSON object containing scores can be fetched from a `GET` request that needs a session cookie to succeed. This session cookie is stored in the `SESSION_COOKIE` environment variable (valid ~ 1 month).

If this first room is totally filled and more than 200 people enter the contest, here is the "bypass" strategy:
  1. Create a new private leaderboard on AoC, from another account
  2. Invite the `lewagon-aoc` account to that leaderboard
  3. Append the new leaderboard code (9999999-a0b1c2d3) to the `AOC_ROOMS` environment variable, comma-separated
