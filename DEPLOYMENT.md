# Deployment Guide

This guide explains how to deploy the plugin to Maven Central.

## Prerequisites

1. **GPG Key Setup**
   - GPG key located at: `~/.gnupg/private-key.asc`
   - Key must be valid (not expired)
   - Key ID: `0xBA7B56AD454AEA2E71DFE7E92E15B94C3D3BC15B`

2. **Maven Settings**
   - Maven Central credentials and GPG passphrase configured in `~/.m2/settings.xml`:
     ```xml
     <servers>
         <server>
             <id>central</id>
             <username>YOUR_USERNAME</username>
             <password>YOUR_PASSWORD</password>
         </server>
     </servers>

     <profiles>
         <profile>
             <id>gpg-signing</id>
             <properties>
                 <gpg.passphrase>YOUR_GPG_PASSPHRASE</gpg.passphrase>
             </properties>
         </profile>
     </profiles>

     <activeProfiles>
         <activeProfile>gpg-signing</activeProfile>
     </activeProfiles>
     ```

## Deployment Methods

### Method 1: Using the Deployment Script (Recommended)

```bash
# Run the deployment script
./deploy.sh
```

### Method 2: Manual Deployment

```bash
# Clean, test, and deploy
./mvnw clean test
./mvnw deploy -DskipTests
```

**Note**: The GPG passphrase is automatically read from `~/.m2/settings.xml` via the `gpg.passphrase` property.

## Troubleshooting

### GPG Key Expired

If you see an error about the GPG key being expired:

```bash
# Edit the key to extend expiration
gpg --edit-key 2E15B94C3D3BC15B
# Type: expire
# Choose new expiration (e.g., 2y for 2 years)
# Type: save

# Also extend the subkey
gpg --edit-key 2E15B94C3D3BC15B
# Type: key 1
# Type: expire
# Choose new expiration
# Type: save

# Export the updated key
gpg --armor --export-secret-keys 2E15B94C3D3BC15B > ~/.gnupg/private-key.asc
chmod 600 ~/.gnupg/private-key.asc
```

### Invalid Armor Header

If you see "invalid armor header", ensure the private key file has a blank line after the header:

```
-----BEGIN PGP PRIVATE KEY BLOCK-----
<blank line here>
<key data>
```

### Missing Passphrase

If deployment fails with "Secret key is encrypted - keyPass is required" or "Sign - key not found":

1. Verify the `gpg.passphrase` property is defined in `~/.m2/settings.xml`
2. Ensure the `gpg-signing` profile is active
3. Check that the passphrase matches the key's passphrase

## Deployment Process

The deployment process:

1. **Build & Sign**: Maven compiles, packages, and signs all artifacts (jar, sources, javadoc, pom)
2. **Install**: Artifacts are installed to local Maven repository
3. **Upload**: Central Publishing plugin uploads artifacts to Maven Central
4. **Publish**: Artifacts are automatically published (if `autoPublish=true`)

## Verifying Deployment

After deployment, verify your artifact at:
- Maven Central Search: https://search.maven.org/
- Sonatype Central Portal: https://central.sonatype.com/

Allow up to 30 minutes for the artifact to appear in Maven Central search.

## Release Checklist

- [ ] Update version in `pom.xml`
- [ ] Update `CHANGELOG.md` with release notes
- [ ] Commit all changes
- [ ] Create a git tag: `git tag -a v0.0.5 -m "Release 0.0.5"`
- [ ] Set GPG_PASSPHRASE environment variable
- [ ] Run deployment: `./deploy.sh`
- [ ] Push commits and tags: `git push && git push --tags`
- [ ] Verify artifact on Maven Central
- [ ] Create GitHub release with release notes
