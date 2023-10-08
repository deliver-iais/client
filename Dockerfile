FROM 172.17.4.40:443/cirrusci/flutter-web:3.3.1 as builder

COPY pubspec.yaml /usr/local/bin/app/pubspec.yaml
COPY pubspec.lock /usr/local/bin/app/pubspec.lock

# Set the working directory to the app files within the container
WORKDIR /usr/local/bin/app

# Get App Dependencies
RUN flutter doctor -v
RUN flutter upgrade 3.10.5 --force
RUN flutter pub get

# Copy the app files to the container
COPY . /usr/local/bin/app

# Build the app for the web
RUN flutter build web --release --no-sound-null-safety --web-renderer canvaskit

FROM 172.17.4.40:443/nginx:1.23.3-alpine

COPY --from=builder /usr/local/bin/app/build/web/ /usr/share/nginx/html/
