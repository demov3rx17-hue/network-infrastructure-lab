# Неправильный IP-адрес

## Симптом

Компьютер не получает адрес из своей подсети или не видит шлюз.

## Проверка

```bash
ip addr
ip route
```

Проверь, что адрес и gateway совпадают с [IP plan](../ip-plan.md).

## Исправление

Для DHCP-клиента обнови адрес:

```bash
sudo dhclient -r
sudo dhclient
```

Для `server01` исправь статический адрес в netplan и выполни `sudo netplan apply`.
