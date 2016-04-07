#!/bin/sh

add-apt-repository -y ppa:ondrej/php
apt-get update
apt-get -y install subversion apache2 libapache2-mod-php7.0 optipng pngquant \
  php-pear php7.0-dev libgraphicsmagick1-dev php7.0-curl

yes "\n" | pecl -d preferred_state=beta install -s gmagick

if ! [ -L /var/www  ]; then
  rm -rf /var/www
  ln -fs /vagrant /var/www
fi

if ! [ -d /var/www/photon ]; then
  svn checkout https://code.svn.wordpress.org/photon/ /var/www/photon/
fi

# Apache configuration

a2enmod rewrite
perl -pi -e 's|/var/www/html|/var/www/photon|g' /etc/apache2/sites-available/000-default.conf
cat > /etc/apache2/conf-available/photon.conf <<EOF
<Directory /var/www/photon>
RewriteEngine on
RewriteCond %{REQUEST_FILENAME} !-d
RewriteCond %{REQUEST_FILENAME} !-f
RewriteRule . index.php [L]
</Directory>
EOF
a2enconf photon

# PHP configuration

echo "extension=gmagick.so" > /etc/php/7.0/mods-available/gmagick.ini
phpenmod gmagick

service apache2 restart


echo "Provisioning complete"
echo "Your photon is ready at http://localhost:8000/"
