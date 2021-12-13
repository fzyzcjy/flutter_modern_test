set -eux

# 注：首先需要安装protoc的dart插件，见https://pub.dev/packages/protoc_plugin
protoc --proto_path=. --dart_out=../lib/src/protobuf ./test_tool.proto

