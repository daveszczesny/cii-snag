build-model:
	@echo "Building models..."
	flutter packages pub run build_runner build
	@echo "Models built successfully."

build-apk:
	flutter build apk --release