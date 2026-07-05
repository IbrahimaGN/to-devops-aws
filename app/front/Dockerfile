# --- Stage 1 : build de l'application Angular ---
FROM node:20-alpine AS builder

WORKDIR /app

COPY package*.json ./
RUN npm ci

COPY . .
RUN npm run build -- --configuration production

# --- Stage 2 : image finale, ultra-légère, sert uniquement les fichiers statiques ---
FROM nginx:alpine

# Angular 21 (application builder) génère dist/<nom-projet>/browser
# Adapter <nom-projet> au nom réel défini dans angular.json
COPY --from=builder /app/dist/todo-front/browser /usr/share/nginx/html
COPY nginx.conf /etc/nginx/conf.d/default.conf

EXPOSE 8080

HEALTHCHECK --interval=30s --timeout=3s CMD wget -q --spider http://localhost:8080 || exit 1