FROM golang:1.16.2 AS builder
WORKDIR /usr/local/go/src/rar
COPY go.mod ./
RUN go mod download
COPY main.go ./
RUN CGO_ENABLED=0 go build -ldflags '-extldflags "-static"' -o /rar .
RUN chmod +x /rar

FROM scratch
COPY --from=builder /rar .
ENTRYPOINT ["/rar"]