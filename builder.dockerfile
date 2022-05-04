FROM 172.17.4.40:443/cirrusci/flutter-web:2.10.5

COPY pubspec.yaml /usr/local/bin/app/pubspec.yaml
COPY pubspec.lock /usr/local/bin/app/pubspec.lock

# Set the working directory to the app files within the container
WORKDIR /usr/local/bin/app

# Get App Dependencies
RUN flutter pub get