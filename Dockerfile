ARG ALPINE_VERSION=3.24.4

# Upstream version to compile
ARG OPENVPN_VERSION=2.7.9

# The key that signs OpenVPN releases
ARG OPENVPN_SIGNING_FINGERPRINT=F554A3687412CFFEBDEFE0A312F5F7B42F2B01E7

# Stage 1: Build
FROM alpine:${ALPINE_VERSION} AS openvpn-build

ARG OPENVPN_VERSION
ARG OPENVPN_SIGNING_FINGERPRINT

WORKDIR /tmp/openvpn-build

RUN set -eux; \
    apk add --no-cache build-base curl gnupg libnl3-dev libcap-ng lz4-dev lzo-dev linux-headers openssl-dev tar; \
    printf '%s\n' "${OPENVPN_VERSION}" | grep -Eq '^[0-9]+\.[0-9]+\.[0-9]+$' || { \
      echo "OPENVPN_VERSION must be x.y.z, got: ${OPENVPN_VERSION}" >&2; exit 1; }; \
    curl --fail --silent --show-error --retry 3 \
      "https://swupdate.openvpn.net/community/releases/openvpn-${OPENVPN_VERSION}.tar.gz" \
      --output "openvpn-${OPENVPN_VERSION}.tar.gz"; \
    curl --fail --silent --show-error --retry 3 \
      "https://swupdate.openvpn.net/community/releases/openvpn-${OPENVPN_VERSION}.tar.gz.asc" \
      --output "openvpn-${OPENVPN_VERSION}.tar.gz.asc"; \
    curl --fail --silent --show-error --retry 3 \
      "https://keys.openpgp.org/vks/v1/by-fingerprint/${OPENVPN_SIGNING_FINGERPRINT}" \
      --output openvpn-signing-key.asc; \
    mkdir -m 0700 /tmp/gnupg; \
    export GNUPGHOME=/tmp/gnupg; \
    gpg --batch --import openvpn-signing-key.asc; \
    ACTUAL_FINGERPRINT="$(gpg --batch --with-colons --fingerprint \
      | awk -F: '$1 == "fpr" { print $10; exit }')"; \
    test "${ACTUAL_FINGERPRINT}" = "${OPENVPN_SIGNING_FINGERPRINT}" || { \
      echo "FATAL: fetched key is ${ACTUAL_FINGERPRINT}, expected ${OPENVPN_SIGNING_FINGERPRINT}" >&2; exit 1; }; \
    gpg --batch --verify "openvpn-${OPENVPN_VERSION}.tar.gz.asc" "openvpn-${OPENVPN_VERSION}.tar.gz"; \
    tar -tzf "openvpn-${OPENVPN_VERSION}.tar.gz" >/dev/null || { \
      echo "FATAL: archive is not a valid gzip tar" >&2; exit 1; }; \
    tar -xzf "openvpn-${OPENVPN_VERSION}.tar.gz"; \
    cd "openvpn-${OPENVPN_VERSION}"; \
    ./configure \
      --prefix=/usr \
      --sysconfdir=/etc \
      --disable-plugin-auth-pam; \
    make -j2; \
    make DESTDIR=/stage install; \
    /stage/usr/sbin/openvpn --version | head -n 1 | grep -F "OpenVPN ${OPENVPN_VERSION} "; \
    rm -rf /tmp/gnupg

# Stage 2: Runtime
FROM alpine:${ALPINE_VERSION}

ARG OPENVPN_VERSION

COPY --from=openvpn-build /stage/usr/sbin/openvpn /usr/sbin/openvpn

RUN set -eux; \
    apk add --no-cache bash easy-rsa iptables lz4-libs lzo openssl; \
    ln -s /usr/share/easy-rsa/easyrsa /usr/local/bin; \
    rm -rf /tmp/* /var/tmp/*; \
    if ldd /usr/sbin/openvpn 2>&1 | grep -q 'not found'; then \
      echo 'ERROR: OpenVPN has unresolved shared-library dependencies' >&2; exit 1; \
    fi; \
    openvpn --version | head -n 1 | grep -F "OpenVPN ${OPENVPN_VERSION} "

ENV OPENVPN=/etc/openvpn
ENV EASYRSA=/usr/share/easy-rsa \
    EASYRSA_ALGO=ec \
    EASYRSA_CURVE=secp384r1 \
    EASYRSA_CRL_DAYS=3650 \
    EASYRSA_PKI=$OPENVPN/pki

COPY ./bin /usr/local/bin/
RUN set -eux; \
    for f in /usr/local/bin/ovpn_*; do \
      [ -f "$f" ] || { echo "FATAL: $f missing from ./bin" >&2; exit 1; }; \
      chmod a+x "$f"; \
    done; \
    command -v ovpn_run >/dev/null; \
    for f in /usr/local/bin/ovpn_*; do bash -n "$f"; done

EXPOSE 1194/udp

CMD ["ovpn_run"]
