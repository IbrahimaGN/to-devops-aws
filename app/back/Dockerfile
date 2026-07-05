FROM node:20-alpine

WORKDIR /app

COPY package*.json ./
RUN npm ci --omit=dev

COPY . .

# Sécurité : ne pas exécuter le conteneur en root
USER node

EXPOSE 3000

HEALTHCHECK --interval=30s --timeout=3s CMD wget -q --spider http://localhost:3000/health || exit 1

CMD ["node", "src/server.js"]