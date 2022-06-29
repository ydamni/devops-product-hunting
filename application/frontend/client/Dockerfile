### ### Build client web app
### Base image
FROM nginx:1.23.0-alpine

### Define working directory inside image
WORKDIR /usr/share/nginx/html

### Add argument
ARG REACT_APP_API_URL

### Add environment variable
ENV REACT_APP_API_URL=$REACT_APP_API_URL

### Add the content of the build's context to the working directory
### Example in shell: cp application/frontend/client/build/* /usr/share/nginx/html
ADD build .

### ### Run server API
### Expose web app port 80
EXPOSE 80
