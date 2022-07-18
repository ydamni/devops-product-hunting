### ### Build server API
### Base image
FROM alpine:3.16

### Define working directory inside image
WORKDIR /app

### Add arguments
ARG POSTGRES_USER
ARG POSTGRES_PASSWORD
ARG POSTGRES_DB

### Add environment variables
ENV POSTGRES_USER=$POSTGRES_USER
ENV POSTGRES_PASSWORD=$POSTGRES_PASSWORD
ENV POSTGRES_DB=$POSTGRES_DB
ENV POSTGRES_HOST="postgres"
ENV POSTGRES_PORT=5432

### Copy the content of the build's context to the working directory
### Example in shell: cp application/backend/api/* /app/
COPY . .

### Install nodejs
RUN apk add --no-cache nodejs

### ### Run server API
### Expose API port 5000
EXPOSE 5000

### Launch server
CMD node --require './tracing.js' index.js
