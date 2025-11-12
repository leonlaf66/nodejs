###Step 1 
FROM public.ecr.aws/docker/library/node:18-alpine AS builder

WORKDIR /app
COPY sample-app/package*.json ./
RUN npm install
COPY sample-app/ .


###Step 2
FROM public.ecr.aws/docker/library/node:18-alpine
RUN apk add --no-cache curl
WORKDIR /app
COPY --from=builder /app/package*.json ./
RUN npm install --omit=dev
COPY --from=builder /app/ .
RUN addgroup -S appgroup && adduser -S appuser -G appgroup
USER appuser
EXPOSE 3000
CMD ["node", "server.js"]