# ═══════════════════════════════════════════════════════════════════════════════
# 🏛️ ODOO 19 - Dockerfile para Dokploy (Multi-arch: AMD64 + ARM64)
# Proyecto: MayordomIA / AlianeD
# ═══════════════════════════════════════════════════════════════════════════════

FROM python:3.12-slim-bookworm

SHELL ["/bin/bash", "-xo", "pipefail", "-c"]

# Instalar dependencias del sistema
RUN apt-get update && \
    apt-get install -y --no-install-recommends \
        ca-certificates \
        curl \
        dirmngr \
        fonts-noto-cjk \
        gnupg \
        libssl-dev \
        node-less \
        npm \
        python3-magic \
        python3-num2words \
        python3-odf \
        python3-pdfminer \
        python3-pip \
        python3-phonenumbers \
        python3-pyldap \
        python3-qrcode \
        python3-renderpm \
        python3-setuptools \
        python3-slugify \
        python3-vobject \
        python3-watchdog \
        python3-xlrd \
        python3-xlwt \
        xz-utils \
        libpq-dev \
        gcc \
        g++ \
        libxml2-dev \
        libxslt1-dev \
        libsasl2-dev \
        libldap2-dev \
        libjpeg-dev \
        zlib1g-dev \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

# Instalar wkhtmltopdf (para reportes PDF)
RUN curl -o wkhtmltox.deb -sSL https://github.com/wkhtmltopdf/packaging/releases/download/0.12.6.1-3/wkhtmltox_0.12.6.1-3.bookworm_$(dpkg --print-architecture).deb \
    && apt-get update \
    && apt-get install -y --no-install-recommends ./wkhtmltox.deb \
    && rm -rf /var/lib/apt/lists/* wkhtmltox.deb

# Instalar rtlcss para soporte RTL
RUN npm install -g rtlcss

# Crear usuario odoo
RUN useradd -m -d /opt/odoo -U -r -s /bin/bash odoo

# Copiar el source code de Odoo
COPY . /opt/odoo/

# Instalar dependencias Python de Odoo
RUN pip3 install --break-system-packages --no-cache-dir -r /opt/odoo/requirements.txt

# Crear directorios necesarios
RUN mkdir -p /var/lib/odoo /mnt/extra-addons /var/log/odoo \
    && chown -R odoo:odoo /var/lib/odoo /mnt/extra-addons /var/log/odoo /opt/odoo

# Copiar el entrypoint
COPY ./entrypoint.sh /
RUN chmod +x /entrypoint.sh

# Copiar configuración por defecto
COPY ./odoo.conf /etc/odoo/odoo.conf
RUN chown odoo:odoo /etc/odoo/odoo.conf

# Volúmenes
VOLUME ["/var/lib/odoo", "/mnt/extra-addons"]

# Puerto
EXPOSE 8069

# Configuración por defecto
ENV ODOO_RC=/etc/odoo/odoo.conf

USER odoo

ENTRYPOINT ["/entrypoint.sh"]
CMD ["odoo"]
