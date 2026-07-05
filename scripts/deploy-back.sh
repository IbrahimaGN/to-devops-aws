#!/usr/bin/env bash
set -euo pipefail

CONTAINER_NAME="todo-back"
IMAGE="${IMAGE:?Variable IMAGE manquante}"
TAG="${TAG:?Variable TAG manquante}"
ENV_FILE="/opt/todo-back/.env"

echo "=== Déploiement de ${CONTAINER_NAME}:${TAG} ==="

if [ ! -f "${ENV_FILE}" ]; then
  echo "ERREUR : ${ENV_FILE} introuvable. Copie-le manuellement une première fois (contient les secrets DB)." >&2
  exit 1
fi

CURRENT_IMAGE=$(docker inspect --format='{{.Config.Image}}' "${CONTAINER_NAME}" 2>/dev/null || echo "")

echo "Pull de la nouvelle image..."
docker pull "${IMAGE}:${TAG}"

echo "Arrêt de l'ancien conteneur (s'il existe)..."
docker stop "${CONTAINER_NAME}" 2>/dev/null || true
docker rm "${CONTAINER_NAME}" 2>/dev/null || true

echo "Démarrage du nouveau conteneur..."
docker run -d \
  --name "${CONTAINER_NAME}" \
  --env-file "${ENV_FILE}" \
  -p 3000:3000 \
  --restart unless-stopped \
  "${IMAGE}:${TAG}"

echo "Vérification du bon démarrage (5s)..."
sleep 5

if ! docker ps --filter "name=${CONTAINER_NAME}" --filter "status=running" | grep -q "${CONTAINER_NAME}"; then
  echo "ÉCHEC du déploiement. Rollback en cours..."
  docker rm -f "${CONTAINER_NAME}" 2>/dev/null || true

  if [ -n "${CURRENT_IMAGE}" ]; then
    docker run -d \
      --name "${CONTAINER_NAME}" \
      --env-file "${ENV_FILE}" \
      -p 3000:3000 \
      --restart unless-stopped \
      "${CURRENT_IMAGE}"
    echo "Rollback effectué vers ${CURRENT_IMAGE}"
  else
    echo "Aucune image précédente disponible pour le rollback (premier déploiement)."
  fi
  exit 1
fi

echo "Déploiement réussi : ${CONTAINER_NAME}:${TAG} est actif."