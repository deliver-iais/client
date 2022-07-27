FROM 172.17.4.40:443/cirrusci/flutter-web:3.0.5 as builder

COPY pubspec.yaml /usr/local/bin/app/pubspec.yaml
COPY pubspec.lock /usr/local/bin/app/pubspec.lock

# Set the working directory to the app files within the container
WORKDIR /usr/local/bin/app

# Get App Dependencies
RUN flutter pub get

# Copy the app files to the container
COPY . /usr/local/bin/app

ARG build_number
ARG build_name

# Build the app for the web
RUN flutter build appbundle --target-platform android-arm --build-name=$build_name --build-number=$build_number
