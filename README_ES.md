# test-runner
Imagen de docker para ejecutar tests de behat en un entorno aislado.

## ¿Cómo hacerlo funcionar ?
La manera recomendada para ejecutar nuestros tests de behat utilizando esta imagen es utilizar un fichero de docker-compose que nos permita copiar el contenido del fichero dentro de la imagen.

En un caso de ejemplo, la estrucutura de ficheros podra ser
```
/
- behat
-- features
---- featuredebehat.feature
-- docker
---- docker-compose.yml
- web
```

El contenido de docker compose podría ser el siguiente:

```
version: "2"

services:
  behat-tests:
    container_name: behat-tests
    image: front-id/test-runner
    environment:
      SSH_AUTH_SOCK: /ssh-agent
    volumes:
      # Forward local machine SSH key to docker.
      - $SSH_AUTH_SOCK:/ssh-agent
      - ../../web:/root/website
    entrypoint: /root/website/behat/docker/entrypoint.sh
```

La otra pieza importante del sistema es el entrypoint.

```
#!/usr/bin/env bash

# Load the SSH sock
ssh-add -l

export PATH="$HOME/vendor/bin:$PATH"

# Make a copy of the website on the apache folder in order to manipulate safely.
cp -r /root/website /var/www/html/tests
cp /root/website/behat/docker/behat.docker.yml /var/www/html/tests/behat/behat.local.yml
cp /root/website/behat/docker/settings.docker.php /var/www/html/tests/sites/default/settings.local.php
cp /root/website/behat/docker/drush_config.docker.php /var/www/html/tests/drush/config.local.php

# Configure apache2.
echo -e "\n [RUN] Configure apache2."
cp /var/www/html/tests/behat/docker/default.apache2.conf /etc/apache2/apache2.conf
service apache2 restart

# Start MySQL.
echo -e "\n [RUN] Start MySQL."
service mysql start

# Installation profile.
echo -e "\n [RUN] Installation profile."
drush sql-create --yes
drush sql-sync @dev default --yes

drush updb --yes
drush fra --yes

cd /var/www/html/tests


# Run Behat tests.
echo -e "\n [RUN] Start tests.\n"
cd behat
composer install
./bin/behat --tags=~@wip
```
Como puntos a tener en cuenta, una de las cosas que hace este script es copiar los ficheros de la web a un lugar seguro para poder sustituir los ficheros de configuración por ficheros preparados para el docker. Esto se hace porque en ocasiones lanzaremos estos tests desde nuestros entornos de desarrollo y si manipulamos los ficheros mapeados desde nuestros hipervisores, lo más probable sería que dejase de funcionar nuestro proyecto local.

