# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

This is a Maven plugin that simplifies jOOQ code generation by using Testcontainers to spin up database containers and applying database migrations (via Flyway or Liquibase) before generating jOOQ classes. The plugin eliminates the need for developers to manually manage database instances for code generation.

**Key concept**: The plugin can either create a temporary Testcontainers database OR connect to an existing database (if JDBC parameters are fully provided in `jooq.jdbc` configuration).

## Build & Test Commands

### Build the plugin
```bash
mvn clean install
```

### Run tests
```bash
mvn test
```

### Run a single test
```bash
mvn test -Dtest=PluginTest#testPostgresFlywayPlugin
```

### Code formatting (Spotless)
The project uses Spotless with Palantir Java Format for code formatting. Spotless runs automatically during the `compile` phase.

```bash
# Check formatting
mvn spotless:check

# Apply formatting
mvn spotless:apply
```

### Testing the plugin locally
After building with `mvn clean install`, test it with one of the example projects:
```bash
cd examples/postgres-flyway-example
mvn clean package
```

The generated jOOQ code will be in `target/generated-sources/jooq/`.

## Architecture

### Plugin Execution Flow

1. **Plugin.java** (entry point - Maven Mojo)
   - Validates configuration (`database.type` is required)
   - Creates a custom Maven classloader to isolate plugin dependencies
   - Determines whether to spin up a container or use existing database via `TargetDatasource.createOrJoinExisting()`
   - Validates that only ONE migration tool (Flyway OR Liquibase) is configured
   - Runs migration → then generates jOOQ sources

2. **TargetDatasource** (datasource abstraction)
   - Interface with two implementations:
     - `ContainerTargetDatasource`: Spins up a Testcontainers database
     - `ExistingTargetDatasource`: Uses existing JDBC connection
   - Decision logic: If `jooq.jdbc` contains `url`, `user`, AND `password`, use existing database; otherwise spin up container

3. **DatabaseProvider** → **DatabaseProps** → **DatabaseType**
   - Factory for creating appropriate Testcontainers instances
   - Supports: `POSTGRES`, `MYSQL`, `MARIADB`
   - Handles default container images, credentials, and database names

4. **MigrationRunner** (interface)
   - Two implementations: `FlywayRunner` and `LiquibaseRunner`
   - Delegates to the underlying migration tool's API
   - Configured via plugin parameters (`<flyway/>` or `<liquibase/>` in pom.xml)

5. **JooqGenerator**
   - Wraps jOOQ's `GenerationTool`
   - Automatically injects JDBC connection from TargetDatasource
   - Sets up jOOQ configuration and adds generated sources to Maven compile path

### Package Structure

```
org.testcontainers.jooq.codegen/
├── Plugin.java                    # Maven Mojo entry point
├── database/
│   ├── DatabaseProps.java         # Database configuration parameters
│   ├── DatabaseType.java          # Enum: POSTGRES, MYSQL, MARIADB
│   └── DatabaseProvider.java      # Factory for Testcontainers instances
├── datasource/
│   ├── TargetDatasource.java      # Interface for database source
│   ├── ContainerTargetDatasource.java
│   └── ExistingTargetDatasource.java
├── jooq/
│   ├── JooqGenerator.java         # jOOQ code generation orchestration
│   └── JooqProps.java             # jOOQ configuration parameters
├── migration/runner/
│   ├── MigrationRunner.java       # Interface for migration tools
│   ├── FlywayRunner.java          # Flyway implementation
│   ├── LiquibaseRunner.java       # Liquibase implementation
│   └── RunnerProperties.java      # Shared properties for runners
└── util/
    └── OptionalUtils.java         # Utility for Optional operations
```

## Key Configuration Details

### Plugin Configuration (in user's pom.xml)

The plugin requires:
1. **database** block with `type` (required)
2. **jooq** block with `generator` (required)
3. **flyway** OR **liquibase** block (exactly one required)

### Classloader Management

The plugin creates a custom URLClassLoader from Maven's runtime classpath to isolate plugin dependencies. This allows the plugin to use the database drivers and migration tools from the user's project dependencies.

**Important**: Always restore the original classloader in the finally block (`Plugin.java:107-114`).

## Testing

Tests use Maven Plugin Testing Harness with test POM files located in `src/test/resources/pom/`. Each test subdirectory contains:
- `pom.xml` - Plugin configuration
- Migration scripts (in standard Flyway/Liquibase locations)

Test structure:
- `PluginTest.java` - Main integration tests
- `MavenProjectAssert.java` - Custom AssertJ assertions for Maven projects
- `Common.java` - Shared test utilities

## Project Version & Release

- Current version: 0.0.5 (in `pom.xml:10`)
- Group ID: `io.github.nillerr`
- Uses JReleaser for Maven Central deployment
- Release process documented in `RELEASING.md`

## Important Implementation Notes

- The plugin is thread-safe (`@Mojo threadSafe = true`)
- Uses `@Inject` for dependency injection (Maven's built-in DI)
- Lombok is used for builders and data classes
- Database containers are managed as AutoCloseable resources (try-with-resources in `Plugin.java:68`)
- JDBC drivers must be added as plugin dependencies in user's pom.xml
