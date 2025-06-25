FROM alpine:latest

ARG TUN2PROXY_VERSION=latest

RUN apk add --no-cache \
 jq \
 curl \
 nano \
 wget \
 unzip \
 iputils \
 dos2unix \
 iptables

WORKDIR /app

RUN set -eux; \
    echo "→ Fetching release metadata…"; \
    curl -sL https://api.github.com/repos/tun2proxy/tun2proxy/releases/latest -o release.json; \
    echo "→ Extracting download URL…"; \
    Z_URL="$(jq -r '.assets[].browser_download_url | select(test("tun2proxy-x86_64-unknown-linux-musl.zip"))' release.json)"; \
    test -n "$Z_URL"; \
    echo "→ Downloading $Z_URL"; \
    curl -sL "$Z_URL" -o tun2proxy.zip; \
    unzip -d /app tun2proxy.zip; \
    chmod +x /app/tun2proxy-bin; \
    rm tun2proxy.zip release.json

COPY entrypoint.sh /app/entrypoint.sh
RUN dos2unix /app/entrypoint.sh
RUN chmod +x /app/entrypoint.sh
ENTRYPOINT ["/app/entrypoint.sh"]

CMD ["/app/tun2proxy-bin", "--setup"]