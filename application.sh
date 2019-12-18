#!/usr/bin/env bash
BASE_DIR=$(cd "$(dirname "$0")"; pwd)

if [ -z "$1" ];
then
    echo "Advertencia, nombre del directorio para la instancia no fue enviado."
    echo "El comando para usarlo correctamente es  ./application.sh <nombre de la instancia> up -d "
    exit 1
fi

# Cargar las variables de entorno
. .env

export COMPOSE_PROJECT_NAME=$1;
echo "Instancia $COMPOSE_PROJECT_NAME"
. ./$COMPOSE_PROJECT_NAME/.env

if [ -z "$ADEMPIERE_WEB_PORT" ];
then
    echo "Variable ADempiere HTTP puerto no enviado"
    exit 1
fi

if [ -z "$ADEMPIERE_SSL_PORT" ];
then
    echo "Variable ADempiere HTTPS puerto no enviado"
    exit 1
fi

if [ -z "$ADEMPIERE_DB_INIT" ];
then
    echo "Variable Initialize Database no enviado"
    exit 1
fi

if [ -z "$ADEMPIERE_VERSION" ];
then
    echo "Variable  ADempiere version no enviado"
    exit 1
fi

export ADEMPIERE_WEB_PORT;
export ADEMPIERE_SSL_PORT;
export ADEMPIERE_DB_INIT;

echo "ADempiere HTTP  port: $ADEMPIERE_WEB_PORT"
echo "ADempiere HTTPS port: $ADEMPIERE_SSL_PORT"
echo "Iniciar Database $ADEMPIERE_DB_INIT"

if [[ "$(docker images -q jdk_adempiere:8 2> /dev/null)" == "" ]]; then
    docker build \
        -t jdk_adempiere:8 \
        "$BASE_DIR/jdk_img" 
fi

if [ "$(docker network inspect -f '{{.Name}}' adempiere_network)" != "adempiere_network" ];
then
    echo "Crear red en docker llamada : adempiere_network"
    docker network create -d bridge adempiere_network
fi

if [ "$USE_CONTAINER_POSTGRES" == "Y" ]; then
    echo " ============================= USAR CONTENEDOR DE POSTGRES ============================= ";
    
    RUNNING=$(docker inspect --format="{{.State.Running}}" $NAME_CONTAINER_POSTGRES 2> /dev/null)

    if [ $? -eq 1 ]; then
    echo "Contenedor postgres no existe."
    echo "Creando el contenedor postgres."
    docker-compose \
        -f "$BASE_DIR/database.yml" \
        up -d
    fi

    if [ "$RUNNING" == "false" ];
    then
    echo "ADVERTENCIA CRITICA - $NAME_CONTAINER_POSTGRES no está corriendo."
    echo "Comenzando el contenedor postgres"
    docker-compose \
        -f "$BASE_DIR/database.yml" \
        start
    fi

    if [ "$RUNNING" == "true" ];
    then
    docker-compose \
        -f "$BASE_DIR/database.yml" \
        config
    fi
    export DB_PORT=5432;
    export DB_HOST=$NAME_CONTAINER_POSTGRES;
else 
    export DB_PORT=$ADEMPIERE_DB_PORT;
    export DB_HOST=$ADEMPIERE_DB_HOST;
fi

# Definir ruta de Adempiere y binario
ADEMPIERE_PATH="./$COMPOSE_PROJECT_NAME"

SRC_ADEMPIERE_BINARY=binary_${ADEMPIERE_VERSION//.}""
PATH_ADEMPIERE_VERSION="./$SRC_ADEMPIERE_BINARY"

ADEMPIERE_BINARY=Adempiere_${ADEMPIERE_VERSION//.}"LTS.tar.gz"
export ADEMPIERE_BINARY;
export ADEMPIERE_VERSION;

URL="https://github.com/adempiere/adempiere/releases/download/"$ADEMPIERE_VERSION"/"$ADEMPIERE_BINARY

if [[ "$(docker images -q adempiere:$ADEMPIERE_VERSION 2> /dev/null)" == "" ]]; 
then
    if [ -d "$PATH_ADEMPIERE_VERSION" ] 
    then
        echo "Directorio del archivo binario ya creado"
    else
        echo "Crear el directorio binario en: /binary_${ADEMPIERE_VERSION//.}"
        mkdir -p $BASE_DIR"/binary_"${ADEMPIERE_VERSION//.}
    fi
    if [ -d "$PATH_ADEMPIERE_VERSION" ] 
    then
        if [ -f "$PATH_ADEMPIERE_VERSION/$ADEMPIERE_BINARY" ] 
        then
            echo "Instalación basada en ADempiere $ADEMPIERE_VERSION"
        else
            echo "Adempiere dirección $PATH_ADEMPIERE_VERSION"
            echo "Adempiere Versión $ADEMPIERE_VERSION"
            echo "Adempiere Binary $PATH_ADEMPIERE_VERSION/$ADEMPIERE_BINARY"
            echo "Descargar de $URL"
            curl -L $URL > "$PATH_ADEMPIERE_VERSION/$ADEMPIERE_BINARY"
            if [ -f "$PATH_ADEMPIERE_VERSION/$ADEMPIERE_BINARY" ] 
            then
                echo "Adempiere Binary se descargó exitosamente."
            else
                echo "Adempiere Binary no descargada."
                exit
            fi
        fi
    else
        echo "No se encontró el directorio del proyecto para : $COMPOSE_PROJECT_NAME "
    fi
    
    docker build \
        -t adempiere:$ADEMPIERE_VERSION \
        --build-arg ADEMPIERE_BINARY=$ADEMPIERE_BINARY \
        --build-arg ADEMPIERE_SRC_DIR=./binary_${ADEMPIERE_VERSION//.}"" \
        "$BASE_DIR" 
fi

# Generar el archivo Dockerfile para tomar la versión de recibida.
sed "s/imagenaqui/adempiere:$ADEMPIERE_VERSION/g" "$BASE_DIR/adempiere-last/BaseDocker" > "$BASE_DIR/adempiere-last/Dockerfile"

# Ejecutar docker-compose
echo
    docker-compose \
    -f "$BASE_DIR/adempiere.yml" \
    -p "$COMPOSE_PROJECT_NAME" \
    $2 \
    $3 \
    $4 \
    $5