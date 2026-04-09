# namer_app

A new Flutter project.

## Docker Deployment

This project includes the following Docker requirements:

- Container
- Nginx
- Redis
- Docker Compose
- Docker image
- Docker volume

The Flutter web app is served by Nginx, and Redis is included as a separate container with a named volume.

### Project Docker files

- `Dockerfile`
- `docker-compose.yml`
- `nginx.conf`
- `.dockerignore`

### Requirements on another computer

Install these first:

- Docker
- Docker Compose
- Flutter SDK

Then check that they are available:

```bash
docker --version
docker compose version
flutter --version
```

### How to run this project on another computer

1. Clone or copy the project to the other computer.
2. Open a terminal in the project folder.
3. Download Flutter packages:

```bash
flutter pub get
```

4. Build the Flutter web files:

```bash
flutter build web --release
```

5. Build and start the Docker containers:

```bash
docker compose up --build
```

6. Open the app in a browser:

```text
http://localhost:8080
```

### Docker context setup

This computer can use two Docker contexts:

- `default` for the normal Linux Docker engine
- `desktop-linux` for Docker Desktop

Use only one context at a time. The app, containers, images, and volumes will appear only in the context where you ran the project.

### Option 1: Use `default` context

Use this if you want to run the project from the terminal and show the result using terminal commands.

Select the context:

```bash
docker context use default
```

Run the project:

```bash
flutter pub get
flutter build web --release
docker compose up -d --build
```

Check the Docker resources:

```bash
docker ps
docker images
docker volume ls
```

Open the app:

```text
http://localhost:8080
```

### Option 2: Use `desktop-linux` for Docker Desktop app

Use this if you want the Docker Desktop application to show the containers, images, and volume.

Select the context:

```bash
docker context use desktop-linux
```

Run the project:

```bash
flutter pub get
flutter build web --release
docker compose up -d --build
```

Then open Docker Desktop and check:

- `Containers`
- `Images`
- `Volumes`

You should see:

- `student-consultation-web`
- `student-consultation-redis`
- `student-consultation-cite-web:latest`
- `redis:7-alpine`
- `student-consultation-cite_redis_data`

Open the app:

```text
http://localhost:8080
```

### How to stop the containers

```bash
docker compose down
```

### How to run it again later

If nothing changed in the code, you can run:

```bash
docker compose up
```

If you changed the Flutter code, build again first:

```bash
flutter build web --release
docker compose up --build
```

### Docker commands for checking the requirement

Show running containers:

```bash
docker ps
```

Show Docker images:

```bash
docker images
```

Show Docker volumes:

```bash
docker volume ls
```

### Notes

- The web app runs in Nginx on port `8080`
- Redis runs on port `6379`
- Redis data is stored in the named volume `redis_data`
- The Docker image uses the local `build/web` output from Flutter
- Redis is included for the deployment requirement
- The current Flutter app does not directly use Redis because there is no backend service in this repository

## Getting Started

This project is a starting point for a Flutter application.

A few resources to get you started if this is your first Flutter project:

- [Lab: Write your first Flutter app](https://docs.flutter.dev/get-started/codelab)
- [Cookbook: Useful Flutter samples](https://docs.flutter.dev/cookbook)

For help getting started with Flutter development, view the
[online documentation](https://docs.flutter.dev/), which offers tutorials,
samples, guidance on mobile development, and a full API reference.
