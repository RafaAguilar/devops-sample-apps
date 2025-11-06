# Builder
FROM golang:1.25-alpine AS builder

WORKDIR /app

COPY go.mod ./
RUN go mod download
COPY . .
RUN CGO_ENABLED=0 GOOS=linux go build -o main .

# Runner
FROM alpine:latest

RUN apk --no-cache add ca-certificates && \
    addgroup -g 1001 appgroup && \
    adduser -D -u 1001 -G appgroup appuser && \
    mkdir /app && \
    chown -R appuser:appgroup /app

COPY --from=builder /app/main /go/bin/main
RUN chmod +x /go/bin/main


USER appuser
WORKDIR /app

EXPOSE 80

ENTRYPOINT ["/go/bin/main"]
