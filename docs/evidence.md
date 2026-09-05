# Уже проверено

Дата проверки: 2026-09-01.

## VyOS: VLAN-интерфейсы

```text
eth0     192.168.239.130/24  WAN-VMnet8
eth1     192.168.100.1/24   LAN-VMnet10 (временная сеть настройки)
eth1.10  192.168.10.1/24    Office
eth1.20  192.168.20.1/24    Servers
eth1.30  192.168.30.1/24    Guest
eth1.40  192.168.40.1/24    Management
```

Команда: `show interfaces`.

## Open vSwitch

Команда `sudo ovs-vsctl show` на `switch01` показала:

```text
Bridge br0
  ens33 trunks: [10, 20, 30, 40]
  ens34 tag: 10
  ens35 tag: 20
  ens36 tag: 30
  ens37 tag: 40
  mgmt0 tag: 40 (internal)
```

Адрес самого коммутатора: `192.168.40.2/24` на `mgmt0`.

## Интернет и DNS с management VLAN

На `switch01` успешно выполнены:

```text
ping -c 2 192.168.40.1  -> 2 received, 0% packet loss
ping -c 2 8.8.8.8       -> 2 received, 0% packet loss
dig +short deb.debian.org @192.168.40.1 -> получен ответ
```

## Firewall

В VyOS создан `firewall ipv4 forward filter` с политикой по умолчанию `drop`.
Разрешены только направления из [firewall-policy.md](firewall-policy.md):
Office → Servers/Internet, Servers → Management/Internet, Guest → Internet,
Management → Servers/Internet.

## Office VM: DHCP, DNS, NAT и изоляция

`office01` подключена к VMnet11 и получила по DHCP адрес `192.168.10.102/24`.

```text
default via 192.168.10.1 dev ens33 proto dhcp
Current DNS Server: 192.168.10.1
ping 192.168.10.1 -> 2 received, 0% packet loss
ping 8.8.8.8      -> 2 received, 0% packet loss
getent hosts deb.debian.org -> получен ответ
ping 192.168.40.2 -> 100% packet loss
```

Последняя строка — ожидаемый результат: Office не должен обращаться в VLAN 40
(Management). После этой проверки счётчик firewall-правила `Office → Internet`
увеличился, а запрет трафика проверен реальной попыткой связи.

## Server VM и связь с Office

`server01` использует статический адрес `192.168.20.10/24`, шлюз и DNS
`192.168.20.1`. Проверки сервера прошли успешно: пинг шлюза и `8.8.8.8` без
потерь, DNS-запрос возвращает ответ.

```text
office01 -> 192.168.20.10: ping 2/2, TCP port 22 open
server01 -> 192.168.10.102: ping 0/2, 100% packet loss
server01 -> 192.168.40.100: ping 2/2, TCP port 22 open
```

Это соответствует политике: Office разрешён к Servers, Servers разрешён к
Management, а новое подключение Servers → Office запрещено. Команда `show
firewall ipv4 forward filter` показала ненулевые счётчики правил 10, 20, 30 и
40, а также default drop.

## Guest VM: интернет без доступа к внутренним VLAN

`guest01` получила `192.168.30.100/24` по DHCP. Шлюз и DNS — `192.168.30.1`.
Пинг `8.8.8.8` и DNS-запрос прошли успешно.

```text
guest01 -> office01 (192.168.10.102): 100% packet loss
guest01 -> server01 (192.168.20.10): 100% packet loss
guest01 -> admin01  (192.168.40.100): 100% packet loss
```

Это подтверждает изоляцию Guest от остальных внутренних сетей. У правила
`Guest → Internet` в VyOS появился ненулевой счётчик.

## Management VM: доступ к серверному VLAN

`admin01` получила `192.168.40.100/24` по DHCP. Шлюз и DNS — `192.168.40.1`.
Интернет и DNS работают.

```text
admin01 -> server01 (192.168.20.10): ping 2/2, TCP port 22 open
admin01 -> office01 (192.168.10.102): 100% packet loss
```

Правило `Management → Servers` имеет ненулевой счётчик. Так проверено и
разрешённое, и запрещённое направление для management VLAN.

## Что ещё проверить

После создания `server01`, `guest01` и `admin01` нужно сохранить команды и
скриншоты из README: выдачу DHCP, DNS, доступ в интернет и остальные
разрешённые/запрещённые связи между VLAN.
