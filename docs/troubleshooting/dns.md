# DNS не работает, но IP-подключение есть

## Проверка

```bash
ping -c 3 8.8.8.8
dig deb.debian.org
cat /etc/resolv.conf
```

Если ping по IP работает, а `dig` нет, проблема обычно в DNS.

На VyOS проверь DNS forwarding и адрес DNS-сервера, который выдаёт DHCP.
