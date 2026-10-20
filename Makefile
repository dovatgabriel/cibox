.PHONY: help up down logs restart status clean prune patate normal

help:
	@echo "CIBox - GitLab Runner in Docker"
	@echo "Available commands:"
	@echo "  make up       - Start the runner"
	@echo "  make down     - Stop the runner"
	@echo "  make logs     - Show logs"
	@echo "  make restart  - Restart the runner"
	@echo "  make status   - Check runner status"
	@echo "  make clean    - Remove container, config and cache"
	@echo "  make prune    - Free Docker disk space (build cache, unused images, runner cache volumes)"
	@echo "  make patate   - PATATE MODE: max performance (concurrent=4, shm=256MB, cached images)"
	@echo "  make normal   - Restore default settings"

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

# Keeps named volumes from other projects (databases, etc.): only runner-* volumes are removed
prune:
	@echo "🧹 Freeing Docker disk space..."
	docker builder prune -af
	docker image prune -af
	@docker volume ls -q --filter dangling=true | grep '^runner-' | xargs -r docker volume rm
	@docker system df
	@echo "✅ Docker disk space freed"

patate:
	@echo "🥔 Activation du Patate Mode..."
	@[ -f config/config.toml ] || (echo "❌ config/config.toml introuvable — lance 'make up' d'abord" && exit 1)
	@sed -i '' \
		-e 's/^concurrent = .*/concurrent = 4/' \
		-e 's/shm_size = .*/shm_size = 268435456/' \
		config/config.toml
	@grep -q 'pull_policy' config/config.toml || \
		awk '/shm_size/{print; print "    pull_policy = [\"if-not-present\"]"; next}1' \
		config/config.toml > config/config.toml.tmp && mv config/config.toml.tmp config/config.toml
	@$(MAKE) --no-print-directory restart
	@echo "🔥 PATATE MODE ON — 4 jobs parallèles, shm=256MB, images Docker en cache"

normal:
	@echo "Retour en mode normal..."
	@[ -f config/config.toml ] || (echo "❌ config/config.toml introuvable" && exit 1)
	@sed -i '' \
		-e 's/^concurrent = .*/concurrent = 1/' \
		-e 's/shm_size = .*/shm_size = 0/' \
		config/config.toml
	@sed -i '' '/pull_policy/d' config/config.toml
	@$(MAKE) --no-print-directory restart
	@echo "✅ Mode normal restauré"
