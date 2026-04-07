FROM python:3.11-slim

ENV PYTHONDONTWRITEBYTECODE=1 \
    PYTHONUNBUFFERED=1

WORKDIR /app

RUN groupadd --system --gid 10001 appuser \
    && useradd --system --uid 10001 --gid 10001 --create-home --home-dir /home/appuser appuser

COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

COPY app.py .
RUN chown -R 10001:10001 /app /home/appuser

USER 10001:10001

EXPOSE 5000

CMD ["python", "app.py"]