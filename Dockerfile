# Stage 1: Build frontend assets
FROM node:20 AS node-builder
WORKDIR /app

COPY package*.json ./
RUN npm install

COPY . .
ENV NODE_OPTIONS=--openssl-legacy-provider
RUN npm run build


# Stage 2: Install PHP dependencies
FROM php:8.2-fpm-alpine AS php-builder

# Install system deps and PHP extensions
RUN apk add --no-cache \
    libpng-dev libjpeg-turbo-dev freetype-dev \
    libzip-dev libxml2-dev oniguruma-dev zlib-dev \
    curl git unzip bash autoconf make g++ pkgconf

RUN docker-php-ext-configure gd --with-freetype --with-jpeg && \
    docker-php-ext-install pdo pdo_mysql mbstring exif pcntl bcmath gd zip

# Copy Composer
COPY --from=composer:latest /usr/bin/composer /usr/bin/composer

WORKDIR /app
COPY . .
RUN composer update
# Ensure dependencies are compatible
RUN composer install --no-dev --optimize-autoloader

# Stage 3: Final Image
FROM php:8.2-fpm-alpine

RUN apk add --no-cache \
    libpng-dev libjpeg-turbo-dev freetype-dev \
    libzip-dev libxml2-dev oniguruma-dev zlib-dev && \
    docker-php-ext-configure gd --with-freetype --with-jpeg && \
    docker-php-ext-install pdo pdo_mysql mbstring exif pcntl bcmath gd zip

WORKDIR /var/www/html

# Copy Laravel backend from php-builder (includes vendor!)
COPY --from=php-builder /app /var/www/html

# Copy frontend assets
COPY --from=node-builder /app/public /var/www/html/public

#set permissions 
RUN chown -R www-data:www-data /var/www/html \
 && chmod -R 775 /var/www/html

# Cope docker/entrypoint.sh
COPY ./docker/entrypoint.sh /usr/local/bin/entrypoint.sh
RUN chmod +x /usr/local/bin/entrypoint.sh

ENTRYPOINT ["entrypoint.sh"]

