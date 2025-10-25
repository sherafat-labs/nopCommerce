#!/bin/bash

# Environment setup script for nopCommerce

if [ ! -f ".env" ]; then
    echo "Creating .env file from template..."
    cp .env.example .env
    echo "Please edit .env file and set your configuration values."
    chmod 600 .env
else
    echo ".env file already exists."
fi

# Validate environment variables
echo "Checking environment variables..."
if [ -f ".env" ]; then
    source .env
    if [ -z "$POSTGRES_PASSWORD" ] || [ "$POSTGRES_PASSWORD" = "change_this_to_secure_password" ]; then
        echo "WARNING: Please set a secure database password in .env file"
    fi
fi

echo "Environment setup complete."