### ### Push data to postgres database
### Base image
FROM postgres:alpine3.16

### Define working directory inside image
WORKDIR /docker-entrypoint-initdb.d

### Add arguments
ARG POSTGRES_USER
ARG POSTGRES_PASSWORD
ARG POSTGRES_DB

### Add environment variables
ENV POSTGRES_USER=$POSTGRES_USER
ENV POSTGRES_PASSWORD=$POSTGRES_PASSWORD
ENV POSTGRES_DB=$POSTGRES_DB

### Copy the content of the build's context to the working directory
### Example in shell: cp application/backend/worker/posts.sql /docker-entrypoint-initdb.d/
COPY posts.sql .

### ### Run postgres database
### Expose database port 5432
EXPOSE 5432
