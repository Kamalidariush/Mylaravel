FROM debian:bookworm-slim

ENV DEBIAN_FRONTEND=noninteractive

RUN apt-get update \
    && apt-get install -y --no-install-recommends \
        pgbackrest \
        postgresql-client \
        ca-certificates \
        tzdata \
        bash \
    && rm -rf /var/lib/apt/lists/*

RUN mkdir -p \
    /etc/pgbackrest \
    /var/log/pgbackrest \
    /var/lib/pgbackrest \
    /backup \
    /var/lib/postgresql/data

CMD ["sleep", "infinity"]