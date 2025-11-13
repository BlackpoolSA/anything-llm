# Build Script README

Este documento explica cómo usar el script `build.sh` para construir y gestionar el entorno de desarrollo de AnythingLLM.

## Descripción

El script `build.sh` es una herramienta automatizada que facilita la construcción, ejecución y reinicio completo del entorno de desarrollo de AnythingLLM usando Docker Compose.

## Requisitos Previos

- **Docker**: Debe estar instalado y ejecutándose
- **Docker Compose**: Debe estar disponible en el PATH
- **Permisos**: El script debe tener permisos de ejecución (`chmod +x build.sh`)

## Uso

### Construcción Normal

Para construir y ejecutar AnythingLLM normalmente:

```bash
./build.sh
```

Este comando:
- Verifica los prerrequisitos (Docker y Docker Compose)
- Construye la imagen de Docker si es necesario
- Inicia los contenedores
- Espera a que los servicios estén listos
- Muestra el estado de los contenedores

### Reset Completo

Para realizar un reinicio completo eliminando todos los datos:

```bash
./build.sh --clean
# o
./build.sh --reset
```

Este comando realiza un **reset completo** que incluye:
- Detiene y elimina todos los contenedores
- Elimina todos los volúmenes de Docker
- Limpia directorios de almacenamiento local:
  - `server/storage/`
  - `collector/hotdir/`
  - `collector/outputs/`
  - `server/prisma/migrations/`
- Resetea la configuración del entorno (`.env`)
- Reconstruye todo desde cero

## Opciones

| Opción | Descripción |
|--------|-------------|
| `--clean`, `--reset` | Realiza un reset completo eliminando todos los datos |
| `--help`, `-h` | Muestra la ayuda y opciones disponibles |

## Lo que hace el Reset Completo

### Limpieza de Docker
- Detiene y elimina contenedores con `docker-compose down --remove-orphans`
- Elimina volúmenes con `docker-compose down -v --remove-orphans`
- Limpia volúmenes huérfanos con `docker volume prune -f`

### Limpieza de Archivos Locales
- Elimina el directorio `server/storage/` (datos persistentes)
- Elimina el directorio `collector/hotdir/` (archivos temporales)
- Elimina el directorio `collector/outputs/` (resultados de procesamiento)
- Elimina el directorio `server/prisma/migrations/` (migraciones de base de datos)

### Reset de Configuración
- Restaura el archivo `.env` desde `.env.example`
- Recrea directorios necesarios vacíos

### Reconstrucción
- Construye la imagen de Docker desde cero
- Inicia todos los servicios
- Espera a que estén saludables

## Estados del Contenedor

Después de la ejecución, el script muestra el estado de los contenedores:

```
NAME          IMAGE                      COMMAND                  SERVICE        CREATED         STATUS                    PORTS
anythingllm   anythingllm-anything-llm   "/bin/bash /usr/loca…"   anything-llm   23 seconds ago  Up 10 seconds (healthy)  0.0.0.0:3001->3001/tcp
```

- **STATUS**: Debe mostrar "Up" y "(healthy)" para indicar que está funcionando correctamente
- **PORTS**: Debe mostrar `0.0.0.0:3001->3001/tcp` para acceso en localhost:3001

## Acceso a la Aplicación

Una vez que el script complete exitosamente, puedes acceder a AnythingLLM en:

**URL**: http://localhost:3001

## Solución de Problemas

### El contenedor no está saludable
```bash
# Ver logs del contenedor
docker-compose -f docker/docker-compose.yml logs

# Ver estado detallado
docker-compose -f docker/docker-compose.yml ps
```

### Error de permisos
```bash
# Asegurar permisos de ejecución
chmod +x build.sh
```

### Puerto 3001 ocupado
```bash
# Ver qué está usando el puerto
lsof -i :3001

# Cambiar el puerto en docker/.env si es necesario
```

### Problemas de Docker
```bash
# Verificar que Docker esté ejecutándose
docker info

# Limpiar imágenes no utilizadas
docker system prune -a
```

## Archivos Relacionados

- `docker/docker-compose.yml`: Configuración de Docker Compose
- `docker/.env`: Variables de entorno para Docker
- `docker/.env.example`: Plantilla de configuración
- `docker/docker-entrypoint.sh`: Script de inicialización del contenedor

## Notas Importantes

- **Datos Persistentes**: El reset completo elimina TODOS los datos. Asegúrate de hacer backup si es necesario.
- **Tiempo de Construcción**: La primera construcción puede tomar varios minutos.
- **Espacio en Disco**: Asegúrate de tener suficiente espacio para las imágenes de Docker.
- **Red**: El contenedor usa `host.docker.internal` para acceso al host.

## Desarrollo

Para desarrollo local sin Docker, consulta el README principal del proyecto para instrucciones de desarrollo nativo.