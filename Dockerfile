# Stage 1: build the Blazor WASM app
FROM mcr.microsoft.com/dotnet/sdk:8.0-alpine AS builder

ARG APP_REPO=https://github.com/atunbey/assemulator
ARG APP_REF=master

RUN apk add --no-cache git

WORKDIR /src
RUN git clone --branch "${APP_REF}" --depth 1 "${APP_REPO}" .

RUN dotnet restore
RUN dotnet publish -c Release -o /out

# Stage 2: serve with nginx
FROM nginx:alpine

COPY --from=builder /out/wwwroot /usr/share/nginx/html

RUN mkdir -p \
    /usr/share/nginx/html/data \
    /usr/share/nginx/html/roms \
    /usr/share/nginx/html/images \
    /usr/share/nginx/html/bios

EXPOSE 80
