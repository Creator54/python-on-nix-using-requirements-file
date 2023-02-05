#!/usr/bin/env bash

#https://dev.to/allenap/some-direnv-best-practices-actually-just-one-4864
if ! [[ -f ./.envrc.cache ]]; then
  nix-shell --run 'direnv dump > .envrc.cache'
fi
