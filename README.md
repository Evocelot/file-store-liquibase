# FileStore - liquibase

...

## Technologies used

- Docker / Podman
- Make
- mariadb:11.6.2
- liquibase:4.30-alpine

## Setup instructions

First, ensure that a running DBMS instance is available. To start a local `MariaDB` container, use the following command:

```bash
make start-mariadb-container
```

Once the MariaDB container is running, execute the following command to run the `Liquibase scripts`:

```bash
make start-liquibase-container
```

This command builds the appropriate image (tagged based on the `local.env` file), starts the container, and automatically stops it after execution.

> **_NOTE:_** Ensure that the MariaDB container is fully initialized before running the Liquibase command.

### Environment variables for Liquibase container

When running the application container, the following environment variables can be configured:


Environment variable | Sample value | Description |
--- | --- | --- |
CONTEXTS | local | Liquibase context to use for changesets |
DB_URL | jdbc:mariadb://evocelot-mariadb:3306/filestore | DBMS connection URL |
DB_USERNAME | root | DBMS username |
DB_PASSWORD | admin | DBMS password |
DB_DRIVER | org.mariadb.jdbc.Driver | JDBC driver |

> **_NOTE:_** Ensure that the `changelog` folder, containing `changelog.xml`, is copied to the `/liquibase/changelog` directory.

### Starting the DBMS Client (optional)

To start a DBMS client (phpMyAdmin) in a local container, run:

```bash
make start-phpmyadmin-container
```

> **_NOTE:_** The default username is `root` and the password is `admin` and the server name is `evocelot-mariadb`.

## DB initialization script

The `schema_local_create.sql` script is automatically executed when the `MariaDB container` starts. You can define the default schema and other initial settings here.

## local.env

The project includes a `local.env` file for storing application settings, with the following environment variables:

Environment variable | Sample value | Description |
--- | --- | --- |
IMAGE_NAME | file-store-liquibase | The name of the created image |
VERSION | 0.0.1-SNAPSHOT | The version number of the application |

## Building the Docker Image

To build the Docker image for this application, use the following command:

```bash
make build-liquibase-image
```

This command reads the configuration from the `local.env` file, builds the Docker image with the specified settings, and tags it according to the `IMAGE_NAME` and `VERSION` values in the configuration. The resulting image can then be used to run Liquibase containers with your database schema changes.
