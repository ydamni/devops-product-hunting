### ### Build client web app
### Base image
FROM nginx:1.23.0-alpine

### Define working directory inside image
WORKDIR /usr/share/nginx/html

### Add the content of the build's context to the working directory
### Example in shell: cp application/frontend/client/build/* /usr/share/nginx/html
ADD build .

### Replace the nginx configuration file
COPY nginx_conf/default.conf /etc/nginx/conf.d/

### ### Run server API
### Expose web app port 80 & 443
EXPOSE 80 443
