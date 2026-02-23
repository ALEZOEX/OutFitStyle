# Build stage
FROM ghcr.io/cirruslabs/flutter:latest AS builder

WORKDIR /app

COPY pubspec.* ./
RUN flutter pub get

# Generate freezed and json_serializable files
COPY . .
RUN flutter pub run build_runner build --delete-conflicting-outputs

# Build for web
RUN flutter build web --release --no-tree-shake-icons

# Runtime stage
FROM nginx:alpine

COPY --from=builder /app/build/web /usr/share/nginx/html
COPY nginx.conf /etc/nginx/conf.d/default.conf

EXPOSE 80

HEALTHCHECK --interval=30s --timeout=3s --start-period=5s --retries=3 \
  CMD wget --quiet --tries=1 --spider http://localhost/ || exit 1

CMD ["nginx", "-g", "daemon off;"]
