# syntax=docker/dockerfile:1
# SPDX-FileCopyrightText: 2025 Pagefault Games
# SPDX-FileContributor: domagoj03
#
# SPDX-License-Identifier: AGPL-3.0-only
ARG NODE_VERSION=20
ARG OS=alpine

FROM node:${NODE_VERSION}-${OS}

# Create non-root user
RUN addgroup -S appgroup && adduser -S appuser -G appgroup

# Install git
RUN apk add --no-cache git

# Set working directory
WORKDIR /app

# Enable and prepare pnpm
RUN corepack enable && corepack prepare pnpm@10.33.2 --activate

# Copy project files
COPY . .

# Copy package files
COPY package.json pnpm-lock.yaml ./

# Install all dependencies without enforcing lockfile strictness or lifecycle scripts
RUN --mount=type=cache,target=/home/appuser/.pnpm-store \
    pnpm install --no-frozen-lockfile --ignore-scripts && \
    rm -rf /home/appuser/.pnpm-store/*

# Build the game in standalone offline mode
RUN pnpm run build:app

# Change ownership
RUN chown -R appuser:appgroup /app

# Switch to non-root user
USER appuser

# Set environment variables for offline play
ENV VITE_BYPASS_LOGIN=1 \
    VITE_BYPASS_TUTORIAL=0 \
    NEXT_TELEMETRY_DISABLED=1 \
    NODE_ENV=production \
    PORT=8000

# Expose port
EXPOSE 8000

# Serve the static offline build
CMD ["npx", "serve", "-s", "dist", "-l", "8000"]
