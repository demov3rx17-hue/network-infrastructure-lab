# Ошибка firewall

## Симптом

Разрешённый трафик не проходит или запрещённый трафик проходит.

## Проверка

На VyOS:

```text
show firewall
show configuration commands | match firewall
```

Проверь направление правила: например, фильтр VLAN 30 должен запрещать доступ Guest к Office, Servers и Management, но не к интернету.
