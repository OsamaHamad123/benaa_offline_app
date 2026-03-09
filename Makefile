.PHONY: gen seed clean-db run-windows run-android smoke-codes help

BASE_URL ?= https://palestine.benaadev.org
SMOKE_EMAIL ?= admin@gmail.com
SMOKE_PASSWORD ?= password
SMOKE_DEVICE ?= copilot-smoke-device-final
SMOKE_COUNT ?= 1

help:
	@echo "Available commands:"
	@echo "  make gen          - Generate Drift and JSON serialization code"
	@echo "  make seed         - Seed database with test data"
	@echo "  make clean-db     - Delete local database"
	@echo "  make run-windows  - Run app on Windows"
	@echo "  make run-android  - Run app on Android"
	@echo "  make smoke-codes  - Run live mobile codes contract smoke test"

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

smoke-codes:
	powershell -ExecutionPolicy Bypass -File .\scripts\smoke_codes_contract.ps1 -BaseUrl "$(BASE_URL)" -Email "$(SMOKE_EMAIL)" -Password "$(SMOKE_PASSWORD)" -DeviceId "$(SMOKE_DEVICE)" -RequestCount $(SMOKE_COUNT)
