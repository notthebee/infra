#!/bin/bash

# Keychain query fields.
# LABEL is the value you put for "Keychain Item Name" in Keychain.app.
LABEL="ansible-vault-password"
ACCOUNT_NAME="notthebee"

/usr/bin/security find-generic-password -w -a "$ACCOUNT_NAME" -l "$LABEL"
