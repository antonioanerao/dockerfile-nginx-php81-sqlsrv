FROM nginx:1.21.6

VOLUME [ "/code" ]
ENV ACCEPT_EULA=Y
WORKDIR /code

RUN ln -fs /usr/share/zoneinfo/America/Rio_Branco /etc/localtime && \
    dpkg-reconfigure --frontend noninteractive tzdata && \
    apt update && \
    apt -y upgrade && \
    echo "pt_BR.UTF-8 UTF-8" > /etc/locale.gen && \
    apt install -y ca-certificates \
                   apt-transport-https \
                   lsb-release \
                   gnupg \
                   curl \
                   wget \
                   vim \
                   dirmngr \
                   software-properties-common \
                   rsync \
                   gettext \
                   locales \
                   gcc \
                   g++ \
                   make \
                   unzip && \
    locale-gen && \
    curl -o /etc/apt/trusted.gpg.d/php.gpg -fSL "https://packages.sury.org/php/apt.gpg" && \
    echo "deb https://packages.sury.org/php/ $(lsb_release -sc) main" | tee /etc/apt/sources.list.d/php.list && \
    apt -y update && \
    apt -y install --allow-unauthenticated php8.1 \
                   php8.1-fpm \
                   php8.1-mysql \
                   php8.1-mbstring \
                   php8.1-soap \
                   php8.1-gd \
                   php8.1-xml \
                   php8.1-intl \
                   php8.1-dev \
                   php8.1-curl \
                   php8.1-zip \
                   php8.1-imagick \
                   php8.1-gmp \
                   php8.1-ldap \
                   php8.1-bcmath \
                   php8.1-bz2 \
                   php8.1-phar \
                   php8.1-sqlite3 \
                   gcc \
                   g++ \
                   make \
                   autoconf \
                   libc-dev \
                   pkg-config && \
    curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/local/bin --filename=composer && \
    curl https://packages.microsoft.com/keys/microsoft.asc | apt-key add - && \
    curl https://packages.microsoft.com/config/debian/11/prod.list > /etc/apt/sources.list.d/mssql-release.list && \
    apt-get update && \
    apt-get install -y msodbcsql18 && \
    apt-get install -y unixodbc-dev && \
    pecl install sqlsrv && \
    pecl install pdo_sqlsrv && \
    printf "; priority=20\nextension=sqlsrv.so\n" > /etc/php/8.1/mods-available/sqlsrv.ini && \
    printf "; priority=30\nextension=pdo_sqlsrv.so\n" > /etc/php/8.1/mods-available/pdo_sqlsrv.ini && \
    phpenmod -v 8.1 sqlsrv pdo_sqlsrv && \
    rm -rf /var/lib/apt/lists/* && \
    apt upgrade -y && \
    apt autoremove -y && \
    apt clean && \
    chown -R www-data:www-data -R /code &&  \
    printf "# priority=30\nservice php8.1-fpm start\n" > /docker-entrypoint.d/30-php8.1-fpm.sh && \
    chmod 755 /docker-entrypoint.d/30-php8.1-fpm.sh && \
    chmod 755 /docker-entrypoint.d/30-php8.1-fpm.sh
    
ADD config_cntr/php.ini /etc/php/8.1/fpm/php.ini
ADD config_cntr/www.conf /etc/php/8.1/fpm/pool.d/www.conf
ADD config_cntr/nginx.conf /etc/nginx

ADD config_cntr/default.conf /etc/nginx/conf.d
