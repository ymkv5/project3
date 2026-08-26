#!/bin/bash

# Variables
VAULT_ADDR='http://127.0.0.1:8200'
VAULT_TOKEN="$(awk -F': ' '/Initial Root Token:/ {print $2}' "$HOME/Desktop/project3/vault/key")"
SECRET_PATH='kv/project3'
ENV_FILE='/home/aau/Desktop/project3/.env'

export VAULT_ADDR
export VAULT_TOKEN

echo "Retrieving secrets from Vault..."

SECRETS=$(docker exec \
  -e VAULT_ADDR=http://127.0.0.1:8200 \
  -e VAULT_TOKEN="$VAULT_TOKEN" \
  vault-project3 \
  vault kv get -format=json "$SECRET_PATH")

if [ $? -ne 0 ]; then
  echo "Failed to retrieve secrets from Vault."
  exit 1
fi

echo "Saving secrets to $ENV_FILE..."

echo "$SECRETS" | jq -r \
  '.data.data | to_entries[] | .key + "=" + (.value|tostring)' \
  > "$ENV_FILE"

if [ $? -ne 0 ]; then
  echo "Failed to save secrets to $ENV_FILE."
  exit 1
fi

echo "Secrets saved successfully."

echo "Running Docker containers..."
docker compose --env-file "$ENV_FILE" up -d --build
