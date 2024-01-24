FROM nginx:1.25.1-alpine3.17 AS nginx
COPY nginx.conf /etc/nginx/nginx.conf

# FROM redmine:4.2.10-alpine3.16 AS redmine
FROM redmine:5.0.5-alpine3.18 AS redmine
COPY config.ru .

FROM ruby:3.2.2-alpine3.18 AS onlyoffice-redmine-build
WORKDIR /srv
COPY . .
RUN \
	apk update && \
	apk add --no-cache git make && \
	make build

FROM alpine:3.18.3 AS onlyoffice-redmine
WORKDIR /srv
COPY --from=onlyoffice-redmine-build /srv/.build/onlyoffice_redmine .
