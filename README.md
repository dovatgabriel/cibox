# CIBox

🐳 Portable GitLab Runner in Docker — Run your CI/CD anywhere, hassle-free.

## What is it?

CIBox is a minimal setup to run a **GitLab Runner in Docker**. Perfect for:

- Running your CI/CD on your local machine (Mac, Linux)
- Running CI on a Raspberry Pi or personal server
- Testing your pipeline before merging
- **Building Docker images** (Docker builds work out of the box!)
- No complex system dependencies

## Prerequisites

- Docker & Docker Compose installed
- A GitLab runner registration token

## Quick setup

### 1. Clone the repo

```bash
git clone https://github.com/gabrieldovat/cibox.git
cd cibox
```

### 2. Configure variables

```bash
cp .env.example .env
```

Edit `.env` and fill in:

- `GITLAB_URL`: Your GitLab instance URL (default: https://gitlab.com/)
- `REGISTRATION_TOKEN`: Token from **Settings > CI/CD > Runners** in your project

### 3. Start the runner

```bash
docker-compose up -d
```

That's it! The runner will register itself and wait for jobs. ✅

## Useful commands

```bash
# Start
docker-compose up -d

# Stop
docker-compose down

# Logs in real-time
docker-compose logs -f

# Restart
docker-compose restart

# Check runner status
docker-compose exec gitlab-runner gitlab-runner status
```

## Configure your .gitlab-ci.yml

To use this runner, add the tag to your pipeline:

```yaml
my_job:
  script:
    - echo "Running on CIBox!"
  tags:
    - cibox # Or the tag you configured
```

## Environment variables

| Variable             | Default               | Description             |
| -------------------- | --------------------- | ----------------------- |
| `GITLAB_URL`         | `https://gitlab.com/` | GitLab instance URL     |
| `REGISTRATION_TOKEN` | -                     | Runner token (required) |
| `RUNNER_DESCRIPTION` | `CIBox Runner`        | Runner name in GitLab   |
| `RUNNER_TAG_LIST`    | `docker,cibox`        | Tags (comma-separated)  |
| `RUNNER_EXECUTOR`    | `docker`              | Executor type           |
| `DOCKER_IMAGE`       | `node:18-bullseye`    | Default Docker image    |

## On Raspberry Pi

```bash
# Install Docker on Raspberry Pi (Bullseye/Bookworm)
curl -fsSL https://get.docker.com -o get-docker.sh
sh get-docker.sh

# Then clone and run normally
git clone https://github.com/gabrieldovat/cibox.git
cd cibox
cp .env.example .env
# ... configure your token ...
docker-compose up -d
```

## Troubleshooting

### Runner doesn't register

```bash
docker-compose logs
```

Check that `REGISTRATION_TOKEN` is correct in `.env`.

### Jobs don't run

- Verify the tag in `.gitlab-ci.yml` matches `RUNNER_TAG_LIST` in `.env`
- Check logs: `docker-compose logs -f`

### Docker socket not accessible

If you get a `/var/run/docker.sock` error, make sure Docker is running and you have permissions.

```bash
# On Mac with Docker Desktop, it's automatic
# On Linux, check: sudo usermod -aG docker $USER
```

## Architecture

```
cibox/
├── docker-compose.yml    # Docker configuration
├── .env                  # Variables (create from .env.example)
├── config/               # GitLab Runner config (generated)
├── cache/                # Job cache (generated)
└── README.md
```

## Building Docker Images

CIBox supports Docker image builds out of the box! The runner automatically has access to the Docker daemon on your host machine.

Example `.gitlab-ci.yml`:

```yaml
build_docker_image:
  stage: build
  image: docker:27
  script:
    - docker build -t myapp:latest .
    - docker push myregistry.com/myapp:latest
  tags:
    - cibox
```

The Docker socket is automatically bind-mounted, so your build jobs can access the host's Docker daemon.

## Notes

- Config and cache are persisted in `config/` and `cache/` directories
- Runner restarts automatically when you restart the container
- `.env` and `config/`/`cache/` are excluded from versioning (`.gitignore` handles this)

## License

MIT

---

Made with ❤️ for faster CI/CD
