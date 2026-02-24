# Laravel-Vue SPA

> A production-ready Single Page Application built with Laravel 8 (API backend) and Vue.js (frontend), fully containerized with Docker.

## Features

- Full-Stack SPA: Laravel REST API + Vue.js frontend
- Dockerized: Multi-stage production Dockerfile + docker-compose for local testing
- Redis Ready: PHP Redis extension pre-installed
- Security: Non-root user (www-data), Alpine-based minimal images
- Nginx Proxy: Production-ready reverse proxy configuration

## What Was Added (Docker Layer)
The following files/folders were added by @asadanas (Md. Asaduzzaman Anas) to enable containerization:
```
laravel-vue-spa-2025/
├── Dockerfile                    # Multi-stage production build
├── docker-compose.yml            # Local development orchestration
├── .dockerignore                 # Exclude files from Docker context
├── docker/
│   ├── entrypoint.sh             # Container startup script (cache clear, migrations)
│   └── nginx/
│       └── default.conf          # Nginx reverse proxy config (FastCGI to PHP-FPM)
└── README.md                     # This installation guide
```
> All other files belong to the original https://github.com/cretueusebiu/laravel-vue-spa.git repository.

## Installation Guide

### Option 1: Traditional Installation (Without Docker)

Use this method if you prefer to run Laravel/Vue directly on your host machine.

### Prerequisites
Choose one of the two methods below to install the application in your test environment.

- PHP 8.2 with extensions
- Composer
- Node.js 16 & npm
- MySQL 8.0

### Step-by-Step Setup
### 1. Clone the repository
```bash
git clone https://github.com/asadanas/laravel-vue-spa-2025.git
cd laravel-vue-spa-2025
```
### 2. Copy environment file
```bash
cp .env.example .env
```
### 3. Install PHP dependencies
```bash
composer install
```
### 4. Install JavaScript dependencies
```bash
npm install
```
### 5. Generate application key and JWT secret
```bash
php artisan key:generate
```
```bash
php artisan jwt:secret
```
### 6. Configure your database & other necessary environments in .env
### Edit these lines in .env:
- APP_KEY=<your_app_key>
- DB_CONNECTION=mysql
- DB_HOST=<database_IP>
- DB_PORT=3306
- DB_DATABASE=laravel
- DB_USERNAME=<your_username>
- DB_PASSWORD=<your_password>
- CACHE_DRIVER=<file or redis>
- QUEUE_CONNECTION=<sync or redis>
- SESSION_DRIVER=<file or redis>
- JWT_SECRET=<your_jwt_secret>

### 7. Run migrations
```bash
php artisan migrate --force
```
### 9. Compile frontend assets
```bash
npm ci --no-audit --no-fund
npm run build
```
### 10. Start the development server
```bash
php artisan serve --host=<Interface_IP or localhost> --port=8080
```
### 11. Access the application
Frontend: http://<Interface_IP or localhost>:8000

## Option 2: Docker Installation (Recommended)
Use this method for a consistent, isolated environment that matches production.

### Prerequisites
Install Docker & Docker Compose by following link.

https://docs.docker.com/engine/install/

### Step-by-Step Setup
### 1. Clone the repository
```bash
git clone https://github.com/asadanas/laravel-vue-spa-2025.git
cd laravel-vue-spa-2025
```
### 2. Copy environment template
```bash
cp .env.example .env
```
### Edit these lines in .env:
- APP_KEY=<your_app_key>
- DB_CONNECTION=mysql
- DB_HOST=127.0.0.1
- DB_PORT=3306
- DB_DATABASE=laravel
- DB_USERNAME=<your_username>
- DB_PASSWORD=<your_password>
- CACHE_DRIVER=<file or redis>
- QUEUE_CONNECTION=<sync or redis>
- SESSION_DRIVER=<file or redis>
- JWT_SECRET=<your_jwt_secret>

### 3. Build and start all services
Dependencies are installed during build (no manual composer/npm needed)
Migrations run automatically if RUN_MIGRATIONS=true into docker-compose yaml.
```bash
docker compose up -d --build
```
### 4. Wait for services to be healthy (30-60 seconds)
```bash
docker compose ps
```
Expected: app, nginx, db, redis all show "Up (healthy)"

### 5. Access the application
Frontend: http://<Interface_IP>:8080

### 6. Remove all the services
```bash
docker compose down -v
```

## Attribution
### Original Project
This application is built upon the laravel-vue-spa https://github.com/cretueusebiu/laravel-vue-spa.git repository by @cretueusebiu (Eusebiu Cretu).

