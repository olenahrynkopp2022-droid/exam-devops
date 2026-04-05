# Django Hello World

A simple Django application that returns "Hello, World!" and is packaged for Kubernetes deployment with Helm.

## Tech Stack

- **Python 3.12** / **Django 6.0.2**
- **Docker** for containerization
- **Helm** for Kubernetes deployment

## Project Structure

```
.
├── Dockerfile                  # Docker image definition
├── manage.py                   # Django management entry point
├── requirements.txt            # Python dependencies
├── mysite/                     # Django project configuration
│   ├── settings.py             # Project settings (SQLite, DEBUG, etc.)
│   ├── urls.py                 # Root URL configuration
│   ├── wsgi.py                 # WSGI entry point
│   └── asgi.py                 # ASGI entry point
├── myapp/                      # Application module
│   ├── views.py                # "Hello, World!" view
│   ├── urls.py                 # App-level URL routing
│   ├── models.py               # Database models (empty)
│   └── migrations/             # Database migrations
└── helm-charts-hello-world/    # Helm chart for Kubernetes
    ├── Chart.yaml              # Chart metadata
    ├── values.yaml             # Default values
    ├── values-dev.yaml         # Dev environment overrides
    ├── values-prod.yaml        # Prod environment overrides
    └── templates/              # Kubernetes manifest templates
        ├── deployment.yaml
        ├── service.yaml
        ├── ingress.yaml
        ├── hpa.yaml
        └── serviceaccount.yaml
```

## Running Locally

### Prerequisites

- Python 3.12+ (or older versions, but it has not been tested).

### Steps

```bash
# Create and activate a virtual environment (if it's run in local environment)
python -m venv venv
source venv/bin/activate

# Install dependencies
pip install -r requirements.txt

# Apply migrations
python manage.py migrate

# Start the development server
python manage.py runserver
```

The app will be available at **http://127.0.0.1:8000/**.
