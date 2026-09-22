# QA Lab

A small Docker-based QA laboratory environment for practicing PostgreSQL, Docker Compose, networking, service health checks, secrets management, SSH tunneling, and Git/GitHub workflows.

## Architecture

```text
Mac
 │
 │ SSH tunnel
 ▼
Oracle Cloud VM
 │
 ├── Adminer
 │     └── 127.0.0.1:8080
 │
 └── PostgreSQL 16
       └── private Docker network
            └── qa-lab_qa-lab-network
```

Adminer and PostgreSQL communicate through the Docker network using the service name:

```text
postgres:5432
```

PostgreSQL is not published directly to the host.

Adminer is bound only to:

```text
127.0.0.1:8080
```

and is accessed remotely through an SSH tunnel.

## Services

### PostgreSQL

* PostgreSQL 16
* Persistent Docker volume
* `restart: unless-stopped`
* Docker healthcheck using `pg_isready`
* Password provided through Docker Secrets
* Not exposed on a host port

### Adminer

* Adminer web interface
* Connected to the same Docker network as PostgreSQL
* Starts after PostgreSQL becomes healthy
* Published only on `127.0.0.1:8080`

## Docker Features Practiced

This repository is used to practice:

* Docker Compose
* Named volumes and persistent database data
* Custom Docker bridge networks
* Docker DNS and service discovery
* Container restart policies
* PostgreSQL healthchecks
* `depends_on` with `condition: service_healthy`
* Docker Compose secrets
* Least-privilege access to secrets
* SSH tunneling
* Git/GitHub with SSH authentication

## Project Structure

```text
qa-lab/
├── compose.yaml
├── .env.example
├── .gitignore
├── README.md
└── secrets/
    └── postgres_password.txt    # local only, not tracked by Git
```

The real `.env` file and files under `secrets/` are intentionally excluded from Git.

## Configuration

Create a local `.env` file containing non-secret configuration:

```env
POSTGRES_DB=qa_lab
POSTGRES_USER=qa_user
```

Create the PostgreSQL password secret locally:

```text
secrets/postgres_password.txt
```

The secret file must never be committed to Git.

## Start the Environment

From the project directory:

```bash
docker compose up -d
```

Check service status:

```bash
docker compose ps
```

PostgreSQL should eventually report:

```text
healthy
```

## Access Adminer Through SSH

Adminer is intentionally not exposed to the Internet.

Create an SSH tunnel from the local Mac:

```bash
ssh -N -L 127.0.0.1:18080:127.0.0.1:8080 ubuntu@<SERVER_IP>
```

Then open:

```text
http://127.0.0.1:18080
```

For the database server in Adminer use:

```text
postgres
```

## Security Notes

The project follows several basic security principles:

* Database ports are not exposed publicly.
* Adminer is bound only to localhost.
* Remote access is provided through an SSH tunnel.
* PostgreSQL credentials are provided through Docker Secrets.
* Secrets are not tracked by Git.
* Adminer does not receive the PostgreSQL secret.
* The GitHub repository uses an SSH deploy key instead of storing GitHub credentials on the server.

## Useful Commands

Validate Compose configuration:

```bash
docker compose config --quiet
```

Show running services:

```bash
docker compose ps
```

Inspect the Docker network:

```bash
docker network inspect qa-lab_qa-lab-network
```

Check PostgreSQL health:

```bash
docker inspect qa-lab-postgres-1 --format '{{json .State.Health}}'
```

View logs:

```bash
docker compose logs
```

Stop the environment:

```bash
docker compose down
```

The named PostgreSQL volume is preserved by default.

## Git Workflow

Typical workflow:

```bash
git status
git add .
git commit -m "..."
git push
```

The repository uses SSH authentication for GitHub, so no GitHub username or personal access token is required for normal pushes.

## Learning Goals

The environment is intentionally built step by step to practice real-world QA infrastructure concepts rather than only running containers.

Planned topics include:

* PostgreSQL backup and restore
* Credential rotation
* Docker resource limits
* Logging and troubleshooting
* Database connectivity testing
* CI/CD
* Automated API and database checks
* More advanced secret management

