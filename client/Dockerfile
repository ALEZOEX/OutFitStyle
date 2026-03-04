# Build stage
FROM ghcr.io/cirruslabs/flutter:stable AS builder

WORKDIR /app

COPY pubspec.* ./
RUN flutter pub get

# Generate freezed and json_serializable files
COPY . .
RUN flutter pub run build_runner build --delete-conflicting-outputs

# Build for web with API base URL и build stamp
# Для production используем '' (пустая строка, запросы будут относительными: /api/v1/...)
# nginx проксирует /api/v1/* на backend
ARG API_BASE_URL=
ARG COMMIT_SHA=unknown
ARG BUILD_DATE=unknown
ARG APP_VERSION=unknown
RUN flutter build web --release --no-tree-shake-icons --dart-define=API_BASE_URL=${API_BASE_URL} --dart-define=COMMIT_SHA=${COMMIT_SHA} --dart-define=BUILD_DATE=${BUILD_DATE} --dart-define=APP_VERSION=${APP_VERSION} --no-wasm-dry-run

# Runtime stage
FROM nginx:alpine

COPY --from=builder /app/build/web /usr/share/nginx/html
COPY nginx.conf /etc/nginx/conf.d/default.conf

EXPOSE 80

HEALTHCHECK --interval=30s --timeout=3s --start-period=5s --retries=3 \
  CMD wget --quiet --tries=1 --spider http://localhost/ || exit 1

CMD ["nginx", "-g", "daemon off;"]
