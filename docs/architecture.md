# Как собрать сеть в VMware

## 1. Базовая сеть

Сначала используется VMnet10 с сетью `192.168.100.0/24`. Это временная сеть для проверки VyOS до VLAN.

На `router01`:

- `eth0` подключён к VMnet8 (NAT/WAN);
- `eth1` подключён к VMnet10.

Проверь в VyOS:

```text
show interfaces
show ip route
ping 8.8.8.8
```

## 2. Open vSwitch

После базовой проверки создай `switch01` на Ubuntu Server и добавь ему пять сетевых адаптеров из [vlan-plan.md](vlan-plan.md).

Установи Open vSwitch:

```bash
sudo apt update
sudo apt install -y openvswitch-switch
```

Сначала посмотри имена интерфейсов:

```bash
ip link
```

Если они отличаются от `ens33` - `ens37`, поменяй их в `openvswitch/setup.sh`. Затем выполни:

```bash
sudo install -m 0755 openvswitch/setup.sh /usr/local/sbin/setup-ovs-lab.sh
sudo install -m 0644 openvswitch/ovs-lab-network.service /etc/systemd/system/
sudo systemctl daemon-reload
sudo systemctl enable --now ovs-lab-network.service
sudo ovs-vsctl show
```

После команды у `switch01` меняется адрес: временный `192.168.100.2` больше
не используется, а постоянный адрес управления — `192.168.40.2/24` на
внутреннем OVS-порту `mgmt0`. Короткий разрыв SSH во время переключения
нормален.

## 3. VLAN на VyOS

Когда trunk до OVS готов, на `eth1` создаются виртуальные интерфейсы `eth1.10`, `eth1.20`, `eth1.30`, `eth1.40`.

В `vyos/config.boot` лежит сокращённый вариант итоговой конфигурации, а в
`vyos/config.commands` — команды, которые применялись в rolling-версии VyOS.
Не копируй их вслепую: сначала проверь имена интерфейсов командой `show interfaces`.

## 4. Ubuntu VM

Подключи VM к своим access-сетям:

| VM | Сеть VMware | Настройка IP |
| --- | --- | --- |
| `office01` | access VLAN 10 | DHCP |
| `server01` | access VLAN 20 | `192.168.20.10/24` |
| `guest01` | access VLAN 30 | DHCP |
| `admin01` | access VLAN 40 | DHCP |

После этого на каждом клиенте проверь адрес, маршрут и DNS:

```bash
ip addr
ip route
ping -c 3 192.168.X.1
dig deb.debian.org
```
