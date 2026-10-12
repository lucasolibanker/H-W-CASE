# Debian 13. A base tem CVE de pacote do sistema.
# As bibliotecas Python vêm do requirements.txt.
FROM python:3.12-slim

WORKDIR /app

# Sem compilador na imagem final: as deps têm wheel.
COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

COPY app ./app
COPY config ./config

# A API não precisa de root para escutar na 8000.
RUN useradd --create-home --uid 10001 appuser \
    && chown -R appuser:appuser /app
USER appuser

EXPOSE 8000

# Um worker. A concorrência do PoC de corrida vem do threadpool do FastAPI
# (rotas síncronas) mais o Redis. Vários workers também funcionariam, porque
# a trava é o SET NX, não a memória do processo.
CMD ["uvicorn", "app.main:app", "--host", "0.0.0.0", "--port", "8000", "--workers", "1"]
