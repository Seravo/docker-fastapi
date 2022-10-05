FROM ghcr.io/seravo/ubuntu:jammy

ARG APT_PROXY

ENV APPDIR /app
ENV VEDIR /ve

RUN sed -i 's/main$/main universe/g' /etc/apt/sources.list && \
    export DEBIAN_FRONTEND="noninteractive" && \
    /usr/sbin/apt-setup && \
    apt-get --assume-yes upgrade && \
    apt-get --assume-yes --no-install-recommends install \
        curl \
        procps \
        python3 \
        python3-dev \
        python3-pip \
        python3-setuptools \
        python3-venv \
        python3-wheel && \
    /usr/sbin/apt-cleanup

RUN mkdir -p "${APPDIR}" "${VEDIR}"

RUN adduser --disabled-password --gecos "user,,," user && \
    chown user "${VEDIR}"


WORKDIR "${APPDIR}"
USER user

RUN python3 -m venv "${VEDIR}" && \
    echo 'export PATH="${VEDIR}:${PATH}"' >> /home/user/.profile

ENV PATH="/home/user/.local/bin:${PATH}"

COPY requirements.txt .
RUN pip3 install -r requirements.txt

COPY app /app
COPY reload.sh /usr/local/sbin/reload-gunicorn

ENTRYPOINT [ \
    "gunicorn", \
    "--bind", "0.0.0.0", \
    "--workers", "4", \
    "--worker-class", "uvicorn.workers.UvicornWorker" \
]
CMD ["hello:app"]

HEALTHCHECK --interval=10s --timeout=5s --start-period=5s --retries=3 CMD curl -f http://localhost:8000/ || exit 1
EXPOSE 8000/tcp
