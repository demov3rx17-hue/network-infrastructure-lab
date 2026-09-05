# План VLAN

Для понятной схемы Open vSwitch получает пять сетевых адаптеров:

| Адаптер switch01 | Режим | VLAN / куда подключён |
| --- | --- | --- |
| `ens33` | trunk | VMnet10, VyOS и все VLAN 10/20/30/40 |
| `ens34` | access | VLAN 10, отдельный VMnet для `office01` |
| `ens35` | access | VLAN 20, отдельный VMnet для `server01` |
| `ens36` | access | VLAN 30, отдельный VMnet для `guest01` |
| `ens37` | access | VLAN 40, отдельный VMnet для `admin01` |

Для access-портов удобно создать в VMware ещё четыре private/host-only сети, например VMnet11 - VMnet14. В этих сетях отключить VMware DHCP и host adapter.

Это важно: одна VM с Open vSwitch не может быть удобным access-коммутатором для других VM без отдельных виртуальных сетевых адаптеров.
