# ---------- Base image ----------
FROM python:3.14-slim

# ---------- Environment ----------
ENV PYTHONDONTWRITEBYTECODE=1
ENV PYTHONUNBUFFERED=1

# ---------- System dependencies ----------
RUN apt-get update && apt-get install -y \
    build-essential \
    gcc \
    libmariadb-dev \
    default-libmysqlclient-dev \
    pkg-config \
    curl \
    && rm -rf /var/lib/apt/lists/*

# ---------- Create non-root user ----------
RUN useradd -m appuser

# ---------- Set working directory ----------
WORKDIR /app

# ---------- Install Python dependencies ----------
COPY requirements.txt .

RUN pip install --upgrade pip && \
    pip install --no-cache-dir -r requirements.txt

# ---------- Copy project ----------
COPY . .

# ---------- Collect static files ----------
RUN python manage.py collectstatic --noinput

# ---------- Set permissions ----------
RUN chown -R appuser:appuser /app

USER appuser

# ---------- Expose port ----------
EXPOSE 8000

# ---------- Healthcheck (optional but recommended) ----------
HEALTHCHECK CMD curl --fail http://localhost:8000 || exit 1

# ---------- Start Gunicorn ----------
CMD ["gunicorn", "core.wsgi:application", \
     "--bind", "0.0.0.0:8000", \
     "--workers", "3", \
     "--threads", "2", \
     "--timeout", "120"]