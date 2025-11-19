# OutfitStyle Web Client

This is the web version of the OutfitStyle client built with Flutter.

## Running with Docker

To run the web client using Docker:

```bash
# Build and run the Docker container
docker-compose up --build

# Or run just the web client
docker-compose up web-client
```

The web application will be available at http://localhost

## Building for Production

To build the Docker image for production:

```bash
docker build -t outfitstyle-web .
```

## Development

For development, you can run the Flutter web app locally:

```bash
# Get dependencies
flutter pub get

# Run in Chrome
flutter run -d chrome

# Build for web
flutter build web
```