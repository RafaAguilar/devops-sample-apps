# No builder stage needed
FROM alpine:latest

# Install PHP and required packages
RUN apk --no-cache add php php-fpm php-cli php-json php-curl

# Create user, group, and directories
RUN addgroup -g 1001 appgroup && \
    adduser -D -u 1001 -G appgroup appuser && \
    mkdir -p /var/www/html && \
    chown -R appuser:appgroup /var/www/html

# Set user and workdir
USER appuser
WORKDIR /var/www/html

# Copy your code directly from the build context
# (This replaces the builder stage and the COPY --from=builder)
COPY --chown=appuser:appgroup index.php .

# Expose port 80
EXPOSE 80

# TODO: remove when bug in app is solved.
ENV APP_ENV=prod

# Use the built-in PHP server
CMD ["php", "-S", "0.0.0.0:80"]