### ### Build client web app
### Base image
FROM alpine:3.16

### Define working directory inside image
WORKDIR /app

### Add argument
ARG REACT_APP_API_URL

### Add environment variable
ENV REACT_APP_API_URL=$REACT_APP_API_URL

### Copy the content of the build's context to the working directory
### Example in shell: cp application/frontend/client/* /app/
COPY . .

### Install npm
RUN apk add --no-cache npm

### ### Run server API
### Expose web app port 3000
EXPOSE 3000

### Launch client
CMD npm start
