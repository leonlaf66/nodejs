# --- Stage 1: Build Environment ---
# This stage installs all dependencies (including dev dependencies) and builds the application.
# We use a Node.js image that includes the full build toolchain.
FROM node:18-alpine AS builder

# Set the working directory
WORKDIR /app

# Copy package.json and package-lock.json
# Copying them separately leverages Docker's cache. 'npm install' only runs if these files change.
COPY sample-app/package*.json ./

# Install all dependencies, including dev dependencies for testing and building.
RUN npm install

# Copy the rest of the application source code.
COPY sample-app/ .

# (Optional) If your application has a build step (e.g., compiling TypeScript), run it here.
# RUN npm run build


# --- Stage 2: Production Environment ---
# This stage builds the final, lightweight production image.
# We use a slim Node.js image for the production environment.
FROM node:18-alpine

# Set the working directory
WORKDIR /app

# Copy package.json and package-lock.json from the 'builder' stage.
COPY --from=builder /app/package*.json ./

# Install only the production dependencies.
# This significantly reduces the final image size.
RUN npm install --omit=dev

# Copy the application code (and build artifacts, if any) from the 'builder' stage.
COPY --from=builder /app/ .

# (Optional) Create a non-root user to run the application for better security.
RUN addgroup -S appgroup && adduser -S appuser -G appgroup
USER appuser

# Expose the port the application runs on.
EXPOSE 3000

# The command to start the application.
CMD ["node", "server.js"]
