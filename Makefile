.PHONY: help up down logs restart status clean

help:
	@echo "CIBox - GitLab Runner in Docker"
	@echo "Available commands:"
	@echo "  make up       - Start the runner"
	@echo "  make down     - Stop the runner"
	@echo "  make logs     - Show logs"
	@echo "  make restart  - Restart the runner"
	@echo "  make status   - Check runner status"
	@echo "  make clean    - Remove container, config and cache"

up:
	docker-compose up -d
	@echo "✅ Runner started"

down:
	docker-compose down
	@echo "⛔ Runner stopped"

logs:
	docker-compose logs -f

restart:
	docker-compose restart
	@echo "🔄 Runner restarted"

status:
	docker-compose exec gitlab-runner gitlab-runner status

clean:
	docker-compose down -v
	rm -rf config/ cache/
	@echo "🗑️  Cleaned up"
