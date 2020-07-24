rm -rf lib/generated-protocol/*
protoc --dart_out=grpc:lib/generated-protocol -I proto proto/pub/v1/**.proto proto/pub/v1/models/**.proto