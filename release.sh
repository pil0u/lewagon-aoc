#!/usr/bin/env bash

set -euo pipefail

printf "\n⏳[Release Phase]: Running database migrations.\n"
bundle exec rails --trace db:migrate

printf "\n🎉[Release Phase]: Database is up to date.\n"
