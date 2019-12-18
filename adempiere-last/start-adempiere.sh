#!/bin/bash

#  script de inicio para ADempiere
#  revisa si es necesario iniciar la base de datos (ENV: ADEMPIERE_DB_INIT=Y )

# Cargar las variables de entorno
ENV_FILE=/root/AdempiereEnvDocker.properties
# Cargar la contraseña de postgres para al ejecutar la sentencia psql 
# no sea necesario pedirla.

export PGPASSWORD=$ADEMPIERE_DB_ADMIN_PASSWORD

if [ -f $ENV_FILE ]; then
  source $ENV_FILE
fi

PATH_CONNECTION_URI="psql -h $ADEMPIERE_DB_HOST -p $ADEMPIERE_DB_PORT -U postgres"

echo "HOST: $ADEMPIERE_DB_HOST"
echo $PATH_CONNECTION_URI -w  -c '\l';
until $PATH_CONNECTION_URI -c '\l'; do
  >&2 echo "Postgres no está disponible"
  sleep 1
done

# Ejecute la configuración sí no se ha ejecutado
if [ "$AD_SETED_CONFIGURATION" != "Y" ]; then
 
 echo "Iniciar adempiere"
 echo "========================"
  cd /opt/Adempiere
  ./RUN_silentsetup.sh

  AD_SETED_CONFIGURATION=Y
else 
  echo "========================"
  echo "Ya esta adempiere iniciado"

fi

# Ejecutar inicialización de la base de datos
if [ "$ADEMPIERE_DB_INIT" = "Y" ]; then
  if [ "$ALREADY_ADEMPIERE_DB_INIT" = "Y" ]; then
    echo "====================================================================================="
    echo "==                           * * *   ADVERTENCIA  * * *                            =="
    echo "== Base de datos ya inicializada por este contenedor                               =="
    echo "== Deshabilite el argumento ADEMPIERE_DB_INIT en el archivo .env                   =="
    echo "== Si desea inicializar la base de datos nuevamente, primero inicie el contenedor  =="
    echo "== con este argumento en N y luego comienza con este argumento en Y                =="
    echo "====================================================================================="
  else
    echo "================================================================================"
    echo "==               * * *   ADempiere Docker: Restaurando DB  * * *              =="
    echo "================================================================================"
    cd /opt/Adempiere/utils
    $PATH_CONNECTION_URI -c "DROP ROLE IF EXISTS adempiere"
    $PATH_CONNECTION_URI -c "CREATE ROLE adempiere LOGIN PASSWORD '$ADEMPIERE_DB_PASSWORD'"
    
    Y|./RUN_ImportAdempiere.sh
    ALREADY_ADEMPIERE_DB_INIT=Y
  fi
else
  echo "================================================================================"
  echo "==  ADempiere Docker: DB no restaurada                                        =="
  echo "================================================================================"
  ALREADY_ADEMPIERE_DB_INIT=N
fi

# Guardar cambios realizados para la persistencía de cambios
echo "# ADempiere Docker Environment File" > $ENV_FILE
echo "AD_SETED_CONFIGURATION=$AD_SETED_CONFIGURATION" >> $ENV_FILE
echo "ALREADY_ADEMPIERE_DB_INIT=$ALREADY_ADEMPIERE_DB_INIT" >> $ENV_FILE


cd /opt/Adempiere/utils
./RUN_Server2.sh
tail -f /dev/null

exit 0