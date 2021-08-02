# lewagon_aoc
```
Ruby    2.7.4  
Rails   6.1.4
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
