FROM nginx:alpine

# Pre-create the volume mount points so nginx starts cleanly
# even before the host directories are populated.
RUN mkdir -p \
    /usr/share/nginx/html/data \
    /usr/share/nginx/html/roms \
    /usr/share/nginx/html/images \
    /usr/share/nginx/html/bios

EXPOSE 80
