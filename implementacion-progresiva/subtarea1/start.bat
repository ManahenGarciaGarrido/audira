@echo off
echo ============================================
echo  AUDIRA - Subtarea 1: Iniciando PostgreSQL
echo ============================================
echo.

echo [1/2] Levantando contenedor de PostgreSQL...
docker-compose up -d

echo.
echo [2/2] Esperando a que PostgreSQL este listo...
timeout /t 5 /nobreak >nul

echo.
echo ============================================
echo  PostgreSQL iniciado correctamente!
echo ============================================
echo.
echo  Base de datos: audira_community
echo  Host: localhost
echo  Puerto: 5432
echo  Usuario: postgres
echo  Password: postgres
echo.
echo Ahora puedes ejecutar:
echo   mvn spring-boot:run
echo.
echo Para detener PostgreSQL:
echo   stop.bat
echo ============================================
pause
