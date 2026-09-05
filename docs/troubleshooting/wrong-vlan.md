# Неправильный VLAN

## Симптом

У VM есть адрес, но она не видит свой шлюз, либо попадает в другую сеть.

## Проверка

На `switch01`:

```bash
sudo ovs-vsctl show
sudo ovs-vsctl list port ens34
```

Проверь, что access-порт имеет правильный `tag`: 10, 20, 30 или 40.

## Исправление

Пример для Office:

```bash
sudo ovs-vsctl set port ens34 tag=10
```
