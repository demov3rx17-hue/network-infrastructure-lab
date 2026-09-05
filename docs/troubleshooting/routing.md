# Ошибка маршрутизации

## Проверка

На Linux:

```bash
ip route
tracepath 8.8.8.8
```

На VyOS:

```text
show ip route
traceroute 8.8.8.8
```

У клиента должен быть default gateway своего VLAN, например `192.168.10.1` для Office.
