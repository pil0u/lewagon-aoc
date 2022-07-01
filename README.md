![Le Wagon x Advent of Code](public/thumbnail.png)

```
Ruby    3.1.2  
Rails   7.0.3
```

Found a bug? Do not hesitate to [open an Issue](/../../issues/new).  
Have a feature request? Let's discuss it [on Slack](slack://channel?team=T02NE0241&id=C02PN711H09).

## Contribute

If you want to help me fix a bug or implement a new requested feature:
1. Make sure [an Issue exists](/../../issues) for it
2. Fork the project
3. Code the changes on your fork
4. Create a Pull Request here from your fork

### Run on your machine

1. Run `bin/setup` to install dependencies, create and seed the database
2. [Ask me](slack://user?team=T02NE0241&id=URZ0F4TEF) for the credentials key and add it to `config/master.key`, required for Kitt OAuth
3. Create a `.env` root file and add these keys with their [appropriate values](#env-variables): `AOC_ROOMS`, `EVENT_YEAR`, `SESSION_COOKIE`
4. Run `bin/dev`

### `ENV` variables

> **Warning**  
The `.env` file is used for development purposes only. It is _not_ versioned and never should.

#### Required

- `AOC_ROOMS` is a comma-separated list of [private leaderboard](https://adventofcode.com/leaderboard/private) IDs that _you belong_ to (e.g. `9999999-a0b1c2d3,7777777-e4f56789`)
- `EVENT_YEAR` can take any [existing event](https://adventofcode.com/events) value (e.g. `2021`)
- `SESSION_COOKIE` is your own Advent of Code session cookie (valid ~ 1 month). You need to [log in](https://adventofcode.com/2021/auth/login) to the platform, then retrieve the value of the `session` cookie (e.g. `436088a93cbdba07668e76df6d26c0dcb4ef3cbd5728069ffb647678ad38`)

#### Optional

- `ANNOUNCEMENT` is a short text to display in a fixed banner across the website (e.g. `ANNOUNCEMENT=We are aware of an issue regarding XXX. Work is in progress.`)
- `OVERMIND_PORT` and `OVERMIND_PROCFILE` if you use [overmind](#overmind)

### Overmind

> **Note**  
> Foreman is the default process manager through the `bin/dev` command. Overmind is an optional alternative.

Overmind is a process manager for Procfile-based applications like ours, based on `tmux`.
You can install the tool on your machine [following these instructions](https://github.com/DarthSim/overmind#installation).

Add these lines to your local `.env` file:
``` zsh
OVERMIND_PORT=3000
OVERMIND_PROCFILE=Procfile.dev
```

Then, instead of the usual `bin/dev`, you can run `overmind s`.

## Advent of Code API hacking

On `adventofcode.com`, a user can create one (and only one) private leaderboard. Up to 200 other users can join it using the generated code. A first room was already generated from the generic account `lewagon-aoc`.  

A JSON object containing scores can be fetched from a `GET` request that needs a session cookie to succeed. This session cookie is stored in the `SESSION_COOKIE` environment variable (valid ~ 1 month).

If this first room is filled and more than 200 people enter the contest, here is the "bypass" strategy:
  1. Create a new private leaderboard on Advent of Code, from another account
  2. Invite the `lewagon-aoc` account to that leaderboard
  3. Append the new leaderboard code (format: `9999999-a0b1c2d3`) to the `AOC_ROOMS` environment variable, comma-separated
