include local.env
export $(shell sed 's/=.*//' local.env)

NETWORK_NAME=evocelot-network

# Creates podman network.
create-podman-network:
	@echo "[>>>] Creating podman network"
	@podman network create $(NETWORK_NAME) 2>/dev/null || \
		echo "There is no need to create the network named $(NETWORK_NAME) because it already exists.";
	@echo "[<<<]"

# Deletes the created podman network.
delete-podman-network:
	@echo "[>>>] Deleting podman network"
	@podman network rm $(NETWORK_NAME) 2>/dev/null || \
		echo "The network named $(NETWORK_NAME) cannot be deleted."
	@echo "[<<<]"

# Builds the docker image.
build-liquibase-image:
	@echo "[>>>] Building the docker image"
	@podman build -t $(IMAGE_NAME):$(VERSION) . -f Dockerfile.prod
	@echo "[<<<]"

# Starts local mariadb container.
start-mariadb-container: create-podman-network stop-mariadb-container build-docker-image
	@echo "[>>>] Starting mariadb container"
	@podman run -d \
		--name evocelot-mariadb \
		--network $(NETWORK_NAME) \
		-p 3306:3306 \
		-e MARIADB_ROOT_PASSWORD=admin \
      	-e TZ=Europe/Budapest \
      	-e LANG=C.UTF-8 \
      	-e LC_ALL=C.UTF-8 \
  		-v ./schema_local_create.sql:/docker-entrypoint-initdb.d/schema_local_create.sql:ro \
		mariadb:11.6.2;
	@echo "evocelot-mariadb started at: http://localhost:3306"
	@echo "[<<<]"

# Stops the local mariadb container.
stop-mariadb-container:
	@echo "[>>>] Stopping the evocelot-mariadb container"
	@podman rm -f evocelot-mariadb
	@echo "[<<<]"

# Builds the image of the liquibase app and starts the container.
start-liquibase-container: build-docker-image create-podman-network
	@echo "[>>>] Starting liquibase container"
	@podman run \
		--network $(NETWORK_NAME) \
		-e CONTEXTS=local \
		-e DB_URL=jdbc:mariadb://evocelot-mariadb:3306/filestore \
		-e DB_USERNAME=root \
		-e DB_PASSWORD=admin \
		-e DB_DRIVER=org.mariadb.jdbc.Driver \
		-v ./changelog:/liquibase/changelog \
		$(IMAGE_NAME):$(VERSION)
	@echo "[<<<]"

# Starts the local phpmyadmin container.
start-phpmyadmin-container: stop-phpmyadmin-container
	@echo "[>>>] Starting phpmyadmin container"
	@podman run -d \
		--name evocelot-phpmyadmin \
		--network $(NETWORK_NAME) \
		-p 8000:80 \
		-e PMA_ARBITRARY=1 \
  		--restart always \
  		phpmyadmin:5.2.1;
	
	@echo "evocelot-phpmyadmin started at: http://localhost:8000"
	@echo "[<<<]"

# Stops the local phpmyadmin container.
stop-phpmyadmin-container:
	@echo "[>>>] Stopping the evocelot-phpmyadmin container"
	@podman rm -f evocelot-phpmyadmin
	@echo "[<<<]"

# Starts local postgresql container
start-postgres-container: create-podman-network stop-postgres-container
	mkdir -p evocelot-postgres-data
	@echo "[>>>] Starting postgresql container"
	@podman run -d \
		--name evocelot-postgres \
		--network $(NETWORK_NAME) \
		-p 5432:5432 \
		-e POSTGRES_DB=filestore \
		-e POSTGRES_USER=admin \
		-e POSTGRES_PASSWORD=admin \
		-e TZ=Europe/Budapest \
		-v ./evocelot-postgres-data:/var/lib/postgresql/data \
		postgres:16; \
		\
		echo "evocelot-postgres started at: localhost:5432"
	@echo "[<<<]"

stop-postgres-container:
	@echo "[>>>] Stopping the evocelot-postgres container"
	@podman rm -f evocelot-postgres 2>/dev/null || true
	@echo "[<<<]"

# Starts pgadmin container
start-pgadmin-container: stop-pgadmin-container
	@echo "[>>>] Starting pgAdmin container"
	@podman run -d \
		--name evocelot-pgadmin \
		--network $(NETWORK_NAME) \
		-p 5050:80 \
		-e PGADMIN_DEFAULT_EMAIL=admin@evocelot.com \
		-e PGADMIN_DEFAULT_PASSWORD=admin \
		-e PGADMIN_CONFIG_SERVER_MODE=False \
		-v ./pgadmin/servers.json:/pgadmin4/servers.json:ro \
		--restart always \
		dpage/pgadmin4:8; \
		\
		echo "pgAdmin started at: http://localhost:5050"
	@echo "[<<<]"

stop-pgadmin-container:
	@echo "[>>>] Stopping the evocelot-pgadmin container"
	@podman rm -f evocelot-pgadmin 2>/dev/null || true
	@echo "[<<<]"

start-liquibase-postgres-container: build-liquibase-image create-podman-network
	@echo "[>>>] Starting liquibase container for postgres"
	@podman run \
		--network $(NETWORK_NAME) \
		-e CONTEXTS=local \
		-e DB_URL=jdbc:postgresql://evocelot-postgres:5432/filestore \
		-e DB_USERNAME=admin \
		-e DB_PASSWORD=admin \
		-e DB_DRIVER=org.postgresql.Driver \
		-v ./changelog:/liquibase/changelog \
		$(IMAGE_NAME):$(VERSION)
	@echo "[<<<]"