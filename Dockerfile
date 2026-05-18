# Stage 1: build the Blazor WASM app
FROM mcr.microsoft.com/dotnet/sdk:10.0-alpine AS builder

ARG APP_REPO=https://github.com/atunbey/assemulator
ARG APP_REF=master

RUN apk add --no-cache git

WORKDIR /src
RUN git clone --branch "${APP_REF}" --depth 1 "${APP_REPO}" .

RUN dotnet restore
RUN dotnet publish -c Release -o /out

# Stage 2: serve with nginx
FROM nginx:alpine

ARG BASE_PATH=/assemulator/

COPY --from=builder /out/wwwroot /usr/share/nginx/html
COPY conf/nginx-container.conf /etc/nginx/conf.d/default.conf

# Rewrite <base href> to match the subpath the app will be served from.
# This avoids relying on nginx sub_filter at the reverse-proxy layer.
RUN sed -i "s|<base href=\"/\" />|<base href=\"${BASE_PATH}\" />|" \
        /usr/share/nginx/html/index.html

RUN mkdir -p \
    /usr/share/nginx/html/data \
    /usr/share/nginx/html/roms \
    /usr/share/nginx/html/images \
    /usr/share/nginx/html/bios

EXPOSE 80
