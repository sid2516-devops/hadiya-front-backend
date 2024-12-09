DB_HOST='example.com'
DB_PORT=3306
DB_NAME='hadiya-products'
DB_USERNAME='test'
DB_PASSWORD='password'

docker run -dit --rm \
  -v ./sql:/flyway/sql \
  -v ./reports:/flyway/reports \
  redgate/flyway:latest \
  -url=jdbc:mysql://db?allowPublicKeyRetrieval=true -schemas=myschema -user=root -password=P@ssw0rd -connectRetries=60 -reportFilename=/flyway/reports/report.html migrate

docker run -dit \
  -v ./reports/report.html:/usr/share/nginx/html/index.html \
  -p 8080:80 \
  nginx:stable-alpine
