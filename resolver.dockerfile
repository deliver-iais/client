FROM 172.17.4.40:443/cirrusci/flutter-web:3.0.5 as builder

RUN flutter precache --android

COPY pubspec.yaml /usr/local/bin/app/pubspec.yaml
COPY pubspec.lock /usr/local/bin/app/pubspec.lock

# Set the working directory to the app files within the container
WORKDIR /usr/local/bin/app

# Get App Dependencies
RUN flutter pub get

# Copy the app files to the container
COPY . /usr/local/bin/app

WORKDIR /usr/local