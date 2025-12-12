# AGENTS.md - Testcontainers jOOQ Codegen Maven Plugin

## Build & Test Commands

```bash
# Build the plugin
mvn clean install

# Run all tests
mvn test

# Run a single test
mvn test -Dtest=PluginTest#testPostgresFlywayPlugin

# Check code formatting
mvn spotless:check

# Apply code formatting
mvn spotless:apply
```

## Code Style Guidelines

- **Formatting**: Use Palantir Java Format via Spotless
- **Imports**: Organize imports alphabetically, group static imports
- **Types**: Use Lombok for data classes and builders
- **Naming**: Follow Java conventions (camelCase for methods/variables, PascalCase for classes)
- **Error Handling**: Use try-with-resources for AutoCloseable resources
- **Thread Safety**: Mark thread-safe components with `@Mojo(threadSafe = true)`
- **Dependencies**: Isolate plugin dependencies using custom classloader
- **Testing**: Use Maven Plugin Testing Harness with test POMs in `src/test/resources/pom/`

## Architecture Notes

- Plugin entry point: `Plugin.java` (Maven Mojo)
- Database abstraction: `TargetDatasource` interface
- Migration runners: `FlywayRunner` and `LiquibaseRunner`
- jOOQ generation: `JooqGenerator` wraps jOOQ's GenerationTool
- Database providers: `DatabaseProvider` factory pattern

## Important Patterns

- Always restore original classloader in finally blocks
- Use `@Inject` for Maven dependency injection
- Database containers managed as AutoCloseable resources
- Single migration tool (Flyway OR Liquibase) required