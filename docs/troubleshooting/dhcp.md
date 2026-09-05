# DHCP не выдаёт адрес

## Проверка

На VyOS:

```text
show dhcp server leases
show configuration commands | match dhcp
```

На клиенте:

```bash
ip addr
sudo dhclient -v
```

## Частые причины

- клиент подключён не к тому access-порту;
- у VLAN нет DHCP-пула;
- неверный gateway или DNS в DHCP;
- trunk не пропускает нужный VLAN.
