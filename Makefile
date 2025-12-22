.PHONY: run dev backend frontend install setup db clean help

# Default target - run everything
run: 
	@echo "🚀 Starting BlowJobs.ai..."
	@make -j2 backend frontend

# Run in development mode with hot reload
dev:
	@echo "🔧 Starting in development mode..."
	@make -j2 backend frontend

# Start backend only
backend:
	@echo "🖥️  Starting Go backend on http://localhost:8080..."
	@cd backend && go run cmd/server/main.go

# Start frontend only (web mode - no emulator needed!)
frontend:
	@echo "📱 Starting Flutter frontend on http://localhost:3000..."
	@cd frontend && flutter run -d chrome --web-port=3000

# Start frontend on a different port (if 3000 is busy)
frontend-web:
	@cd frontend && flutter run -d web-server --web-port=8081

# Install all dependencies
install:
	@echo "📦 Installing dependencies..."
	@cd backend && go mod download
	@cd frontend && flutter pub get
	@echo "✅ Dependencies installed!"

# First-time setup
setup: install db
	@echo "✅ Setup complete! Run 'make run' to start."

# Database setup (requires PostgreSQL running)
db:
	@echo "🗄️  Setting up database..."
	-createdb blowjobs 2>/dev/null || echo "Database may already exist"
	@echo "✅ Database ready!"

# Start with Docker (includes database)
docker:
	@echo "🐳 Starting with Docker..."
	docker-compose up -d
	@echo "✅ Services running!"
	@echo "   Backend: http://localhost:8080"
	@echo "   Database: localhost:5432"

# Stop Docker services
docker-stop:
	docker-compose down

# Clean build artifacts
clean:
	@echo "🧹 Cleaning..."
	@cd frontend && flutter clean
	@rm -f backend/main
	@echo "✅ Clean!"

# Help
help:
	@echo "BlowJobs.ai - Available commands:"
	@echo ""
	@echo "  make run        - Start backend + frontend (web)"
	@echo "  make install    - Install all dependencies"
	@echo "  make setup      - First-time setup (install + db)"
	@echo "  make backend    - Start backend only"
	@echo "  make frontend   - Start frontend in Chrome"
	@echo "  make docker     - Start with Docker"
	@echo "  make clean      - Clean build files"
	@echo ""
	@echo "Testing options:"
	@echo "  Chrome (default) - No emulator needed!"
	@echo "  Android          - make frontend-android"
	@echo "  iOS (macOS only) - make frontend-ios"

# Platform-specific frontend targets
frontend-android:
	@cd frontend && flutter run -d android

frontend-ios:
	@cd frontend && flutter run -d ios

frontend-windows:
	@cd frontend && flutter run -d windows

