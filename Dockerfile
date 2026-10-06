FROM golang:1.22-alpine AS builder

WORKDIR /src

COPY app/go.mod ./
RUN go mod download

COPY app/ ./

RUN CGO_ENABLED=0 GOOS=linux go build \
    -o /out/greeter .

FROM gcr.io/distroless/static-debian12:nonroot

COPY --from=builder /out/greeter /greeter

EXPOSE 8080

ENTRYPOINT ["/greeter"]