# Use the latest version of the Amazon Linux base image
FROM amazonlinux:2

# Update all installed packages to their latest versions
RUN yum update -y 

# Install the unzip package, which we will use to extract the web files from the zip folder
RUN yum install unzip -y

# Install wget package, which we will use to download files from the internet 
RUN yum install -y wget

# Install Apache
RUN yum install -y httpd

# Install PHP and various extensions
RUN amazon-linux-extras enable php7.4 && \
  yum clean metadata && \
  yum install -y \
    php \
    php-common \
    php-pear \
    php-cgi \
    php-curl \
    php-mbstring \
    php-gd \
    php-mysqlnd \
    php-gettext \
    php-json \
    php-xml \
    php-fpm \
    php-intl \
    php-zip

# Enable MySQL 5.7 through amazon-linux-extras and install MySQL client
RUN amazon-linux-extras enable mysql57 && \
    yum clean metadata && \
    yum install -y mysql

# Install MySQL server directly from mysql57 package
RUN yum install -y mysql-server

# Change directory to the html directory
WORKDIR /var/www/html

# Install Git
RUN yum install -y git

# Clone the GitHub repository
RUN git clone https://"your_personal_access_token"@github.com/"your_github_username"/"your_repository_name".git 

# Unzip the zip folder containing the web files
RUN unzip "your_repository_name"/"web_file_zip" -d "your_repository_name"/

# Copy the web files into the HTML directory
RUN cp -av "your_repository_name"/"web_file_unzip"/. /var/www/html

# Remove the repository we cloned
RUN rm -rf "your_repository_name"

# Enable the mod_rewrite setting in the httpd.conf file
RUN sed -i '/<Directory "\/var\/www\/html">/,/<\/Directory>/ s/AllowOverride None/AllowOverride All/' /etc/httpd/conf/httpd.conf

# Give full access to the /var/www/html directory
RUN chmod -R 777 /var/www/html

# Give full access to the storage directory
RUN chmod -R 777 storage/

# Use the sed command to search the .env file for a line that starts with APP_ENV= and replace everything after the = character
RUN sed -i '/^APP_ENV=/ s/=.*$/=production/' .env

# Use the sed command to search the .env file for a line that starts with APP_URL= and replace everything after the = character
RUN sed -i '/^APP_URL=/ s/=.*$/=https:\/\/"your_domain_name"\//' .env

# Use the sed command to search the .env file for a line that starts with DB_HOST= and replace everything after the = character
RUN sed -i '/^DB_HOST=/ s/=.*$/="your_rds_endpoint"/' .env

# Use the sed command to search the .env file for a line that starts with DB_DATABASE= and replace everything after the = character
RUN sed -i '/^DB_DATABASE=/ s/=.*$/="your_rds_db_name"/' .env

# Use the sed command to search the .env file for a line that starts with DB_USERNAME= and replace everything after the = character
RUN sed -i '/^DB_USERNAME=/ s/=.*$/="your_rds_master_username"/' .env

# Use the sed command to search the .env file for a line that starts with DB_PASSWORD= and replace everything after the = character
RUN sed -i '/^DB_PASSWORD=/ s/=.*$/="your_rds_db_password"/' .env

# Copy the file, AppServiceProvider.php from the host file system into the container at the path app/Providers/AppServiceProvider.php
COPY AppServiceProvider.php app/Providers/AppServiceProvider.php

# Expose the default Apache and MySQL ports
EXPOSE 80 3306

# Start Apache and MySQL
ENTRYPOINT ["/usr/sbin/httpd", "-D", "FOREGROUND"]
