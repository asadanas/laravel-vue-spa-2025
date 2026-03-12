# Laravel-Vue SPA

> A production-ready Single Page Application built with Laravel 8 (API backend) and Vue.js (frontend), fully containerized with Docker and designed for Kubernetes deployment via GitOps.

## Features

### Containerization & Orchestration
- **Multi-stage Docker builds**: Separate `admin-app` (PHP-FPM) and `admin-nginx` images for independent scaling.
- **Optimized images**: Alpine-based, non-root (`www-data`), minimal attack surface.
- **Local development**: `docker-compose.yml` for one-command environment setup.
- **Kubernetes-ready**: Helm charts + ArgoCD GitOps workflows for declarative cluster deployments.

### Automation & Reliability
- **CI/CD Pipeline**: GitHub Actions automates build, versioning, and push to Docker Hub.
- **Semantic Versioning**: Tags include `{VERSION}-{BRANCH}-{SHA}` for immutable, auditable releases.
- **GitOps Deployment**: A separate `k8s-manifests` repository allows ArgoCD to deploy applications safely.

### Production Security & Performance
- **Redis integration**: Caching, sessions, and queue management.
- **Nginx reverse proxy**: Production-ready reverse proxy configuration.
- **Environment isolation**: Branch-based image tagging (`dev`, `stage`, `latest`) for safe promotion pipelines.

## What Was Added
The following files/folders were added by @asadanas (Md. Asaduzzaman Anas) to enable containerization:
```
laravel-vue-spa-2025/
├── Dockerfile              # Multi-stage production build
├── docker-compose.yml      # Local development orchestration
├── .dockerignore           # Exclude files from Docker context
├── docker/
│ ├── entrypoint.sh         # Container startup script (cache clear, migrations)
│ └── nginx/
│ └── default.conf          # Nginx reverse proxy config (FastCGI to PHP-FPM)
├── .github/workflows/
│ └── docker-build.yml      # GitHub Actions CI/CD workflow
├── VERSION                 # Semantic version file for image tagging
└── README.md               # This installation guide
```
> All other files belonged to the original https://github.com/cretueusebiu/laravel-vue-spa.git repository.

## Documentation Overview:
1. Installing the application without Docker (traditional setup)
2. How Docker support was added to the original `laravel-vue-spa` repository
3. Installing the application with Docker
4. CI/CD automation using GitHub Actions
5. Deployment to Kubernetes using Helm and ArgoCD (GitOps)

# Installing the application without Docker (traditional setup)

Use this method if you prefer to run Laravel/Vue directly on your host machine.

### Prerequisites

- PHP 8.2 with extensions
- Composer
- Node.js 16 & npm
- MySQL 8.0
- Redis

### Step-by-Step Setup
### 1. Clone the repository
```bash
git clone https://github.com/cretueusebiu/laravel-vue-spa.git
cd laravel-vue-spa
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
#### Edit these lines in .env:
- APP_KEY=<your_app_key>
- DB_CONNECTION=mysql
- DB_HOST=<database_IP>
- DB_PORT=3306
- DB_DATABASE=laravel
- DB_USERNAME=<your_username>
- DB_PASSWORD=<your_password>
- CACHE_DRIVER=redis
- QUEUE_CONNECTION=redis
- SESSION_DRIVER=redis
- JWT_SECRET=<your_jwt_secret>

### 7. Run migrations
```bash
php artisan migrate --force
```
### 8. Compile frontend assets
```bash
npm ci --no-audit --no-fund
npm run build
```
### 9. Start the development server
```bash
php artisan serve --host=<Interface_IP or localhost> --port=8080
```
### 10. Access the application
Frontend: http://<Interface_IP or localhost>:8080

# How Docker Support Was Added to the Original Repository

### Original Repo
https://github.com/cretueusebiu/laravel-vue-spa

### Step 1: Clone the Original Repository
```bash
git clone https://github.com/cretueusebiu/laravel-vue-spa.git laravel-vue-spa-2025
cd laravel-vue-spa-2025
```
### 2: Create the Dockerfile
```bash
vim Dockerfile
```
Paste the multi-stage Dockerfile content here. 
### 3: Create docker-compose.yml
```bash
vim docker-compose.yml
```
Paste the docker compose config here.
### 4: Create .dockerignore
```bash
vim .dockerignore
```
Paste the file or folder to ignore.  
### 5: Create docker/entrypoint.sh
```bash
mkdir -p docker
vim docker/entrypoint.sh
```
Paste the startup script here. 
### 6: Create docker/nginx/default.conf
```bash
mkdir -p docker/nginx
vim docker/nginx/default.conf
```
Paste the Nginx config here. 
### 7: Commit Everything
```bash
git add .
git commit -m "Add Docker support with multi-stage builds"
git push origin master
```

# Installing the application with Docker
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
#### Edit these lines in .env:
- APP_KEY=<your_app_key>
- DB_CONNECTION=mysql
- DB_HOST=127.0.0.1
- DB_PORT=3306
- DB_DATABASE=laravel
- DB_USERNAME=<your_username>
- DB_PASSWORD=<your_password>
- CACHE_DRIVER=redis
- QUEUE_CONNECTION=redis
- SESSION_DRIVER=redis
- JWT_SECRET=<your_jwt_secret>

### 3. Build and start all services
>Dependencies are installed during the Docker build process
>(no manual composer or npm commands required).

>Database migrations run automatically if
>RUN_MIGRATIONS=true is set in docker-compose.yml.
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

# CI/CD with GitHub Actions
This repository handles building and publishing Docker images via GitHub Actions. 

### How to Add the Workflow to GitHub
1. Create the workflow directory:
```bash
mkdir -p .github/workflows
```
2. Create the workflow file:
```bash
vim .github/workflows/docker-build.yml
```
Paste the workflow YAML into .github/workflows/docker-build.yml
3. Commit and push:
```bash
git add .github/workflows/docker-build.yml
git commit -m "Add GitHub Actions workflow for Docker builds"
git push origin master
```
4. Verify: Go to your GitHub repo → Actions tab → You should see the workflow running.

### Create the VERSION file in your repository root:
```bash
echo "1.0.0" > VERSION
git add VERSION
git commit -m "Add VERSION file for image tagging"
git push origin master
```
### Required Secrets
Configure these in GitHub Repo → Settings → Secrets → Actions:
```bash
DOCKERHUB_USERNAME     # Your Docker Hub username
DOCKERHUB_TOKEN        # Docker Hub Personal Access Token (with write permission)
```
### Version Management
1. Update the VERSION file in this repo (e.g., 1.0.0 → 1.1.0)
2. Commit and push to trigger a new build

### What This Workflow Does
1. Build: Compiles Laravel + Vue app into Docker images
2. Push: Uploads admin-app and admin-nginx to Docker Hub
3. Tag: Applies semantic version tags to each image

# Deployment: Kubernetes + GitOps
Deployment is managed via GitOps in a separate repository using Helm and ArgoCD.
### Kubernetes Manifests & Deployment Guide:
https://github.com/asadanas/k8s-manifests

### Quick Deployment Flow:
1. Push code → GitHub Actions builds & pushes images
2. Update image tag in apps/laravel-vue-app/values-production.yaml
3. ArgoCD auto-syncs changes to your Kubernetes cluster

## Attribution
### Original Project
This application is built upon the laravel-vue-spa https://github.com/cretueusebiu/laravel-vue-spa.git repository by @cretueusebiu (Eusebiu Cretu).
### Docker & CI/CD Enhancements
Containerization, CI/CD pipeline, and GitOps workflow implemented by @asadanas (Md. Asaduzzaman Anas).

