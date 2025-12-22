@echo off
echo Seeding database with dummy users...
cd backend
go run cmd/seed/main.go
cd ..
echo.
echo Done! You can now run "npm start" to launch the app.

