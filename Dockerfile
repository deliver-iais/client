FROM 172.17.4.40:443/deliver-web-builder:1.0.0 as builder

# Copy the app files to the container
COPY . /usr/local/bin/app

# Build the app for the web
RUN flutter build web --release

FROM 172.17.4.40:443/nginx:1.19.8-alpine

COPY --from=builder /usr/local/bin/app/build/web/ /usr/share/nginx/html/
