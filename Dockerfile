# build container using an LTS Node version
# does not get deployed to runtime
FROM node:18-alpine AS builder

# Make sure we ot brotli
RUN apk update
RUN apk add --upgrade brotli

# Create app directory
WORKDIR /usr
COPY package*.json ./
COPY src ./src
COPY public ./public
RUN npm install
RUN npm run build
RUN cd /usr/dist && find . -type f -exec brotli -v -Z {} \;

# Actual runtime container
FROM alpine
RUN apk add brotli nginx nginx-mod-http-brotli

#COPY nginx/*.conf /etc/nginx/
COPY nginx/nginx.conf /etc/nginx/nginx.conf
COPY nginx/error404.* /usr/share/nginx/html/
COPY nginx/favicon.* /usr/share/nginx/html/

# Actual data
COPY --from=builder /usr/dist /usr/share/nginx/html/
CMD ["nginx", "-g", "daemon off;"]
EXPOSE 80