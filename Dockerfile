# Fixed version tag for the assignment. Refresh deliberately and scan before production.
ARG NODE_IMAGE=node:22.16.0-alpine3.22
FROM ${NODE_IMAGE} AS build
WORKDIR /build
# Dependency metadata precedes source for cache reuse. This app has no third-party packages.
COPY package.json package-lock.json ./
RUN npm ci --ignore-scripts --no-audit --no-fund --cache /tmp/npm-cache && rm -rf /tmp/npm-cache
COPY src ./src
COPY public ./public
COPY tests ./tests
COPY scripts ./scripts
RUN npm test && npm run build

FROM ${NODE_IMAGE} AS runtime
ENV NODE_ENV=production PORT=8080
WORKDIR /app
COPY --from=build --chown=node:node /build/dist/ ./
# The official Node image creates the node user (UID 1000).
USER node
EXPOSE 8080
HEALTHCHECK --interval=15s --timeout=3s --start-period=10s --retries=3 CMD ["node", "-e", "fetch('http://127.0.0.1:8080/healthz').then(r=>process.exit(r.ok?0:1)).catch(()=>process.exit(1))"]
CMD ["node", "src/server.js"]
