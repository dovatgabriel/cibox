#!/bin/bash

# Auto-register GitLab Runner if not already registered
if [ ! -f /etc/gitlab-runner/config.toml ]; then
  echo "🔧 Registering GitLab Runner..."

  gitlab-runner register \
    --url "${GITLAB_URL}" \
    --token "${REGISTRATION_TOKEN}" \
    --executor "${RUNNER_EXECUTOR}" \
    --docker-image "${DOCKER_IMAGE}" \
    --description "${RUNNER_DESCRIPTION}" \
    --tag-list "${RUNNER_TAG_LIST}" \
    --docker-volumes /var/run/docker.sock:/var/run/docker.sock \
    --docker-privileged \
    --non-interactive

  echo "✅ Runner registered successfully"
else
  echo "✅ Runner already registered"
fi

# Start the runner
gitlab-runner run
