# Build stage
FROM ghcr.io/cirruslabs/flutter:3.24 AS builder

WORKDIR /app

COPY pubspec.* ./
RUN flutter pub get

COPY . .
RUN flutter build web --release --no-tree-shake-icons

# Runtime stage
FROM nginx:alpine

COPY --from=builder /app/build/web /usr/share/nginx/html
COPY nginx.conf /etc/nginx/conf.d/default.conf

EXPOSE 80

HEALTHCHECK --interval=30s --timeout=3s --start-period=5s --retries=3 \
  CMD wget --quiet --tries=1 --spider http://localhost/ || exit 1

CMD ["nginx", "-g", "daemon off;"]
