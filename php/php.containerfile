# Builder
FROM php:8.2-alpine AS builder

WORKDIR /tmp

COPY index.php ./

# Runner
FROM alpine:latest

# Install PHP and required packages
RUN apk --no-cache add php php-fpm php-cli php-json php-curl

RUN addgroup -g 1001 appgroup && \
    adduser -D -u 1001 -G appgroup appuser && \
    mkdir -p /var/www/html && \
    chown -R appuser:appgroup /var/www/html

COPY --from=builder --chown=appuser:appgroup /tmp/ /var/www/html/
USER appuser
WORKDIR /var/www/html

# Expose port 80
EXPOSE 80

# TODO: remove when bug in app is solved.
ENV APP_ENV=prod

CMD ["php", "-S", "0.0.0.0:80"]
