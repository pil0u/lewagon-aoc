![Le Wagon x Advent of Code](public/thumbnail.png)

```
Ruby    3.3.10
Rails   7.2.2.2
```

Found a bug? Please [open an Issue](/../../issues/new).<br>
Have a feature request? Let's discuss it [on Slack](slack://user?team=T02NE0241&id=URZ0F4TEF).

# Contribute

If you want to help me fix a bug or implement a new requested feature:
1. Make sure [an Issue exists](/../../issues) for it
2. Ask me questions
3. Fork the project
4. Code the changes on your fork
5. Create a Pull Request here from your fork

## CI with GitHub Actions

Upon Pull Request actions (open, push), CI scripts are automatically run tests, linters and security tools. **All the checks shall pass for your PR to be reviewed.**

## Run on your machine

1. Run `bin/setup` to install dependencies, create and seed the database
2. Ask me for the credentials key on Slack and add it to `config/master.key` (required for Kitt OAuth)
3. Create a `.env` root file and add these keys with their [appropriate values](#required-env-variables): `AOC_ROOMS`, `SESSION_COOKIE`
4. Run `bin/dev`

### Required `ENV` variables

> [!CAUTION]
> The `.env` file is used for development purposes only. It is _not_ versioned and never should.

- `POSTGRES_USER` and `POSTGRES_PASSWORD` should be set accordingly to your db config. If you're using the [Docker dev env](#docker-dev-env) you can omit those.
- `AOC_ROOMS` is a comma-separated list of [private leaderboard](https://adventofcode.com/leaderboard/private) IDs that _you belong_ to (e.g. `9999999-a0b1c2d3,7777777-e4f56789`)
- `SESSION_COOKIE` is your own Advent of Code session cookie (valid ~ 1 month). You need to [log in](https://adventofcode.com/auth/login) to the platform, then retrieve the value of the `session` cookie (e.g. `436088a9...9ffb6476`)

### Docker dev env

You can also run the app in a Docker container. A `docker-compose.yml` file is provided for this purpose. The ENV variables are still required and should be added to the `.env` file.
A small CLI is provided for common use-cases: `bin/ddev` (see usage for more details).

### Overmind (optional)

> [!NOTE]
> Foreman is the default process manager through the `bin/dev` command. Overmind is an optional alternative.

Overmind is a process manager for Procfile-based applications like ours, based on `tmux`. You can install the tool on your machine [following these instructions](https://github.com/DarthSim/overmind#installation).

Add these lines to your local `.env` file:
```zsh
OVERMIND_PORT=3000
OVERMIND_PROCFILE=Procfile.dev
```

Then, instead of the usual `bin/dev`, you have to run `overmind s`.

### Use SSL

In short: create an SSL certificate for your localhost, store it in your keychain and run the server using that certificate.

On macOS:
```zsh
mkcert localhost
sudo security add-trusted-cert -d -r trustRoot -k /Library/Keychains/System.keychain ./localhost.pem
```

On Ubuntu:
```zsh
sudo apt install openssl
openssl req -x509 -newkey rsa:2048 -nodes -keyout localhost-key.pem -out localhost.pem -days 365 -subj "/C=FR/ST=State/L=Locality/O=Organization/CN=localhost"
```

Finally, move the generated files to the `tmp` folder in the project root and start the server with `bin/dev ssl`.
```zsh
mv localhost* tmp/
bin/dev ssl
```

## Launch the webapp on local mobile browser

Because the OAuth will not work on your local IP, you have to bypass authentication. For example, you could **temporarily** add this line in the `welcome` controller method:
```ruby
sign_in(User.find_by(github_username: "your_username"))
```

Then, find the local IP address of the computer you launch the server from (ex: `192.168.1.14`) and open the app on your mobile browser from that IP (ex: `http://192.168.1.14:3000`)

> [!CAUTION]
> Bypassing authentication, even temporarily, can pose significant security risks. Only use this method in a controlled development environment and never in production.

# Advent of Code API

On `adventofcode.com`, a user can create one (and only one) private leaderboard. Up to 200 users can join it using a unique generated code.

A JSON object containing scores can be fetched from a `GET` request that needs a session cookie to succeed. We store this session cookie in the `SESSION_COOKIE` environment variable (valid ~ 1 month).

We use multiple private leaderboards to run the platform with more than 200 participants. We store their IDs in the `AOC_ROOMS` environment variable, comma-separated. One account joins all of them, and we use this account's `SESSION_COOKIE`.

# License

[MIT](LICENSE)
