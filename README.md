# ADempiere Docker

## Requisitos mínimos de Docker

Para usar esta imagen de Docker, debe tener un número de versión de motor Docker mayor
o igual a 3.0.
Para verificar la versión de su instalación de Docker,abra una ventana de terminal y escriba el
siguiente comando:

```
docker info
```

La salida esperada es:

```
...
Server Version: 17.04.0-ce
..
Kernel Version: 3.13.0-24-generic
..
Insecure Registries:
 127.0.0.0/8
```

Para verificar la versión de Docker que está ejecutando en su servidor, mire la propiedad _Server Version_ property.


### Esctructura del proyecto

```
└─ adempiere-docker
   ├─ .env
   ├─ application.sh
   ├─ Dockerfile    
   ├─ adempiere.yml
   ├─ database.yml
   ├─ database.volume.yml
   └─ jdk_img
   | └─ Dockerfile
   └─ binary_<versión>
   |  └─ Adempiere_<versión>LTS.tar.gz
   └─ adempiere-last
   |  ├─ BaseDocker   
   |  ├─ define-adn-ctl.sh
   |  ├─ Dockerfile
   |  └─ start-adempiere.sh
   └─ adempiere (instancia 1)
   |  ├─ .env   
   |  ├─ lib
   |  └─ packages
   └─ adempiere (instancia 1)
   |  ├─ .env   
   |  ├─ lib
   |  └─ packages
   └─ instance N...
   ...
```
#### Archivos .env 

Este archivo contiene las variables de configuración para la implementación sin tener que modificar los script.
```
./.env
```
Contiene las variables globales para la implementación completa.

```
./(nombre_instancia)/.env
```
Contiene las variables locales como los puertos que se mapean al host.


#### Directorio (instancia) adempiere

Este directorio contiene los archivos necesarios para implementar e iniciar una instancia particular de ADempiere.
Aquí encontraremos:
* El instalador Adempiere Adempiere_LTS.tar.gz con la versión especificada, si no existe, se descargará desde la última versión estable.
* lib: Los archivos para copiar en el directorio lib en ADempiere (este directorio contendrá la personalización y personalización de ADempiere.
* paquetes: los archivos para copiar en el directorio de paquetes en ADempiere (este directorio contendrá la localización de un ADempiere).



### adempiere.yml

Este archivo contendrá la definición de nuestros contenedores de la instancia ADempiere.

### Contenedor Postgres 
Si no tiene un servidor de base de datos externo, puede usar el contenedor del servidor postgres definido en este directorio. Debe usar para el argumento ADEMPIERE_DB_INIT con "Y" para cargar base de datos limpia de ADempiere.

### Uso

Este proyecto ya contiene todo lo necesario para funcionar al solo hacer
```
./applitacion.sh adempiere up -d
```
el cual usará las vaiables de entorno definidas en los archivos.
```
.env y adempieere/.env
```
Pero te recomendamos editar dichas variables por seguridad con contraseñas más seguras 
Edite y defina los parámetros para una nueva instancia.

```
nano .env 
nano ./eevolution/.env
```

Una vez hecho esto puedes correr 
```
./applitacion.sh adempiere up -d
```
(adempiere) es el nombre de la carpeta que contiene la instancia individual de adempiere


Este comando docker se encarga de crear todas las imagenes necesarias, el uso del parametro "-d" le dice que lo ejecutemos en segundo plano. 


Para detener los contenedores,se debe  ejecutar el siguiente comando.
```
./application.sh adempiere stop
```

Tenga en cuenta que en el comando anterior usamos la instrucción ```stop``` en lugar de ```down```, esto se debe a que la instrucción ```down``` elimina los contenedores a, ```stop``` solo apagarlos.


### Crear más de una instancia 

Si desea una nueva instancia, solo necesita editar y configurar la definición de dicha instancia en el archivo (Nombre) / .env e iniciar solo esta imagen y contenedor.

Dicha instancia debe tener la estructura de la instancia por defecto llamada adempiere
```
 └─ adempiere (instancia 1)
   |  ├─ .env   
   |  ├─ lib
   |  └─ packages
```

quedando

```
 └─ nueva (instancia 2)
   |  ├─ .env   (Variables de entorno diferentes a la instancia 1)
   |  ├─ lib
   |  └─ packages
```

Posterior a esto, ejecutar dicha instancia

```
./application.sh nueva up -d 
```


Si necesita una copia de seguridad de la base de datos usa el siguiente comando


```
./application.sh eevolution exec adempiere /opt/Adempiere/utils/RUN_DBExport.sh

```

Para obtener el zip del respaldo :

```
./application.sh eevolution exec adempiere "cat /opt/Adempiere/data/ExpDat.dmp" \ 
| gzip >  "backup.$(date +%F_%R).gz"
```

## Ingresar a contenedor adempiere 

```
docker exec -it <nombre_contedor> bash
ejemplo:
docker exec -it adempiere bash
```
con este comando tenemos acceso a la terminal para ejecutar comandos dentro del contenedor

para hacer una copia de las librerías que hemos pasado a contenedor  por medio de la carpeta
de la instancia 

```
 └─ adempiere (instancia 1)
   |  ├─ .env   
   |  ├─ lib (librerías)
   |  └─ packages (paquetes)
```
Cuando se tengan las librerías correspondientes se procede  a ingresar al contenedor de Adempiere 
y ejecutar la siguientes instrucciones que hacen una copia de las librerías a la carpeta de 
Adempiere

```
cp /opt/Adempiere/lib_volumen/* /opt/Adempiere/lib/
cp /opt/Adempiere/packages_volumen/* /opt/Adempiere/packages/
```

### Contribución

Este proyecto tiene base en hacer mejoras y ajustes para que sea más adaptable y flexible.

https://github.com/adempiere/adempiere-docker
