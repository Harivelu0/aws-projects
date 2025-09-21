#!/bin/bash
set -e

# Run migrations first
echo "Running database migrations..."
python manage.py migrate

# Create admin user if not exists
echo "Creating admin user if not exists..."
python manage.py createsuperuser \
  --noinput \
  --username admin \
  --email admin@example.com || echo "Admin already exists"

# Then start the application
echo "Starting application..."
gunicorn blog_project.wsgi:application --bind 0.0.0.0:8000 --workers 3