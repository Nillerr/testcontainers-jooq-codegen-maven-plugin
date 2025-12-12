#!/bin/bash
set -e

# Deployment script for Maven Central
# This script deploys the plugin to Maven Central with GPG signing
#
# Prerequisites:
# - GPG key configured at ~/.gnupg/private-key.asc
# - Maven settings configured at ~/.m2/settings.xml with:
#   - Maven Central credentials (server id: central)
#   - GPG passphrase (in gpg-signing profile)

echo "Starting deployment to Maven Central..."

# Run tests first
echo "Running tests..."
./mvnw clean test

# Deploy to Maven Central
echo "Deploying to Maven Central..."
./mvnw deploy -DskipTests

echo "Deployment complete!"
echo "Check your deployment status at: https://central.sonatype.com/"
