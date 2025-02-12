# telegram_bot/Dockerfile

# web_app/Dockerfile

# Используем базовый образ с Debian Bookworm
FROM buildpack-deps:bookworm

# Установим зависимости для Python и компиляции
RUN set -eux; \
    apt-get update; \
    apt-get install -y --no-install-recommends \
        libbluetooth-dev \
        tk-dev \
        uuid-dev \
        gcc \
        wget \
        libssl-dev \
        zlib1g-dev \
        libbz2-dev \
        libreadline-dev \
        libsqlite3-dev \
        curl \
        llvm \
        libncurses5-dev \
        libncursesw5-dev \
        xz-utils \
        tk-dev \
        libffi-dev \
        liblzma-dev \
        python3-openssl \
    ; \
    rm -rf /var/lib/apt/lists/*

# Устанавливаем Python 3.12
ENV PYTHON_VERSION 3.12.7
ENV PYTHON_SHA256 24887b92e2afd4a2ac602419ad4b596372f67ac9b077190f459aba390faf5550

RUN set -eux; \
    wget -O python.tar.xz "https://www.python.org/ftp/python/${PYTHON_VERSION%%[a-z]*}/Python-$PYTHON_VERSION.tar.xz"; \
    echo "$PYTHON_SHA256 *python.tar.xz" | sha256sum -c -; \
    mkdir -p /usr/src/python; \
    tar --extract --directory /usr/src/python --strip-components=1 --file python.tar.xz; \
    rm python.tar.xz; \
    cd /usr/src/python; \
    ./configure \
        --enable-optimizations \
        --with-ensurepip; \
    make -j "$(nproc)"; \
    make install; \
    cd /; \
    rm -rf /usr/src/python

# Обновляем pip и устанавливаем Poetry
RUN python3.12 -m pip install --upgrade pip
RUN curl -sSL https://install.python-poetry.org | python3.12 -

# Настраиваем переменную окружения для Poetry
ENV PATH="/root/.local/bin:$PATH"

# Устанавливаем рабочую директорию
WORKDIR /app

# Копируем файлы проекта
COPY pyproject.toml poetry.lock /app/
COPY telegram_bot /app/telegram_bot

# Устанавливаем зависимости через Poetry
RUN poetry install --no-root

# Определяем команду запуска
CMD ["poetry", "run", "python", "telegram_bot/main.py"]
