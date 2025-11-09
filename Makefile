.PHONY: gen seed clean-db run-windows run-android help

help:
	@echo "Available commands:"
	@echo "  make gen          - Generate Drift and JSON serialization code"
	@echo "  make seed         - Seed database with test data"
	@echo "  make clean-db     - Delete local database"
	@echo "  make run-windows  - Run app on Windows"
	@echo "  make run-android  - Run app on Android"

gen:
	dart run build_runner build --delete-conflicting-outputs

seed:
	@echo "Seeding database... (implement in app settings)"

clean-db:
	@echo "Cleaning database..."
	@powershell -Command "Remove-Item -Path '$$env:USERPROFILE\\Documents\\app.db' -ErrorAction SilentlyContinue"
	@powershell -Command "Remove-Item -Path '$$env:USERPROFILE\\Documents\\app.db-shm' -ErrorAction SilentlyContinue"
	@powershell -Command "Remove-Item -Path '$$env:USERPROFILE\\Documents\\app.db-wal' -ErrorAction SilentlyContinue"

run-windows:
	flutter run -d windows

run-android:
	flutter run -d android
