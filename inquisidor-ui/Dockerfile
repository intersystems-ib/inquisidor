FROM node:slim AS builder

USER root
WORKDIR /app
COPY /inquisidor-ui .

RUN npm install
RUN node node_modules/@angular/cli/bin/ng build --configuration production

FROM nginx
COPY --from=builder ./app/dist/inquisidor-ui/browser/ /usr/share/nginx/html

COPY /inquisidor-ui/cert/inquisidor_ui.crt /etc/nginx/ssl/inquisidor_ui.crt
COPY /inquisidor-ui/cert/inquisidor_ui.key /etc/nginx/ssl/inquisidor_ui.key

COPY /inquisidor-ui/nginx.conf /etc/nginx/nginx.conf
EXPOSE 80 443