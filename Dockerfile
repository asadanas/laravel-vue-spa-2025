FROM php:8.2-fpm

# Install system deps
RUN apt-get update && apt-get install -y \
    build-essential \
    libpng-dev \
    libjpeg-dev \
    libfreetype6-dev \
    libonig-dev \
    libxml2-dev \
    libzip-dev \
    zip \
    unzip \
    git \
    curl \
    npm \
    nodejs

# Install PHP extensions
RUN docker-php-ext-configure gd --with-freetype --with-jpeg && \
    docker-php-ext-install pdo pdo_mysql mbstring exif pcntl bcmath gd zip

# Set working directory
WORKDIR /var/www

# Copy existing application
COPY . .

# Install Composer
COPY --from=composer:latest /usr/bin/composer /usr/bin/composer

# Update PHP dependencies
RUN composer update

# Install PHP dependencies
RUN composer install --no-interaction --prefer-dist --optimize-autoloader

# Fix for Webpack build with Node.js >=17 (OpenSSL 3)
ENV NODE_OPTIONS=--openssl-legacy-provider

# Install Node dependencies & build
RUN npm install && npm run build

CMD ["php-fpm", "-F"]

