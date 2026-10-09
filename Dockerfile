FROM node:24-bookworm-slim AS build
WORKDIR /app
COPY package.json package-lock.json ./
RUN npm ci
COPY . .
RUN npm run build && npm run check && npm test

FROM node:24-bookworm-slim
ENV NODE_ENV=production HOST=0.0.0.0 PORT=8080 ORDERS_DB_PATH=/data/orders.sqlite
WORKDIR /app
COPY package.json package-lock.json ./
RUN npm ci --omit=dev && mkdir /data && chown node:node /data
COPY --from=build /app/dist ./dist
COPY --from=build /app/server ./server
COPY --from=build /app/shared ./shared
COPY --from=build /app/scripts/list-orders.mjs ./scripts/list-orders.mjs
COPY --from=build /app/scripts/admin-link.mjs ./scripts/admin-link.mjs
USER node
EXPOSE 8080
CMD ["node", "server/index.js", "--production"]
