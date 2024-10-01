# Node Modules
FROM node:18 as nodemodules

WORKDIR /stuff

COPY package*.json /stuff/

RUN npm ci


# Build
FROM node:18 as build

WORKDIR /app

COPY . /app

COPY --from=nodemodules /stuff/node_modules/ /app/node_modules

RUN npm install -g ionic

RUN ionic build --configuration web


# Generate Self Signed Certificate
FROM node:18 as certificate

WORKDIR /certificate

RUN apt-get update && \
    apt-get install -y openssl && \
    openssl genrsa -out server.pass.key 2048 && \
    openssl rsa -in server.pass.key -out server.key && \
    rm server.pass.key && \
    openssl req -new -key server.key -out server.csr \
        -subj "/O=james9001" && \
    openssl x509 -req -days 365 -in server.csr -signkey server.key -out server.crt


# Runtime
FROM nginx:1.20.1 as runtime

WORKDIR /etc/nginx

COPY --from=build /app/www/ /usr/share/nginx/html

COPY /nginx-custom.conf /etc/nginx/conf.d/default.conf

COPY entrypoint-custom.sh /entrypoint-custom.sh

COPY --from=certificate /certificate/server.key /certificate/server.key
COPY --from=certificate /certificate/server.crt /certificate/server.crt

ENTRYPOINT ["/entrypoint-custom.sh"]
CMD ["nginx", "-g", "daemon off;"]
