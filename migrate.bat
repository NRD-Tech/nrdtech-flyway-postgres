@echo off
set PWD=%cd%

docker run ^
--env FLYWAY_PLACEHOLDERS_ENV=dev ^
--env HOST=host.docker.internal ^
--env PORT=5432 ^
--env SCHEMA=public ^
--env USER=postgres ^
--env DB=mydb ^
--env PASS=dev ^
--rm ^
-v "%PWD%/migration":/flyway/migration ^
-v "%PWD%/static":/flyway/static ^
-v "%PWD%/conf":/flyway/conf ^
-v "%PWD%/drivers":/flyway/drivers ^
redgate/flyway:9.19.1 ^
-configFiles=conf/config.ini ^
migrate
