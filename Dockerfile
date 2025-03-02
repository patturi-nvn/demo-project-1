# Stage 1: Build environment
FROM node:18-alpine as builder
WORKDIR /app

COPY package*.json ./
RUN npm ci --omit=dev
COPY . .
RUN npm run build

# Stage 2: Production environment
FROM nginx:stable-alpine
WORKDIR /usr/share/nginx/html

# Remove default nginx static assets
RUN rm -rf ./*

# Copy built assets from builder
COPY --from=builder /app/build .

# Copy nginx configuration
COPY nginx.conf /etc/nginx/conf.d/default.conf

# Create necessary directories and set permissions
RUN mkdir -p /var/run/nginx /var/cache/nginx && \
    chmod -R 777 /var/run/nginx /var/cache/nginx && \
    chown -R nginx:nginx /usr/share/nginx/html && \
    chmod -R 755 /usr/share/nginx/html

EXPOSE 80

CMD ["nginx", "-g", "daemon off;"]