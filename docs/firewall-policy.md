# Политика firewall

| Откуда | Куда | Результат |
| --- | --- | --- |
| Office | Internet | разрешено |
| Office | Servers | разрешено |
| Office | Management | запрещено |
| Servers | Management | разрешено |
| Servers | Office | запрещено |
| Guest | Internet | разрешено |
| Guest | Servers | запрещено |
| Guest | Office | запрещено |
| Guest | Management | запрещено |
| Management | Servers | разрешено |

Во всех правилах VyOS сначала разрешается ответный трафик `ESTABLISHED,RELATED`. Затем разрешаются только нужные направления. Всё остальное между VLAN блокируется.

Проверять лучше с `ping` и `curl`. Успешный тест должен вернуть ответ, а запрещённый — не должен.
