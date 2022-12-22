#!/bin/bash

#Inicia o serviço do apache
service apache2 start

#Edita o arquivo de configuração do banco de dados com base nas variáveis de ambietne do arquivo .env
ConfigDataBase () {
      {
        echo "<?php"; \
        echo "class DB extends DBmysql {"; \
        echo "   public \$dbhost     = \"${MYSQL_HOST}\";"; \
        echo "   public \$dbport     = \"${MYSQL_PORT}\";"; \
        echo "   public \$dbuser     = \"${MYSQL_USER}\";"; \
        echo "   public \$dbpassword = \"${MYSQL_PASSWORD}\";"; \
        echo "   public \$dbdefault  = \"${MYSQL_DATABASE}\";"; \
        echo "   public \$use_timezones = true;"; \
        echo "   public \$use_utf8mb4 = true;"; \
        echo "   public \$allow_myisam = false;"; \
        echo "   public \$allow_datetime = false;"; \
        echo "   public \$allow_signed_keys = false;"; \
        echo "}"; \
        echo ; 
      } > /tmp/glpi/config/config_db.php

}

#Verifica os diretórios padrão do GLPI
VerifyDir () {
  DIR="${GLPI_VAR_DIR}/_cron
  ${GLPI_VAR_DIR}/_dumps
  ${GLPI_VAR_DIR}/_graphs
  ${GLPI_VAR_DIR}/_log
  ${GLPI_VAR_DIR}/_lock
  ${GLPI_VAR_DIR}/_pictures
  ${GLPI_VAR_DIR}/_plugins
  ${GLPI_VAR_DIR}/_rss
  ${GLPI_VAR_DIR}/_tmp
  ${GLPI_VAR_DIR}/_uploads
  ${GLPI_VAR_DIR}/_cache
  ${GLPI_VAR_DIR}/_sessions
  ${GLPI_VAR_DIR}/_locales"

  for i in $DIR
  do 
    if [ ! -d $i ]
    then
      echo -n "Creating $i dir... " 
      mkdir -p $i
      echo "done"
    fi
  done
}

#verifica a chave de criptografia do GLPI (Não implementado neste projeto)
VerifyKey () {

  if [ ! -e /tmp/glpi/config/glpicrypt.key ]
  then
    php -c /etc/php.ini bin/console glpi:security:change_key --no-interaction
  fi

}

# Atribui as permissões nos diretórios utilizados pelo GLPI
SetPermissions () {
  echo -n "Setting chown in files... "
    chown -R www-data:www-data /var/www/html
    chown -R www-data:www-data /tmp/glpi/config
    chown -R www-data:www-data /var/lib/glpi
    chown -R www-data:www-data /var/log/glpi
    chmod -R 775 /var/www/html
    chmod -R 775 /tmp/glpi/config
    chmod -R 775 /var/lib/glpi
    chmod -R 775 /var/log/glpi
  echo "done"
}

SetPermissions
VerifyDir
ConfigDataBase
VerifyKey


#remove o arquivo index do apache
set -e
rm -f /var/www/html/index.html

# remover arquivos .pid pré-existentes
rm -f /usr/local/apache2/logs/httpd.pid

#verifica se as configurações do apache estão corretas
apache2ctl -t

# reinicia o serviço do apache
SetPermissions
service apache2 restart

# Comando sem uma saida para evitar reboot automático do container
tail -f /dev/null

