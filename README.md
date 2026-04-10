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

The Flutter web app is served by Nginx. The project now also includes a Node/Express backend, PostgreSQL for app data, and Redis as a separate container with a named volume.

### Project Docker files

- `Dockerfile`
- `docker-compose.yml`
- `nginx.conf`
- `.dockerignore`
- `backend/Dockerfile`
- `backend/src/server.js`
- `backend/init/01-schema.sql`
- `backend/init/02-seed.sql`

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

- `student-consultation-backend`
- `student-consultation-postgres`
- `student-consultation-web`
- `student-consultation-redis`
- `student-consultation-cite-web:latest`
- `redis:7-alpine`
- `postgres:16-alpine`
- `student-consultation-cite_postgres_data`
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

### Development setup for login and database

If you want the login, register, and consultation data to work locally, start PostgreSQL and the backend first:

```bash
docker compose up -d postgres backend redis
```

Then run Flutter in the browser:

```bash
flutter pub get
flutter run -d chrome --dart-define=API_BASE_URL=http://localhost:3000/api
```

For a full Docker demo, build the web app and start everything:

```bash
flutter build web --release
docker compose up -d --build
```

Open:

```text
http://localhost:8080
```

### Default sample accounts

These accounts are seeded into PostgreSQL on first startup:

- `admin` / `admin123`
- `stephen` / `cohay123`
- `ryan` / `ryan123`

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
- The backend API runs on port `3000`
- PostgreSQL runs on port `5432`
- Redis runs on port `6379`
- PostgreSQL stores the app's users and consultations
- Redis data is stored in the named volume `redis_data`
- The Docker image uses the local `build/web` output from Flutter
- Redis is included for the deployment requirement
- The Flutter app now calls the backend API at `http://localhost:3000/api` by default for local development
- For Android emulators or physical phones, you may need a different `API_BASE_URL`

## Getting Started

This project is a starting point for a Flutter application.

A few resources to get you started if this is your first Flutter project:

- [Lab: Write your first Flutter app](https://docs.flutter.dev/get-started/codelab)
- [Cookbook: Useful Flutter samples](https://docs.flutter.dev/cookbook)

For help getting started with Flutter development, view the
[online documentation](https://docs.flutter.dev/), which offers tutorials,
samples, guidance on mobile development, and a full API reference.
