FROM alpine:latest

RUN apk add --no-cache openvpn iptables bash easy-rsa && \
    ln -s /usr/share/easy-rsa/easyrsa /usr/local/bin/easyrsa

ENV OPENVPN=/etc/openvpn
ENV EASYRSA=/usr/share/easy-rsa \
    EASYRSA_ALGO=ec \
    EASYRSA_CURVE=secp384r1 \
    EASYRSA_CRL_DAYS=3650 \
    EASYRSA_PKI=$OPENVPN/pki

VOLUME ["/etc/openvpn"]

EXPOSE 1194/udp

COPY ./bin /usr/local/bin

RUN chmod a+x /usr/local/bin/*

CMD ["ovpn_run"]
