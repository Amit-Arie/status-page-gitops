FROM python:3.10-slim

ENV PYTHONUNBUFFERED=1 \
    PYTHONDONTWRITEBYTECODE=1

WORKDIR /opt/status-page

RUN apt-get update && apt-get install -y --no-install-recommends \
    build-essential \
    libpq-dev \
    gcc \
    curl \
    && rm -rf /var/lib/apt/lists/*

COPY requirements.txt ./
RUN pip install --no-cache-dir --upgrade pip && \
    pip install --no-cache-dir "rq==1.10.1" "rq-scheduler==0.11.0" -r requirements.txt gunicorn

COPY . .

EXPOSE 8000

CMD ["gunicorn", "-b", "0.0.0.0:8000", "statuspage.wsgi:application"]
