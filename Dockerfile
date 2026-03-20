# Stage 1: Build
FROM debian:latest AS build-env

RUN apt-get update && apt-get install -y curl git wget unzip libgconf-2-4 gdb libstdc++6 libglu1-mesa fonts-droid-fallback python3 sed
RUN apt-get clean

# Fix for flutter git issue
RUN git config --global --add safe.directory /usr/local/flutter

# Install Flutter
RUN git clone https://github.com/flutter/flutter.git /usr/local/flutter
ENV PATH="/usr/local/flutter/bin:/usr/local/flutter/bin/cache/dart-sdk/bin:${PATH}"

RUN flutter doctor -v
RUN flutter config --enable-web

# Copy project files
WORKDIR /app
COPY aegis_copilot/pubspec.yaml /app/
RUN flutter pub get
COPY aegis_copilot /app
RUN flutter build web --release

# Stage 2: Serve
FROM nginx:alpine
COPY --from=build-env /app/build/web /usr/share/nginx/html
COPY nginx.conf /etc/nginx/conf.d/config.template

# Support Cloud Run port
CMD /bin/sh -c "envsubst '\$PORT' < /etc/nginx/conf.d/config.template > /etc/nginx/conf.d/default.conf && nginx -g 'daemon off;'"

