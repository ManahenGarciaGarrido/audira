# 🐳 INSTRUCCIONES DE USO CON DOCKER

## ¿Por qué necesitas Docker?

Para ejecutar el servicio Spring Boot (`mvn spring-boot:run`), necesitas tener PostgreSQL corriendo. Docker facilita esto creando un contenedor con PostgreSQL ya configurado.

---

## 📦 Requisitos Previos

1. **Docker Desktop instalado y corriendo**
   - Windows/Mac: [Docker Desktop](https://www.docker.com/products/docker-desktop/)
   - Linux: `sudo apt-get install docker.io docker-compose`

2. **Verificar que Docker funciona:**
   ```bash
   docker --version
   docker-compose --version
   ```

---

## 🚀 Cómo usar en cada subtarea

### Subtarea 1, 2, 3 o 4

Cada subtarea tiene su propio sistema Docker independiente.

### En Windows (PowerShell o CMD):

```powershell
# 1. Ir a la carpeta de la subtarea
cd implementacion-progresiva/subtarea1

# 2. Iniciar PostgreSQL
start.bat

# 3. En otra terminal, ir al servicio y ejecutar Spring Boot
cd ../../community-service
mvn spring-boot:run

# 4. Cuando termines, detener PostgreSQL
cd ../implementacion-progresiva/subtarea1
stop.bat
```

### En Linux/Mac (Terminal):

```bash
# 1. Ir a la carpeta de la subtarea
cd implementacion-progresiva/subtarea1

# 2. Dar permisos de ejecución (solo primera vez)
chmod +x start.sh stop.sh

# 3. Iniciar PostgreSQL
./start.sh

# 4. En otra terminal, ir al servicio y ejecutar Spring Boot
cd ../../community-service
mvn spring-boot:run

# 5. Cuando termines, detener PostgreSQL
cd ../implementacion-progresiva/subtarea1
./stop.sh
```

---

## 📝 Lo que hacen los scripts

### `start.bat` / `start.sh`
- Levanta un contenedor Docker con PostgreSQL 15 Alpine
- Crea la base de datos `audira_community`
- Expone el puerto `5432` para conexiones
- Espera 5 segundos a que PostgreSQL esté listo
- Muestra un resumen de la configuración

### `stop.bat` / `stop.sh`
- Detiene el contenedor de PostgreSQL
- Limpia los recursos (pero mantiene los datos en volúmenes)

---

## 🔧 Configuración de PostgreSQL

Todas las subtareas usan la misma configuración:

| Parámetro | Valor |
|-----------|-------|
| **Host** | localhost |
| **Puerto** | 5432 |
| **Base de datos** | audira_community |
| **Usuario** | postgres |
| **Contraseña** | postgres |

Esto coincide con tu `application.yml`:
```yaml
spring:
  datasource:
    url: jdbc:postgresql://localhost:5432/audira_community
    username: postgres
    password: postgres
```

---

## 🐛 Solución de Problemas

### Error: "Cannot connect to the Docker daemon"
**Problema:** Docker Desktop no está corriendo.
**Solución:** Abre Docker Desktop y espera a que se inicie completamente.

### Error: "Port 5432 is already in use"
**Problema:** Ya tienes PostgreSQL corriendo (local o en otro contenedor).
**Solución:**
```bash
# Ver qué está usando el puerto
# Windows:
netstat -ano | findstr :5432

# Linux/Mac:
lsof -i :5432

# Detener PostgreSQL local
# Windows:
net stop postgresql-x64-15

# Linux/Mac:
sudo systemctl stop postgresql

# O detener otro contenedor Docker:
docker ps
docker stop <container_id>
```

### Error: "Permission denied" al ejecutar .sh en Linux
**Problema:** El script no tiene permisos de ejecución.
**Solución:**
```bash
chmod +x start.sh stop.sh
```

### Error: "spring.datasource.url" no definido
**Problema:** El archivo `application.yml` no está en la ruta correcta.
**Solución:** Asegúrate de copiar `application.yml` a `community-service/src/main/resources/`

### PostgreSQL tarda mucho en iniciar
**Problema:** Primera vez que descargas la imagen.
**Solución:** La primera vez, Docker descargará la imagen de PostgreSQL (~80MB). Las siguientes veces será instantáneo.

---

## 📊 Verificar que PostgreSQL está corriendo

### Opción 1: Ver contenedores activos
```bash
docker ps
```
Deberías ver algo como:
```
CONTAINER ID   IMAGE                PORTS                    NAMES
abc123def456   postgres:15-alpine   0.0.0.0:5432->5432/tcp   audira-community-db-subtarea1
```

### Opción 2: Conectarte con psql (si lo tienes instalado)
```bash
psql -h localhost -U postgres -d audira_community
# Contraseña: postgres
```

### Opción 3: Ver logs del contenedor
```bash
docker logs audira-community-db-subtarea1
```

---

## 🧹 Limpiar Datos (Reset de Base de Datos)

Si quieres empezar desde cero:

```bash
# 1. Detener PostgreSQL
stop.bat  # o ./stop.sh

# 2. Eliminar volúmenes (CUIDADO: esto borra todos los datos)
docker-compose down -v

# 3. Reiniciar
start.bat  # o ./start.sh
```

---

## 🔄 Cambiar entre subtareas

Cada subtarea tiene su propio volumen de datos independiente:
- `postgres-community-data-subtarea1`
- `postgres-community-data-subtarea2`
- `postgres-community-data-subtarea3`
- `postgres-community-data-subtarea4`

**IMPORTANTE:** Solo puedes tener UNA subtarea corriendo a la vez (todas usan el puerto 5432).

Para cambiar de subtarea:
```bash
# 1. Detener la subtarea actual
cd implementacion-progresiva/subtarea1
stop.bat

# 2. Iniciar la nueva subtarea
cd ../subtarea2
start.bat
```

---

## 💡 Consejos

1. **Mantén Docker Desktop abierto** mientras trabajas con las subtareas
2. **Un solo PostgreSQL a la vez** - detén una subtarea antes de iniciar otra
3. **Los datos persisten** - aunque detengas el contenedor, los datos se mantienen en volúmenes
4. **Usa `docker ps`** para ver qué contenedores están corriendo
5. **En producción**, cambia las credenciales por defecto (postgres/postgres)

---

## 🎯 Flujo de Trabajo Completo

```
┌─────────────────────────────────────────────────────────┐
│ 1. Iniciar Docker Desktop                              │
└─────────────────────────────────────────────────────────┘
                        │
                        ▼
┌─────────────────────────────────────────────────────────┐
│ 2. cd implementacion-progresiva/subtareaN              │
│    start.bat  (o ./start.sh)                           │
└─────────────────────────────────────────────────────────┘
                        │
                        ▼
┌─────────────────────────────────────────────────────────┐
│ 3. Esperar mensaje "PostgreSQL iniciado correctamente!"│
└─────────────────────────────────────────────────────────┘
                        │
                        ▼
┌─────────────────────────────────────────────────────────┐
│ 4. cd ../../community-service                          │
│    mvn spring-boot:run                                 │
└─────────────────────────────────────────────────────────┘
                        │
                        ▼
┌─────────────────────────────────────────────────────────┐
│ 5. Probar endpoints con curl o Postman                │
└─────────────────────────────────────────────────────────┘
                        │
                        ▼
┌─────────────────────────────────────────────────────────┐
│ 6. Cuando termines:                                    │
│    Ctrl+C (para detener Spring Boot)                   │
│    cd ../implementacion-progresiva/subtareaN           │
│    stop.bat  (o ./stop.sh)                            │
└─────────────────────────────────────────────────────────┘
```

---

## 📚 Recursos Adicionales

- [Docker Documentation](https://docs.docker.com/)
- [PostgreSQL Docker Image](https://hub.docker.com/_/postgres)
- [Docker Compose Documentation](https://docs.docker.com/compose/)

---

**¿Problemas?** Revisa la sección de "Solución de Problemas" arriba o consulta el README.md de cada subtarea.
