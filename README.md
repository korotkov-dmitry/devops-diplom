# Дипломный практикум в YandexCloud
  * [Цели:](#цели)
  * [Этапы выполнения:](#этапы-выполнения)
      * [Регистрация доменного имени](#регистрация-доменного-имени)
      * [Создание инфраструктуры](#создание-инфраструктуры)
          * [Установка Nginx и LetsEncrypt](#установка-nginx)
          * [Установка кластера MySQL](#установка-mysql)
          * [Установка WordPress](#установка-wordpress)
          * [Установка Gitlab CE, Gitlab Runner и настройка CI/CD](#установка-gitlab)
          * [Установка Prometheus, Alert Manager, Node Exporter и Grafana](#установка-prometheus)
  * [Что необходимо для сдачи задания?](#что-необходимо-для-сдачи-задания)
  * [Как правильно задавать вопросы дипломному руководителю?](#как-правильно-задавать-вопросы-дипломному-руководителю)

---
## Цели:

1. Зарегистрировать доменное имя (любое на ваш выбор в любой доменной зоне).
2. Подготовить инфраструктуру с помощью Terraform на базе облачного провайдера YandexCloud.
3. Настроить внешний Reverse Proxy на основе Nginx и LetsEncrypt.
4. Настроить кластер MySQL.
5. Установить WordPress.
6. Развернуть Gitlab CE и Gitlab Runner.
7. Настроить CI/CD для автоматического развёртывания приложения.
8. Настроить мониторинг инфраструктуры с помощью стека: Prometheus, Alert Manager и Grafana.

---
## Этапы выполнения:

### Регистрация доменного имени

Подойдет любое доменное имя на ваш выбор в любой доменной зоне.

ПРИМЕЧАНИЕ: Далее в качестве примера используется домен `you.domain` замените его вашим доменом.

Рекомендуемые регистраторы:
  - [nic.ru](https://nic.ru)
  - [reg.ru](https://reg.ru)

Цель:

1. Получить возможность выписывать [TLS сертификаты](https://letsencrypt.org) для веб-сервера.

Ожидаемые результаты:

1. У вас есть доступ к личному кабинету на сайте регистратора.
2. Вы зарезистрировали домен и можете им управлять (редактировать dns записи в рамках этого домена).

### Создание инфраструктуры

Для начала необходимо подготовить инфраструктуру в YC при помощи [Terraform](https://www.terraform.io/).

Особенности выполнения:

- Бюджет купона ограничен, что следует иметь в виду при проектировании инфраструктуры и использовании ресурсов;
- Следует использовать последнюю стабильную версию [Terraform](https://www.terraform.io/).

Предварительная подготовка:

1. Создайте сервисный аккаунт, который будет в дальнейшем использоваться Terraform для работы с инфраструктурой с необходимыми и достаточными правами. Не стоит использовать права суперпользователя
2. Подготовьте [backend](https://www.terraform.io/docs/language/settings/backends/index.html) для Terraform:
   а. Рекомендуемый вариант: [Terraform Cloud](https://app.terraform.io/)  
   б. Альтернативный вариант: S3 bucket в созданном YC аккаунте.
3. Настройте [workspaces](https://www.terraform.io/docs/language/state/workspaces.html)
   а. Рекомендуемый вариант: создайте два workspace: *stage* и *prod*. В случае выбора этого варианта все последующие шаги должны учитывать факт существования нескольких workspace.  
   б. Альтернативный вариант: используйте один workspace, назвав его *stage*. Пожалуйста, не используйте workspace, создаваемый Terraform-ом по-умолчанию (*default*).
4. Создайте VPC с подсетями в разных зонах доступности.
5. Убедитесь, что теперь вы можете выполнить команды `terraform destroy` и `terraform apply` без дополнительных ручных действий.
6. В случае использования [Terraform Cloud](https://app.terraform.io/) в качестве [backend](https://www.terraform.io/docs/language/settings/backends/index.html) убедитесь, что применение изменений успешно проходит, используя web-интерфейс Terraform cloud.

Цель:

1. Повсеместно применять IaaC подход при организации (эксплуатации) инфраструктуры.
2. Иметь возможность быстро создавать (а также удалять) виртуальные машины и сети. С целью экономии денег на вашем аккаунте в YandexCloud.

Ожидаемые результаты:

1. Terraform сконфигурирован и создание инфраструктуры посредством Terraform возможно без дополнительных ручных действий.
2. Полученная конфигурация инфраструктуры является предварительной, поэтому в ходе дальнейшего выполнения задания возможны изменения.

---
### Установка Nginx и LetsEncrypt

Необходимо разработать Ansible роль для установки Nginx и LetsEncrypt.

**Для получения LetsEncrypt сертификатов во время тестов своего кода пользуйтесь [тестовыми сертификатами](https://letsencrypt.org/docs/staging-environment/), так как количество запросов к боевым серверам LetsEncrypt [лимитировано](https://letsencrypt.org/docs/rate-limits/).**

Рекомендации:
  - Имя сервера: `you.domain`
  - Характеристики: 2vCPU, 2 RAM, External address (Public) и Internal address.

Цель:

1. Создать reverse proxy с поддержкой TLS для обеспечения безопасного доступа к веб-сервисам по HTTPS.

Ожидаемые результаты:

1. В вашей доменной зоне настроены все A-записи на внешний адрес этого сервера:
    - `https://www.you.domain` (WordPress)
    - `https://gitlab.you.domain` (Gitlab)
    - `https://grafana.you.domain` (Grafana)
    - `https://prometheus.you.domain` (Prometheus)
    - `https://alertmanager.you.domain` (Alert Manager)
2. Настроены все upstream для выше указанных URL, куда они сейчас ведут на этом шаге не важно, позже вы их отредактируете и укажите верные значения.
2. В браузере можно открыть любой из этих URL и увидеть ответ сервера (502 Bad Gateway). На текущем этапе выполнение задания это нормально!

___
### Установка кластера MySQL

Необходимо разработать Ansible роль для установки кластера MySQL.

Рекомендации:
  - Имена серверов: `db01.you.domain` и `db02.you.domain`
  - Характеристики: 4vCPU, 4 RAM, Internal address.

Цель:

1. Получить отказоустойчивый кластер баз данных MySQL.

Ожидаемые результаты:

1. MySQL работает в режиме репликации Master/Slave.
2. В кластере автоматически создаётся база данных c именем `wordpress`.
3. В кластере автоматически создаётся пользователь `wordpress` с полными правами на базу `wordpress` и паролем `wordpress`.

**Вы должны понимать, что в рамках обучения это допустимые значения, но в боевой среде использование подобных значений не приемлимо! Считается хорошей практикой использовать логины и пароли повышенного уровня сложности. В которых будут содержаться буквы верхнего и нижнего регистров, цифры, а также специальные символы!**

___
### Установка WordPress

Необходимо разработать Ansible роль для установки WordPress.

Рекомендации:
  - Имя сервера: `app.you.domain`
  - Характеристики: 4vCPU, 4 RAM, Internal address.

Цель:

1. Установить [WordPress](https://wordpress.org/download/). Это система управления содержимым сайта ([CMS](https://ru.wikipedia.org/wiki/Система_управления_содержимым)) с открытым исходным кодом.


По данным W3techs, WordPress используют 64,7% всех веб-сайтов, которые сделаны на CMS. Это 41,1% всех существующих в мире сайтов. Эту платформу для своих блогов используют The New York Times и Forbes. Такую популярность WordPress получил за удобство интерфейса и большие возможности.

Ожидаемые результаты:

1. Виртуальная машина на которой установлен WordPress и Nginx/Apache (на ваше усмотрение).
2. В вашей доменной зоне настроена A-запись на внешний адрес reverse proxy:
    - `https://www.you.domain` (WordPress)
3. На сервере `you.domain` отредактирован upstream для выше указанного URL и он смотрит на виртуальную машину на которой установлен WordPress.
4. В браузере можно открыть URL `https://www.you.domain` и увидеть главную страницу WordPress.
---
### Установка Gitlab CE и Gitlab Runner

Необходимо настроить CI/CD систему для автоматического развертывания приложения при изменении кода.

Рекомендации:
  - Имена серверов: `gitlab.you.domain` и `runner.you.domain`
  - Характеристики: 4vCPU, 4 RAM, Internal address.

Цель:
1. Построить pipeline доставки кода в среду эксплуатации, то есть настроить автоматический деплой на сервер `app.you.domain` при коммите в репозиторий с WordPress.

Подробнее об [Gitlab CI](https://about.gitlab.com/stages-devops-lifecycle/continuous-integration/)

Ожидаемый результат:

1. Интерфейс Gitlab доступен по https.
2. В вашей доменной зоне настроена A-запись на внешний адрес reverse proxy:
    - `https://gitlab.you.domain` (Gitlab)
3. На сервере `you.domain` отредактирован upstream для выше указанного URL и он смотрит на виртуальную машину на которой установлен Gitlab.
3. При любом коммите в репозиторий с WordPress и создании тега (например, v1.0.0) происходит деплой на виртуальную машину.

___
### Установка Prometheus, Alert Manager, Node Exporter и Grafana

Необходимо разработать Ansible роль для установки Prometheus, Alert Manager и Grafana.

Рекомендации:
  - Имя сервера: `monitoring.you.domain`
  - Характеристики: 4vCPU, 4 RAM, Internal address.

Цель:

1. Получение метрик со всей инфраструктуры.

Ожидаемые результаты:

1. Интерфейсы Prometheus, Alert Manager и Grafana доступены по https.
2. В вашей доменной зоне настроены A-записи на внешний адрес reverse proxy:
  - `https://grafana.you.domain` (Grafana)
  - `https://prometheus.you.domain` (Prometheus)
  - `https://alertmanager.you.domain` (Alert Manager)
3. На сервере `you.domain` отредактированы upstreams для выше указанных URL и они смотрят на виртуальную машину на которой установлены Prometheus, Alert Manager и Grafana.
4. На всех серверах установлен Node Exporter и его метрики доступны Prometheus.
5. У Alert Manager есть необходимый [набор правил](https://awesome-prometheus-alerts.grep.to/rules.html) для создания алертов.
2. В Grafana есть дашборд отображающий метрики из Node Exporter по всем серверам.
3. В Grafana есть дашборд отображающий метрики из MySQL (*).
4. В Grafana есть дашборд отображающий метрики из WordPress (*).

*Примечание: дашборды со звёздочкой являются опциональными заданиями повышенной сложности их выполнение желательно, но не обязательно.*

---
## Что необходимо для сдачи задания?

1. Репозиторий со всеми Terraform манифестами и готовность продемонстрировать создание всех ресурсов с нуля.
2. Репозиторий со всеми Ansible ролями и готовность продемонстрировать установку всех сервисов с нуля.
3. Скриншоты веб-интерфейсов всех сервисов работающих по HTTPS на вашем доменном имени.
  - `https://www.you.domain` (WordPress)
  - `https://gitlab.you.domain` (Gitlab)
  - `https://grafana.you.domain` (Grafana)
  - `https://prometheus.you.domain` (Prometheus)
  - `https://alertmanager.you.domain` (Alert Manager)
4. Все репозитории рекомендуется хранить на одном из ресурсов ([github.com](https://github.com) или [gitlab.com](https://gitlab.com)).

---
## Как правильно задавать вопросы дипломному руководителю?

**Что поможет решить большинство частых проблем:**

1. Попробовать найти ответ сначала самостоятельно в интернете или в
  материалах курса и ДЗ и только после этого спрашивать у дипломного
  руководителя. Навык поиска ответов пригодится вам в профессиональной
  деятельности.
2. Если вопросов больше одного, то присылайте их в виде нумерованного
  списка. Так дипломному руководителю будет проще отвечать на каждый из
  них.
3. При необходимости прикрепите к вопросу скриншоты и стрелочкой
  покажите, где не получается.

**Что может стать источником проблем:**

1. Вопросы вида «Ничего не работает. Не запускается. Всё сломалось». Дипломный руководитель не сможет ответить на такой вопрос без дополнительных уточнений. Цените своё время и время других.
2. Откладывание выполнения курсового проекта на последний момент.
3. Ожидание моментального ответа на свой вопрос. Дипломные руководители работающие разработчики, которые занимаются, кроме преподавания, своими проектами. Их время ограничено, поэтому постарайтесь задавать правильные вопросы, чтобы получать быстрые ответы :)

### Решение

<details><summary>Полный вывод</summary>
```
vagrant@vagrant:/vagrant/terraform$ terraform apply -auto-approve
data.yandex_compute_image.image: Reading...
data.yandex_compute_image.image: Read complete after 1s [id=fd8s2gbn4d5k2rcf12d9]

Terraform used the selected providers to generate the following execution plan. Resource actions are indicated with the following symbols:
  + create

Terraform will perform the following actions:

  # null_resource.playbook will be created
  + resource "null_resource" "playbook" {
      + id = (known after apply)
    }

  # null_resource.wait-clear-ssh will be created
  + resource "null_resource" "wait-clear-ssh" {
      + id = (known after apply)
    }

  # yandex_compute_instance.app will be created
  + resource "yandex_compute_instance" "app" {
      + created_at                = (known after apply)
      + folder_id                 = (known after apply)
      + fqdn                      = (known after apply)
      + hostname                  = "app.korotkovdmitry.ru"
      + id                        = (known after apply)
      + metadata                  = {
          + "ssh-keys" = <<-EOT
                ubuntu:ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABgQDPa+gMP2AjP8ZidhknRHJBBuDDo3N+PuVxXauRwejE4b1Beqig3UsHi6mfq84bKLCSSFclAxl27tphR2aOAW1qCfvPPN5QPiGJs1J8Kts//KWoCCk5P/Ke0bo0S9UHbqNj9wwrG5MzyBIERHxKKxE24fNdjGhkda7HHtw8fuCkATh3pvsytmwXaCkzh8AA17j9RvpSOvilldfS40G3fl8MgZCpeantCEGUvTP+YjnCzTY1Q0LUynHLQptbrqTKstCCgxzo3wDNtHnTxiggsMOduxMfUFZmG3K1YOekxul/h+x4OsQ/WnhwoJrIP5rSVffk5ArxjI2LhpzlMR11SyXs4p7RevwwEKWerugC9JRM6sIFfWhUu0X/1vGkVwuHVcwa85oKKQLwF6fyIBGvhzx76yyX4n3p1gz8v1ibuiYxx28BT8tBlFkDAleciK8Ysn1Zpl2pUE8nIiK90pRkYeyh1+uBWY7IoYowmo5iNXBz+Cuzdl121iPZ0qoHIV1mkMs= vagrant@vagrant
            EOT
        }
      + name                      = "app"
      + network_acceleration_type = "standard"
      + platform_id               = "standard-v1"
      + service_account_id        = (known after apply)
      + status                    = (known after apply)
      + zone                      = (known after apply)

      + boot_disk {
          + auto_delete = true
          + device_name = (known after apply)
          + disk_id     = (known after apply)
          + mode        = (known after apply)

          + initialize_params {
              + block_size  = (known after apply)
              + description = (known after apply)
              + image_id    = "fd8s2gbn4d5k2rcf12d9"
              + name        = (known after apply)
              + size        = 6
              + snapshot_id = (known after apply)
              + type        = "network-hdd"
            }
        }

      + network_interface {
          + index              = (known after apply)
          + ip_address         = (known after apply)
          + ipv4               = true
          + ipv6               = (known after apply)
          + ipv6_address       = (known after apply)
          + mac_address        = (known after apply)
          + nat                = true
          + nat_ip_address     = (known after apply)
          + nat_ip_version     = (known after apply)
          + security_group_ids = (known after apply)
          + subnet_id          = (known after apply)
        }

      + placement_policy {
          + host_affinity_rules = (known after apply)
          + placement_group_id  = (known after apply)
        }

      + resources {
          + core_fraction = 100
          + cores         = 4
          + memory        = 4
        }

      + scheduling_policy {
          + preemptible = (known after apply)
        }
    }

  # yandex_compute_instance.db01 will be created
  + resource "yandex_compute_instance" "db01" {
      + created_at                = (known after apply)
      + folder_id                 = (known after apply)
      + fqdn                      = (known after apply)
      + hostname                  = "db01.korotkovdmitry.ru"
      + id                        = (known after apply)
      + metadata                  = {
          + "ssh-keys" = <<-EOT
                ubuntu:ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABgQDPa+gMP2AjP8ZidhknRHJBBuDDo3N+PuVxXauRwejE4b1Beqig3UsHi6mfq84bKLCSSFclAxl27tphR2aOAW1qCfvPPN5QPiGJs1J8Kts//KWoCCk5P/Ke0bo0S9UHbqNj9wwrG5MzyBIERHxKKxE24fNdjGhkda7HHtw8fuCkATh3pvsytmwXaCkzh8AA17j9RvpSOvilldfS40G3fl8MgZCpeantCEGUvTP+YjnCzTY1Q0LUynHLQptbrqTKstCCgxzo3wDNtHnTxiggsMOduxMfUFZmG3K1YOekxul/h+x4OsQ/WnhwoJrIP5rSVffk5ArxjI2LhpzlMR11SyXs4p7RevwwEKWerugC9JRM6sIFfWhUu0X/1vGkVwuHVcwa85oKKQLwF6fyIBGvhzx76yyX4n3p1gz8v1ibuiYxx28BT8tBlFkDAleciK8Ysn1Zpl2pUE8nIiK90pRkYeyh1+uBWY7IoYowmo5iNXBz+Cuzdl121iPZ0qoHIV1mkMs= vagrant@vagrant
            EOT
        }
      + name                      = "db01"
      + network_acceleration_type = "standard"
      + platform_id               = "standard-v1"
      + service_account_id        = (known after apply)
      + status                    = (known after apply)
      + zone                      = (known after apply)

      + boot_disk {
          + auto_delete = true
          + device_name = (known after apply)
          + disk_id     = (known after apply)
          + mode        = (known after apply)

          + initialize_params {
              + block_size  = (known after apply)
              + description = (known after apply)
              + image_id    = "fd8s2gbn4d5k2rcf12d9"
              + name        = (known after apply)
              + size        = 6
              + snapshot_id = (known after apply)
              + type        = "network-hdd"
            }
        }

      + network_interface {
          + index              = (known after apply)
          + ip_address         = (known after apply)
          + ipv4               = true
          + ipv6               = (known after apply)
          + ipv6_address       = (known after apply)
          + mac_address        = (known after apply)
          + nat                = true
          + nat_ip_address     = (known after apply)
          + nat_ip_version     = (known after apply)
          + security_group_ids = (known after apply)
          + subnet_id          = (known after apply)
        }

      + placement_policy {
          + host_affinity_rules = (known after apply)
          + placement_group_id  = (known after apply)
        }

      + resources {
          + core_fraction = 100
          + cores         = 4
          + memory        = 4
        }

      + scheduling_policy {
          + preemptible = (known after apply)
        }
    }

  # yandex_compute_instance.db02 will be created
  + resource "yandex_compute_instance" "db02" {
      + created_at                = (known after apply)
      + folder_id                 = (known after apply)
      + fqdn                      = (known after apply)
      + hostname                  = "db02.korotkovdmitry.ru"
      + id                        = (known after apply)
      + metadata                  = {
          + "ssh-keys" = <<-EOT
                ubuntu:ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABgQDPa+gMP2AjP8ZidhknRHJBBuDDo3N+PuVxXauRwejE4b1Beqig3UsHi6mfq84bKLCSSFclAxl27tphR2aOAW1qCfvPPN5QPiGJs1J8Kts//KWoCCk5P/Ke0bo0S9UHbqNj9wwrG5MzyBIERHxKKxE24fNdjGhkda7HHtw8fuCkATh3pvsytmwXaCkzh8AA17j9RvpSOvilldfS40G3fl8MgZCpeantCEGUvTP+YjnCzTY1Q0LUynHLQptbrqTKstCCgxzo3wDNtHnTxiggsMOduxMfUFZmG3K1YOekxul/h+x4OsQ/WnhwoJrIP5rSVffk5ArxjI2LhpzlMR11SyXs4p7RevwwEKWerugC9JRM6sIFfWhUu0X/1vGkVwuHVcwa85oKKQLwF6fyIBGvhzx76yyX4n3p1gz8v1ibuiYxx28BT8tBlFkDAleciK8Ysn1Zpl2pUE8nIiK90pRkYeyh1+uBWY7IoYowmo5iNXBz+Cuzdl121iPZ0qoHIV1mkMs= vagrant@vagrant
            EOT
        }
      + name                      = "db02"
      + network_acceleration_type = "standard"
      + platform_id               = "standard-v1"
      + service_account_id        = (known after apply)
      + status                    = (known after apply)
      + zone                      = (known after apply)

      + boot_disk {
          + auto_delete = true
          + device_name = (known after apply)
          + disk_id     = (known after apply)
          + mode        = (known after apply)

          + initialize_params {
              + block_size  = (known after apply)
              + description = (known after apply)
              + image_id    = "fd8s2gbn4d5k2rcf12d9"
              + name        = (known after apply)
              + size        = 6
              + snapshot_id = (known after apply)
              + type        = "network-hdd"
            }
        }

      + network_interface {
          + index              = (known after apply)
          + ip_address         = (known after apply)
          + ipv4               = true
          + ipv6               = (known after apply)
          + ipv6_address       = (known after apply)
          + mac_address        = (known after apply)
          + nat                = true
          + nat_ip_address     = (known after apply)
          + nat_ip_version     = (known after apply)
          + security_group_ids = (known after apply)
          + subnet_id          = (known after apply)
        }

      + placement_policy {
          + host_affinity_rules = (known after apply)
          + placement_group_id  = (known after apply)
        }

      + resources {
          + core_fraction = 100
          + cores         = 4
          + memory        = 4
        }

      + scheduling_policy {
          + preemptible = (known after apply)
        }
    }

  # yandex_compute_instance.gitlab will be created
  + resource "yandex_compute_instance" "gitlab" {
      + created_at                = (known after apply)
      + folder_id                 = (known after apply)
      + fqdn                      = (known after apply)
      + hostname                  = "gitlab.korotkovdmitry.ru"
      + id                        = (known after apply)
      + metadata                  = {
          + "ssh-keys" = <<-EOT
                ubuntu:ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABgQDPa+gMP2AjP8ZidhknRHJBBuDDo3N+PuVxXauRwejE4b1Beqig3UsHi6mfq84bKLCSSFclAxl27tphR2aOAW1qCfvPPN5QPiGJs1J8Kts//KWoCCk5P/Ke0bo0S9UHbqNj9wwrG5MzyBIERHxKKxE24fNdjGhkda7HHtw8fuCkATh3pvsytmwXaCkzh8AA17j9RvpSOvilldfS40G3fl8MgZCpeantCEGUvTP+YjnCzTY1Q0LUynHLQptbrqTKstCCgxzo3wDNtHnTxiggsMOduxMfUFZmG3K1YOekxul/h+x4OsQ/WnhwoJrIP5rSVffk5ArxjI2LhpzlMR11SyXs4p7RevwwEKWerugC9JRM6sIFfWhUu0X/1vGkVwuHVcwa85oKKQLwF6fyIBGvhzx76yyX4n3p1gz8v1ibuiYxx28BT8tBlFkDAleciK8Ysn1Zpl2pUE8nIiK90pRkYeyh1+uBWY7IoYowmo5iNXBz+Cuzdl121iPZ0qoHIV1mkMs= vagrant@vagrant
            EOT
        }
      + name                      = "gitlab"
      + network_acceleration_type = "standard"
      + platform_id               = "standard-v1"
      + service_account_id        = (known after apply)
      + status                    = (known after apply)
      + zone                      = (known after apply)

      + boot_disk {
          + auto_delete = true
          + device_name = (known after apply)
          + disk_id     = (known after apply)
          + mode        = (known after apply)

          + initialize_params {
              + block_size  = (known after apply)
              + description = (known after apply)
              + image_id    = "fd8s2gbn4d5k2rcf12d9"
              + name        = (known after apply)
              + size        = 12
              + snapshot_id = (known after apply)
              + type        = "network-hdd"
            }
        }

      + network_interface {
          + index              = (known after apply)
          + ip_address         = (known after apply)
          + ipv4               = true
          + ipv6               = (known after apply)
          + ipv6_address       = (known after apply)
          + mac_address        = (known after apply)
          + nat                = false
          + nat_ip_address     = (known after apply)
          + nat_ip_version     = (known after apply)
          + security_group_ids = (known after apply)
          + subnet_id          = (known after apply)
        }

      + placement_policy {
          + host_affinity_rules = (known after apply)
          + placement_group_id  = (known after apply)
        }

      + resources {
          + core_fraction = 100
          + cores         = 4
          + memory        = 4
        }

      + scheduling_policy {
          + preemptible = (known after apply)
        }
    }

  # yandex_compute_instance.monitoring will be created
  + resource "yandex_compute_instance" "monitoring" {
      + created_at                = (known after apply)
      + folder_id                 = (known after apply)
      + fqdn                      = (known after apply)
      + hostname                  = "monitoring.korotkovdmitry.ru"
      + id                        = (known after apply)
      + metadata                  = {
          + "ssh-keys" = <<-EOT
                ubuntu:ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABgQDPa+gMP2AjP8ZidhknRHJBBuDDo3N+PuVxXauRwejE4b1Beqig3UsHi6mfq84bKLCSSFclAxl27tphR2aOAW1qCfvPPN5QPiGJs1J8Kts//KWoCCk5P/Ke0bo0S9UHbqNj9wwrG5MzyBIERHxKKxE24fNdjGhkda7HHtw8fuCkATh3pvsytmwXaCkzh8AA17j9RvpSOvilldfS40G3fl8MgZCpeantCEGUvTP+YjnCzTY1Q0LUynHLQptbrqTKstCCgxzo3wDNtHnTxiggsMOduxMfUFZmG3K1YOekxul/h+x4OsQ/WnhwoJrIP5rSVffk5ArxjI2LhpzlMR11SyXs4p7RevwwEKWerugC9JRM6sIFfWhUu0X/1vGkVwuHVcwa85oKKQLwF6fyIBGvhzx76yyX4n3p1gz8v1ibuiYxx28BT8tBlFkDAleciK8Ysn1Zpl2pUE8nIiK90pRkYeyh1+uBWY7IoYowmo5iNXBz+Cuzdl121iPZ0qoHIV1mkMs= vagrant@vagrant
            EOT
        }
      + name                      = "monitoring"
      + network_acceleration_type = "standard"
      + platform_id               = "standard-v1"
      + service_account_id        = (known after apply)
      + status                    = (known after apply)
      + zone                      = (known after apply)

      + boot_disk {
          + auto_delete = true
          + device_name = (known after apply)
          + disk_id     = (known after apply)
          + mode        = (known after apply)

          + initialize_params {
              + block_size  = (known after apply)
              + description = (known after apply)
              + image_id    = "fd8s2gbn4d5k2rcf12d9"
              + name        = (known after apply)
              + size        = 6
              + snapshot_id = (known after apply)
              + type        = "network-hdd"
            }
        }

      + network_interface {
          + index              = (known after apply)
          + ip_address         = (known after apply)
          + ipv4               = true
          + ipv6               = (known after apply)
          + ipv6_address       = (known after apply)
          + mac_address        = (known after apply)
          + nat                = false
          + nat_ip_address     = (known after apply)
          + nat_ip_version     = (known after apply)
          + security_group_ids = (known after apply)
          + subnet_id          = (known after apply)
        }

      + placement_policy {
          + host_affinity_rules = (known after apply)
          + placement_group_id  = (known after apply)
        }

      + resources {
          + core_fraction = 100
          + cores         = 4
          + memory        = 4
        }

      + scheduling_policy {
          + preemptible = (known after apply)
        }
    }

  # yandex_compute_instance.nginx will be created
  + resource "yandex_compute_instance" "nginx" {
      + allow_stopping_for_update = true
      + created_at                = (known after apply)
      + folder_id                 = (known after apply)
      + fqdn                      = (known after apply)
      + hostname                  = "korotkovdmitry.ru"
      + id                        = (known after apply)
      + metadata                  = {
          + "ssh-keys" = <<-EOT
                ubuntu:ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABgQDPa+gMP2AjP8ZidhknRHJBBuDDo3N+PuVxXauRwejE4b1Beqig3UsHi6mfq84bKLCSSFclAxl27tphR2aOAW1qCfvPPN5QPiGJs1J8Kts//KWoCCk5P/Ke0bo0S9UHbqNj9wwrG5MzyBIERHxKKxE24fNdjGhkda7HHtw8fuCkATh3pvsytmwXaCkzh8AA17j9RvpSOvilldfS40G3fl8MgZCpeantCEGUvTP+YjnCzTY1Q0LUynHLQptbrqTKstCCgxzo3wDNtHnTxiggsMOduxMfUFZmG3K1YOekxul/h+x4OsQ/WnhwoJrIP5rSVffk5ArxjI2LhpzlMR11SyXs4p7RevwwEKWerugC9JRM6sIFfWhUu0X/1vGkVwuHVcwa85oKKQLwF6fyIBGvhzx76yyX4n3p1gz8v1ibuiYxx28BT8tBlFkDAleciK8Ysn1Zpl2pUE8nIiK90pRkYeyh1+uBWY7IoYowmo5iNXBz+Cuzdl121iPZ0qoHIV1mkMs= vagrant@vagrant
            EOT
        }
      + name                      = "nginx"
      + network_acceleration_type = "standard"
      + platform_id               = "standard-v1"
      + service_account_id        = (known after apply)
      + status                    = (known after apply)
      + zone                      = "ru-central1-a"

      + boot_disk {
          + auto_delete = true
          + device_name = (known after apply)
          + disk_id     = (known after apply)
          + mode        = (known after apply)

          + initialize_params {
              + block_size  = (known after apply)
              + description = (known after apply)
              + image_id    = "fd8s2gbn4d5k2rcf12d9"
              + name        = (known after apply)
              + size        = (known after apply)
              + snapshot_id = (known after apply)
              + type        = "network-hdd"
            }
        }

      + network_interface {
          + index              = (known after apply)
          + ip_address         = (known after apply)
          + ipv4               = true
          + ipv6               = (known after apply)
          + ipv6_address       = (known after apply)
          + mac_address        = (known after apply)
          + nat                = true
          + nat_ip_address     = "62.84.124.149"
          + nat_ip_version     = (known after apply)
          + security_group_ids = (known after apply)
          + subnet_id          = (known after apply)
        }

      + placement_policy {
          + host_affinity_rules = (known after apply)
          + placement_group_id  = (known after apply)
        }

      + resources {
          + core_fraction = 100
          + cores         = 2
          + memory        = 2
        }

      + scheduling_policy {
          + preemptible = (known after apply)
        }
    }

  # yandex_compute_instance.runner will be created
  + resource "yandex_compute_instance" "runner" {
      + created_at                = (known after apply)
      + folder_id                 = (known after apply)
      + fqdn                      = (known after apply)
      + hostname                  = "runner.korotkovdmitry.ru"
      + id                        = (known after apply)
      + metadata                  = {
          + "ssh-keys" = <<-EOT
                ubuntu:ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABgQDPa+gMP2AjP8ZidhknRHJBBuDDo3N+PuVxXauRwejE4b1Beqig3UsHi6mfq84bKLCSSFclAxl27tphR2aOAW1qCfvPPN5QPiGJs1J8Kts//KWoCCk5P/Ke0bo0S9UHbqNj9wwrG5MzyBIERHxKKxE24fNdjGhkda7HHtw8fuCkATh3pvsytmwXaCkzh8AA17j9RvpSOvilldfS40G3fl8MgZCpeantCEGUvTP+YjnCzTY1Q0LUynHLQptbrqTKstCCgxzo3wDNtHnTxiggsMOduxMfUFZmG3K1YOekxul/h+x4OsQ/WnhwoJrIP5rSVffk5ArxjI2LhpzlMR11SyXs4p7RevwwEKWerugC9JRM6sIFfWhUu0X/1vGkVwuHVcwa85oKKQLwF6fyIBGvhzx76yyX4n3p1gz8v1ibuiYxx28BT8tBlFkDAleciK8Ysn1Zpl2pUE8nIiK90pRkYeyh1+uBWY7IoYowmo5iNXBz+Cuzdl121iPZ0qoHIV1mkMs= vagrant@vagrant
            EOT
        }
      + name                      = "runner"
      + network_acceleration_type = "standard"
      + platform_id               = "standard-v1"
      + service_account_id        = (known after apply)
      + status                    = (known after apply)
      + zone                      = (known after apply)

      + boot_disk {
          + auto_delete = true
          + device_name = (known after apply)
          + disk_id     = (known after apply)
          + mode        = (known after apply)

          + initialize_params {
              + block_size  = (known after apply)
              + description = (known after apply)
              + image_id    = "fd8s2gbn4d5k2rcf12d9"
              + name        = (known after apply)
              + size        = 6
              + snapshot_id = (known after apply)
              + type        = "network-hdd"
            }
        }

      + network_interface {
          + index              = (known after apply)
          + ip_address         = (known after apply)
          + ipv4               = true
          + ipv6               = (known after apply)
          + ipv6_address       = (known after apply)
          + mac_address        = (known after apply)
          + nat                = false
          + nat_ip_address     = (known after apply)
          + nat_ip_version     = (known after apply)
          + security_group_ids = (known after apply)
          + subnet_id          = (known after apply)
        }

      + placement_policy {
          + host_affinity_rules = (known after apply)
          + placement_group_id  = (known after apply)
        }

      + resources {
          + core_fraction = 100
          + cores         = 4
          + memory        = 4
        }

      + scheduling_policy {
          + preemptible = (known after apply)
        }
    }

  # yandex_vpc_network.default will be created
  + resource "yandex_vpc_network" "default" {
      + created_at                = (known after apply)
      + default_security_group_id = (known after apply)
      + folder_id                 = (known after apply)
      + id                        = (known after apply)
      + labels                    = (known after apply)
      + name                      = "net"
      + subnet_ids                = (known after apply)
    }

  # yandex_vpc_subnet.subnet-0 will be created
  + resource "yandex_vpc_subnet" "subnet-0" {
      + created_at     = (known after apply)
      + folder_id      = (known after apply)
      + id             = (known after apply)
      + labels         = (known after apply)
      + name           = "subnet-0"
      + network_id     = (known after apply)
      + v4_cidr_blocks = [
          + "192.168.10.0/24",
        ]
      + v6_cidr_blocks = (known after apply)
      + zone           = "ru-central1-a"
    }

  # yandex_vpc_subnet.subnet-1 will be created
  + resource "yandex_vpc_subnet" "subnet-1" {
      + created_at     = (known after apply)
      + folder_id      = (known after apply)
      + id             = (known after apply)
      + labels         = (known after apply)
      + name           = "subnet-1"
      + network_id     = (known after apply)
      + v4_cidr_blocks = [
          + "192.168.11.0/24",
        ]
      + v6_cidr_blocks = (known after apply)
      + zone           = "ru-central1-b"
    }

Plan: 12 to add, 0 to change, 0 to destroy.
yandex_vpc_network.default: Creating...
yandex_vpc_network.default: Creation complete after 2s [id=enp86osjovl09pv280lv]
yandex_vpc_subnet.subnet-1: Creating...
yandex_vpc_subnet.subnet-0: Creating...
yandex_vpc_subnet.subnet-0: Creation complete after 1s [id=e9bes9gpmbnf461voqfb]
yandex_compute_instance.runner: Creating...
yandex_compute_instance.db01: Creating...
yandex_compute_instance.monitoring: Creating...
yandex_compute_instance.gitlab: Creating...
yandex_compute_instance.nginx: Creating...
yandex_compute_instance.app: Creating...
yandex_compute_instance.db02: Creating...
yandex_vpc_subnet.subnet-1: Creation complete after 2s [id=e2ll0lk4np7alhv2vq5j]
yandex_compute_instance.runner: Still creating... [10s elapsed]
yandex_compute_instance.db01: Still creating... [10s elapsed]
yandex_compute_instance.monitoring: Still creating... [10s elapsed]
yandex_compute_instance.app: Still creating... [10s elapsed]
yandex_compute_instance.gitlab: Still creating... [10s elapsed]
yandex_compute_instance.nginx: Still creating... [10s elapsed]
yandex_compute_instance.db02: Still creating... [10s elapsed]
yandex_compute_instance.runner: Still creating... [20s elapsed]
yandex_compute_instance.db01: Still creating... [20s elapsed]
yandex_compute_instance.monitoring: Still creating... [20s elapsed]
yandex_compute_instance.nginx: Still creating... [20s elapsed]
yandex_compute_instance.app: Still creating... [20s elapsed]
yandex_compute_instance.gitlab: Still creating... [20s elapsed]
yandex_compute_instance.db02: Still creating... [20s elapsed]
yandex_compute_instance.db02: Creation complete after 26s [id=fhmlepfjjqbf5mttegjc]
yandex_compute_instance.runner: Creation complete after 27s [id=fhmrdm9iu6bel3ksl6v4]
yandex_compute_instance.monitoring: Creation complete after 27s [id=fhml30bvp60tm544a2l9]
yandex_compute_instance.app: Creation complete after 27s [id=fhmtr3h65q4aakppralm]
yandex_compute_instance.gitlab: Creation complete after 27s [id=fhm3mqs8rcnc3999ipr2]
yandex_compute_instance.nginx: Creation complete after 28s [id=fhmg1bh3v4f9ms4h6mo4]
null_resource.wait-clear-ssh: Creating...
null_resource.wait-clear-ssh: Provisioning with 'local-exec'...
null_resource.wait-clear-ssh (local-exec): Executing: ["/bin/sh" "-c" "sleep 40"]
yandex_compute_instance.db01: Creation complete after 28s [id=fhm1ujdvf2cinplra2i5]
null_resource.wait-clear-ssh: Still creating... [10s elapsed]
null_resource.wait-clear-ssh: Still creating... [20s elapsed]
null_resource.wait-clear-ssh: Still creating... [30s elapsed]
null_resource.wait-clear-ssh: Still creating... [40s elapsed]
null_resource.wait-clear-ssh: Provisioning with 'local-exec'...
null_resource.wait-clear-ssh (local-exec): Executing: ["/bin/sh" "-c" "ssh-keygen -f '/home/vagrant/.ssh/known_hosts' -R 'korotkovdmitry.ru'"]
null_resource.wait-clear-ssh (local-exec): # Host korotkovdmitry.ru found: line 19
null_resource.wait-clear-ssh (local-exec): /home/vagrant/.ssh/known_hosts updated.
null_resource.wait-clear-ssh (local-exec): Original contents retained as /home/vagrant/.ssh/known_hosts.old
null_resource.wait-clear-ssh: Creation complete after 40s [id=8282910076580073651]
null_resource.playbook: Creating...
null_resource.playbook: Provisioning with 'local-exec'...
null_resource.playbook (local-exec): Executing: ["/bin/sh" "-c" "ANSIBLE_FORCE_COLOR=1 ANSIBLE_HOST_KEY_CHECKING=False ansible-playbook ..//ansible/playbook.yml 
-i ..//ansible/inventory"]

null_resource.playbook (local-exec): PLAY [nginx] *******************************************************************

null_resource.playbook (local-exec): TASK [Gathering Facts] *********************************************************
null_resource.playbook (local-exec): ok: [korotkovdmitry.ru]

null_resource.playbook (local-exec): TASK [install_nginx_letsencrypt : Upgrade system] ******************************
null_resource.playbook: Still creating... [10s elapsed]
null_resource.playbook (local-exec): changed: [korotkovdmitry.ru]

null_resource.playbook (local-exec): TASK [install_nginx_letsencrypt : Install nginx] *******************************
null_resource.playbook: Still creating... [20s elapsed]
null_resource.playbook: Still creating... [30s elapsed]
null_resource.playbook (local-exec): changed: [korotkovdmitry.ru]

null_resource.playbook (local-exec): TASK [install_nginx_letsencrypt : install letsencrypt] *************************
null_resource.playbook: Still creating... [40s elapsed]
null_resource.playbook (local-exec): changed: [korotkovdmitry.ru]

null_resource.playbook (local-exec): TASK [install_nginx_letsencrypt : create letsencrypt directory] ****************
null_resource.playbook (local-exec): changed: [korotkovdmitry.ru]

null_resource.playbook (local-exec): TASK [install_nginx_letsencrypt : Remove default nginx config] *****************
null_resource.playbook: Still creating... [50s elapsed]
null_resource.playbook (local-exec): changed: [korotkovdmitry.ru]

null_resource.playbook (local-exec): TASK [install_nginx_letsencrypt : Install system nginx config] *****************
null_resource.playbook (local-exec): changed: [korotkovdmitry.ru]

null_resource.playbook (local-exec): TASK [install_nginx_letsencrypt : Install nginx site for letsencrypt requests] ***
null_resource.playbook (local-exec): changed: [korotkovdmitry.ru]

null_resource.playbook (local-exec): TASK [install_nginx_letsencrypt : Reload nginx to activate letsencrypt site] ***
null_resource.playbook: Still creating... [1m0s elapsed]
null_resource.playbook (local-exec): changed: [korotkovdmitry.ru]

null_resource.playbook (local-exec): TASK [install_nginx_letsencrypt : Create letsencrypt certificate nginx] ********
null_resource.playbook: Still creating... [1m10s elapsed]
null_resource.playbook (local-exec): changed: [korotkovdmitry.ru]

null_resource.playbook (local-exec): TASK [install_nginx_letsencrypt : Create letsencrypt certificate gitlab] *******
null_resource.playbook (local-exec): changed: [korotkovdmitry.ru]

null_resource.playbook (local-exec): TASK [install_nginx_letsencrypt : Create letsencrypt certificate grafana] ******
null_resource.playbook: Still creating... [1m20s elapsed]
null_resource.playbook (local-exec): changed: [korotkovdmitry.ru]

null_resource.playbook (local-exec): TASK [install_nginx_letsencrypt : Create letsencrypt certificate prometheus] ***
null_resource.playbook: Still creating... [1m30s elapsed]
null_resource.playbook (local-exec): changed: [korotkovdmitry.ru]

null_resource.playbook (local-exec): TASK [install_nginx_letsencrypt : Create letsencrypt certificate alertmanager] ***
null_resource.playbook: Still creating... [1m40s elapsed]
null_resource.playbook (local-exec): changed: [korotkovdmitry.ru]

null_resource.playbook (local-exec): TASK [install_nginx_letsencrypt : Generate dhparams] ***************************
null_resource.playbook: Still creating... [1m50s elapsed]
null_resource.playbook: Still creating... [2m0s elapsed]
null_resource.playbook: Still creating... [2m10s elapsed]
null_resource.playbook: Still creating... [2m20s elapsed]
null_resource.playbook: Still creating... [2m30s elapsed]
null_resource.playbook: Still creating... [2m40s elapsed]
null_resource.playbook: Still creating... [2m50s elapsed]
null_resource.playbook: Still creating... [3m0s elapsed]
null_resource.playbook: Still creating... [3m10s elapsed]
null_resource.playbook: Still creating... [3m21s elapsed]
null_resource.playbook (local-exec): changed: [korotkovdmitry.ru]

null_resource.playbook (local-exec): TASK [install_nginx_letsencrypt : Install nginx site for specified site] *******
null_resource.playbook: Still creating... [3m31s elapsed]
null_resource.playbook (local-exec): changed: [korotkovdmitry.ru]

null_resource.playbook (local-exec): TASK [install_nginx_letsencrypt : Reload nginx to activate specified site] *****
null_resource.playbook (local-exec): changed: [korotkovdmitry.ru]

null_resource.playbook (local-exec): TASK [install_nginx_letsencrypt : Add letsencrypt cronjob for cert renewal] ****
null_resource.playbook (local-exec): changed: [korotkovdmitry.ru]

null_resource.playbook (local-exec): TASK [install_proxy : install privoxy] *****************************************
null_resource.playbook: Still creating... [3m41s elapsed]
null_resource.playbook (local-exec): changed: [korotkovdmitry.ru]

null_resource.playbook (local-exec): TASK [install_proxy : configure privoxy] ***************************************
null_resource.playbook: Still creating... [3m51s elapsed]
null_resource.playbook (local-exec): changed: [korotkovdmitry.ru]

null_resource.playbook (local-exec): TASK [install_proxy : start privoxy] *******************************************
null_resource.playbook (local-exec): ok: [korotkovdmitry.ru]

null_resource.playbook (local-exec): RUNNING HANDLER [install_proxy : restart privoxy] ******************************
null_resource.playbook (local-exec): changed: [korotkovdmitry.ru]

null_resource.playbook (local-exec): PLAY [mysql_db01 mysql_db02] ***************************************************

null_resource.playbook (local-exec): TASK [Gathering Facts] *********************************************************
null_resource.playbook: Still creating... [4m1s elapsed]
null_resource.playbook (local-exec): ok: [db02.korotkovdmitry.ru]
null_resource.playbook (local-exec): ok: [db01.korotkovdmitry.ru]

null_resource.playbook (local-exec): TASK [install_mysql : include_tasks] *******************************************
null_resource.playbook (local-exec): included: /vagrant/ansible/roles/install_mysql/tasks/variables.yml for db01.korotkovdmitry.ru, db02.korotkovdmitry.ru

null_resource.playbook (local-exec): TASK [install_mysql : Include OS-specific variables.] **************************
null_resource.playbook (local-exec): ok: [db01.korotkovdmitry.ru] => (item=/vagrant/ansible/roles/install_mysql/vars/Debian.yml)
null_resource.playbook (local-exec): ok: [db02.korotkovdmitry.ru] => (item=/vagrant/ansible/roles/install_mysql/vars/Debian.yml)

null_resource.playbook (local-exec): TASK [install_mysql : Define mysql_packages.] **********************************
null_resource.playbook (local-exec): ok: [db01.korotkovdmitry.ru]
null_resource.playbook (local-exec): ok: [db02.korotkovdmitry.ru]

null_resource.playbook (local-exec): TASK [install_mysql : Define mysql_daemon.] ************************************
null_resource.playbook (local-exec): ok: [db01.korotkovdmitry.ru]
null_resource.playbook (local-exec): ok: [db02.korotkovdmitry.ru]

null_resource.playbook (local-exec): TASK [install_mysql : Define mysql_slow_query_log_file.] ***********************
null_resource.playbook (local-exec): ok: [db01.korotkovdmitry.ru]
null_resource.playbook (local-exec): ok: [db02.korotkovdmitry.ru]

null_resource.playbook (local-exec): TASK [install_mysql : Define mysql_log_error.] *********************************
null_resource.playbook (local-exec): ok: [db01.korotkovdmitry.ru]
null_resource.playbook (local-exec): ok: [db02.korotkovdmitry.ru]

null_resource.playbook (local-exec): TASK [install_mysql : Define mysql_syslog_tag.] ********************************
null_resource.playbook (local-exec): ok: [db01.korotkovdmitry.ru]
null_resource.playbook (local-exec): ok: [db02.korotkovdmitry.ru]

null_resource.playbook (local-exec): TASK [install_mysql : Define mysql_pid_file.] **********************************
null_resource.playbook (local-exec): ok: [db01.korotkovdmitry.ru]
null_resource.playbook (local-exec): ok: [db02.korotkovdmitry.ru]

null_resource.playbook (local-exec): TASK [install_mysql : Define mysql_config_file.] *******************************
null_resource.playbook (local-exec): ok: [db01.korotkovdmitry.ru]
null_resource.playbook (local-exec): ok: [db02.korotkovdmitry.ru]

null_resource.playbook (local-exec): TASK [install_mysql : Define mysql_config_include_dir.] ************************
null_resource.playbook (local-exec): ok: [db01.korotkovdmitry.ru]
null_resource.playbook (local-exec): ok: [db02.korotkovdmitry.ru]

null_resource.playbook (local-exec): TASK [install_mysql : Define mysql_socket.] ************************************
null_resource.playbook (local-exec): ok: [db01.korotkovdmitry.ru]
null_resource.playbook (local-exec): ok: [db02.korotkovdmitry.ru]

null_resource.playbook (local-exec): TASK [install_mysql : Define mysql_supports_innodb_large_prefix.] **************
null_resource.playbook (local-exec): ok: [db01.korotkovdmitry.ru]
null_resource.playbook (local-exec): ok: [db02.korotkovdmitry.ru]

null_resource.playbook (local-exec): TASK [install_mysql : include_tasks] *******************************************
null_resource.playbook (local-exec): skipping: [db01.korotkovdmitry.ru]
null_resource.playbook (local-exec): skipping: [db02.korotkovdmitry.ru]

null_resource.playbook (local-exec): TASK [install_mysql : include_tasks] *******************************************
null_resource.playbook (local-exec): included: /vagrant/ansible/roles/install_mysql/tasks/setup-Debian.yml for db01.korotkovdmitry.ru, db02.korotkovdmitry.ru

null_resource.playbook (local-exec): TASK [install_mysql : Check if MySQL is already installed.] ********************
null_resource.playbook (local-exec): ok: [db02.korotkovdmitry.ru]
null_resource.playbook (local-exec): ok: [db01.korotkovdmitry.ru]

null_resource.playbook (local-exec): TASK [install_mysql : Update apt cache if MySQL is not yet installed.] *********
null_resource.playbook: Still creating... [4m11s elapsed]
null_resource.playbook (local-exec): ok: [db02.korotkovdmitry.ru]
null_resource.playbook (local-exec): ok: [db01.korotkovdmitry.ru]

null_resource.playbook (local-exec): TASK [install_mysql : Ensure MySQL Python libraries are installed.] ************
null_resource.playbook: Still creating... [4m21s elapsed]
null_resource.playbook (local-exec): changed: [db02.korotkovdmitry.ru]
null_resource.playbook (local-exec): changed: [db01.korotkovdmitry.ru]

null_resource.playbook (local-exec): TASK [install_mysql : Ensure MySQL packages are installed.] ********************
null_resource.playbook: Still creating... [4m31s elapsed]
null_resource.playbook: Still creating... [4m41s elapsed]
null_resource.playbook: Still creating... [4m51s elapsed]
null_resource.playbook (local-exec): changed: [db02.korotkovdmitry.ru]
null_resource.playbook (local-exec): changed: [db01.korotkovdmitry.ru]

null_resource.playbook (local-exec): TASK [install_mysql : Ensure MySQL is stopped after initial install.] **********
null_resource.playbook (local-exec): changed: [db02.korotkovdmitry.ru]
null_resource.playbook: Still creating... [5m1s elapsed]
null_resource.playbook (local-exec): changed: [db01.korotkovdmitry.ru]

null_resource.playbook (local-exec): TASK [install_mysql : Delete innodb log files created by apt package after initial install.] ***
null_resource.playbook (local-exec): changed: [db01.korotkovdmitry.ru] => (item=ib_logfile0)
null_resource.playbook (local-exec): changed: [db02.korotkovdmitry.ru] => (item=ib_logfile0)
null_resource.playbook (local-exec): changed: [db02.korotkovdmitry.ru] => (item=ib_logfile1)
null_resource.playbook (local-exec): changed: [db01.korotkovdmitry.ru] => (item=ib_logfile1)

null_resource.playbook (local-exec): TASK [install_mysql : include_tasks] *******************************************
null_resource.playbook (local-exec): skipping: [db01.korotkovdmitry.ru]
null_resource.playbook (local-exec): skipping: [db02.korotkovdmitry.ru]

null_resource.playbook (local-exec): TASK [install_mysql : Check if MySQL packages were installed.] *****************
null_resource.playbook (local-exec): ok: [db01.korotkovdmitry.ru]
null_resource.playbook (local-exec): ok: [db02.korotkovdmitry.ru]

null_resource.playbook (local-exec): TASK [install_mysql : include_tasks] *******************************************
null_resource.playbook (local-exec): included: /vagrant/ansible/roles/install_mysql/tasks/configure.yml for db01.korotkovdmitry.ru, db02.korotkovdmitry.ru

null_resource.playbook (local-exec): TASK [install_mysql : Get MySQL version.] **************************************
null_resource.playbook (local-exec): ok: [db01.korotkovdmitry.ru]
null_resource.playbook (local-exec): ok: [db02.korotkovdmitry.ru]

null_resource.playbook (local-exec): TASK [install_mysql : Copy my.cnf global MySQL configuration.] *****************
null_resource.playbook: Still creating... [5m11s elapsed]
null_resource.playbook (local-exec): changed: [db01.korotkovdmitry.ru]
null_resource.playbook (local-exec): changed: [db02.korotkovdmitry.ru]

null_resource.playbook (local-exec): TASK [install_mysql : Verify mysql include directory exists.] ******************
null_resource.playbook (local-exec): skipping: [db01.korotkovdmitry.ru]
null_resource.playbook (local-exec): skipping: [db02.korotkovdmitry.ru]

null_resource.playbook (local-exec): TASK [install_mysql : Copy my.cnf override files into include directory.] ******

null_resource.playbook (local-exec): TASK [install_mysql : Create slow query log file (if configured).] *************
null_resource.playbook (local-exec): skipping: [db01.korotkovdmitry.ru]
null_resource.playbook (local-exec): skipping: [db02.korotkovdmitry.ru]

null_resource.playbook (local-exec): TASK [install_mysql : Create datadir if it does not exist] *********************
null_resource.playbook (local-exec): changed: [db01.korotkovdmitry.ru]
null_resource.playbook (local-exec): changed: [db02.korotkovdmitry.ru]

null_resource.playbook (local-exec): TASK [install_mysql : Set ownership on slow query log file (if configured).] ***
null_resource.playbook (local-exec): skipping: [db01.korotkovdmitry.ru]
null_resource.playbook (local-exec): skipping: [db02.korotkovdmitry.ru]

null_resource.playbook (local-exec): TASK [install_mysql : Create error log file (if configured).] ******************
null_resource.playbook (local-exec): skipping: [db01.korotkovdmitry.ru]
null_resource.playbook (local-exec): skipping: [db02.korotkovdmitry.ru]

null_resource.playbook (local-exec): TASK [install_mysql : Set ownership on error log file (if configured).] ********
null_resource.playbook (local-exec): skipping: [db01.korotkovdmitry.ru]
null_resource.playbook (local-exec): skipping: [db02.korotkovdmitry.ru]

null_resource.playbook (local-exec): TASK [install_mysql : Ensure MySQL is started and enabled on boot.] ************
null_resource.playbook (local-exec): changed: [db02.korotkovdmitry.ru]
null_resource.playbook (local-exec): changed: [db01.korotkovdmitry.ru]

null_resource.playbook (local-exec): TASK [install_mysql : include_tasks] *******************************************
null_resource.playbook: Still creating... [5m21s elapsed]
null_resource.playbook (local-exec): included: /vagrant/ansible/roles/install_mysql/tasks/secure-installation.yml for db01.korotkovdmitry.ru, db02.korotkovdmitry.ru

null_resource.playbook (local-exec): TASK [install_mysql : Ensure default user is present.] *************************
null_resource.playbook (local-exec): changed: [db01.korotkovdmitry.ru]
null_resource.playbook (local-exec): changed: [db02.korotkovdmitry.ru]

null_resource.playbook (local-exec): TASK [install_mysql : Copy user-my.cnf file with password credentials.] ********
null_resource.playbook (local-exec): changed: [db01.korotkovdmitry.ru]
null_resource.playbook (local-exec): changed: [db02.korotkovdmitry.ru]

null_resource.playbook (local-exec): TASK [install_mysql : Disallow root login remotely] ****************************
null_resource.playbook (local-exec): ok: [db02.korotkovdmitry.ru] => (item=DELETE FROM mysql.user WHERE User='root' AND Host NOT IN ('localhost', '127.0.0.1', '::1'))
null_resource.playbook (local-exec): ok: [db01.korotkovdmitry.ru] => (item=DELETE FROM mysql.user WHERE User='root' AND Host NOT IN ('localhost', '127.0.0.1', '::1'))

null_resource.playbook (local-exec): TASK [install_mysql : Get list of hosts for the root user.] ********************
null_resource.playbook: Still creating... [5m31s elapsed]
null_resource.playbook (local-exec): ok: [db02.korotkovdmitry.ru]
null_resource.playbook (local-exec): ok: [db01.korotkovdmitry.ru]

null_resource.playbook (local-exec): TASK [install_mysql : Update MySQL root password for localhost root account (5.7.x).] ***
null_resource.playbook (local-exec): changed: [db02.korotkovdmitry.ru] => (item=localhost)
null_resource.playbook (local-exec): changed: [db01.korotkovdmitry.ru] => (item=localhost)

null_resource.playbook (local-exec): TASK [install_mysql : Update MySQL root password for localhost root account (< 5.7.x).] ***
null_resource.playbook (local-exec): skipping: [db01.korotkovdmitry.ru] => (item=localhost) 
null_resource.playbook (local-exec): skipping: [db02.korotkovdmitry.ru] => (item=localhost) 

null_resource.playbook (local-exec): TASK [install_mysql : Copy .my.cnf file with root password credentials.] *******
null_resource.playbook (local-exec): changed: [db02.korotkovdmitry.ru]
null_resource.playbook (local-exec): changed: [db01.korotkovdmitry.ru]

null_resource.playbook (local-exec): TASK [install_mysql : Get list of hosts for the anonymous user.] ***************
null_resource.playbook: Still creating... [5m41s elapsed]
null_resource.playbook (local-exec): ok: [db02.korotkovdmitry.ru]
null_resource.playbook (local-exec): ok: [db01.korotkovdmitry.ru]

null_resource.playbook (local-exec): TASK [install_mysql : Remove anonymous MySQL users.] ***************************

null_resource.playbook (local-exec): TASK [install_mysql : Remove MySQL test database.] *****************************
null_resource.playbook (local-exec): ok: [db01.korotkovdmitry.ru]
null_resource.playbook (local-exec): ok: [db02.korotkovdmitry.ru]

null_resource.playbook (local-exec): TASK [install_mysql : include_tasks] *******************************************
null_resource.playbook (local-exec): included: /vagrant/ansible/roles/install_mysql/tasks/databases.yml for db01.korotkovdmitry.ru, db02.korotkovdmitry.ru

null_resource.playbook (local-exec): TASK [install_mysql : Ensure MySQL databases are present.] *********************
null_resource.playbook (local-exec): changed: [db01.korotkovdmitry.ru] => (item={'name': 'wordpress', 'collation': 'utf8_general_ci', 'encoding': 'utf8', 'replicate': 1})
null_resource.playbook (local-exec): changed: [db02.korotkovdmitry.ru] => (item={'name': 'wordpress', 'collation': 'utf8_general_ci', 'encoding': 'utf8', 'replicate': 1})

null_resource.playbook (local-exec): TASK [install_mysql : include_tasks] *******************************************
null_resource.playbook (local-exec): included: /vagrant/ansible/roles/install_mysql/tasks/users.yml for db01.korotkovdmitry.ru, db02.korotkovdmitry.ru

null_resource.playbook (local-exec): TASK [install_mysql : Ensure MySQL users are present.] *************************
null_resource.playbook (local-exec): changed: [db02.korotkovdmitry.ru] => (item=None)
null_resource.playbook (local-exec): changed: [db01.korotkovdmitry.ru] => (item=None)
null_resource.playbook: Still creating... [5m51s elapsed]
null_resource.playbook (local-exec): changed: [db02.korotkovdmitry.ru] => (item=None)
null_resource.playbook (local-exec): changed: [db02.korotkovdmitry.ru]
null_resource.playbook (local-exec): changed: [db01.korotkovdmitry.ru] => (item=None)
null_resource.playbook (local-exec): changed: [db01.korotkovdmitry.ru]

null_resource.playbook (local-exec): TASK [install_mysql : include_tasks] *******************************************
null_resource.playbook (local-exec): included: /vagrant/ansible/roles/install_mysql/tasks/replication.yml for db01.korotkovdmitry.ru, db02.korotkovdmitry.ru

null_resource.playbook (local-exec): TASK [install_mysql : Ensure replication user exists on master.] ***************
null_resource.playbook (local-exec): skipping: [db02.korotkovdmitry.ru]
null_resource.playbook (local-exec): changed: [db01.korotkovdmitry.ru]

null_resource.playbook (local-exec): TASK [install_mysql : Check slave replication status.] *************************
null_resource.playbook (local-exec): skipping: [db01.korotkovdmitry.ru]
null_resource.playbook (local-exec): ok: [db02.korotkovdmitry.ru]

null_resource.playbook (local-exec): TASK [install_mysql : Check master replication status.] ************************
null_resource.playbook (local-exec): skipping: [db01.korotkovdmitry.ru]
null_resource.playbook (local-exec): skipping: [db02.korotkovdmitry.ru]

null_resource.playbook (local-exec): TASK [install_mysql : Configure replication on the slave.] *********************
null_resource.playbook (local-exec): skipping: [db01.korotkovdmitry.ru]
null_resource.playbook (local-exec): skipping: [db02.korotkovdmitry.ru]

null_resource.playbook (local-exec): TASK [install_mysql : Start replication.] **************************************
null_resource.playbook (local-exec): skipping: [db01.korotkovdmitry.ru]
null_resource.playbook (local-exec): skipping: [db02.korotkovdmitry.ru]

null_resource.playbook (local-exec): RUNNING HANDLER [install_mysql : restart mysql] ********************************
null_resource.playbook (local-exec): [WARNING]: Ignoring "sleep" as it is not used in "systemd"
null_resource.playbook (local-exec): [WARNING]: Ignoring "sleep" as it is not used in "systemd"
null_resource.playbook: Still creating... [6m1s elapsed]
null_resource.playbook (local-exec): changed: [db02.korotkovdmitry.ru]
null_resource.playbook (local-exec): changed: [db01.korotkovdmitry.ru]

null_resource.playbook (local-exec): PLAY [app] *********************************************************************

null_resource.playbook (local-exec): TASK [Gathering Facts] *********************************************************
null_resource.playbook (local-exec): ok: [app.korotkovdmitry.ru]

null_resource.playbook (local-exec): TASK [wordpress : Update apt cache] ********************************************
null_resource.playbook: Still creating... [6m11s elapsed]
null_resource.playbook: Still creating... [6m21s elapsed]
null_resource.playbook (local-exec): changed: [app.korotkovdmitry.ru]

null_resource.playbook (local-exec): TASK [wordpress : Install prerequisites] ***************************************
null_resource.playbook: Still creating... [6m31s elapsed]
null_resource.playbook (local-exec): changed: [app.korotkovdmitry.ru]

null_resource.playbook (local-exec): TASK [wordpress : Install LAMP Packages] ***************************************
null_resource.playbook: Still creating... [6m41s elapsed]
null_resource.playbook (local-exec): changed: [app.korotkovdmitry.ru] => (item=apache2)
null_resource.playbook: Still creating... [6m51s elapsed]
null_resource.playbook: Still creating... [7m1s elapsed]
null_resource.playbook (local-exec): changed: [app.korotkovdmitry.ru] => (item=php)
null_resource.playbook (local-exec): changed: [app.korotkovdmitry.ru] => (item=php-mysql)
null_resource.playbook: Still creating... [7m11s elapsed]
null_resource.playbook (local-exec): changed: [app.korotkovdmitry.ru] => (item=libapache2-mod-php)

null_resource.playbook (local-exec): TASK [wordpress : Install PHP Extensions] **************************************
null_resource.playbook (local-exec): changed: [app.korotkovdmitry.ru] => (item=php-curl)
null_resource.playbook: Still creating... [7m21s elapsed]
null_resource.playbook (local-exec): changed: [app.korotkovdmitry.ru] => (item=php-gd)
null_resource.playbook: Still creating... [7m31s elapsed]
null_resource.playbook (local-exec): changed: [app.korotkovdmitry.ru] => (item=php-mbstring)
null_resource.playbook: Still creating... [7m41s elapsed]
null_resource.playbook (local-exec): changed: [app.korotkovdmitry.ru] => (item=php-xml)
null_resource.playbook (local-exec): changed: [app.korotkovdmitry.ru] => (item=php-xmlrpc)
null_resource.playbook: Still creating... [7m51s elapsed]
null_resource.playbook (local-exec): changed: [app.korotkovdmitry.ru] => (item=php-soap)
null_resource.playbook (local-exec): changed: [app.korotkovdmitry.ru] => (item=php-intl)
null_resource.playbook: Still creating... [8m1s elapsed]
null_resource.playbook (local-exec): changed: [app.korotkovdmitry.ru] => (item=php-zip)

null_resource.playbook (local-exec): TASK [wordpress : Create document root] ****************************************
null_resource.playbook (local-exec): changed: [app.korotkovdmitry.ru]

null_resource.playbook (local-exec): TASK [wordpress : Set up Apache VirtualHost] ***********************************
null_resource.playbook: Still creating... [8m11s elapsed]
null_resource.playbook (local-exec): changed: [app.korotkovdmitry.ru]

null_resource.playbook (local-exec): TASK [wordpress : Enable rewrite module] ***************************************
null_resource.playbook (local-exec): changed: [app.korotkovdmitry.ru]

null_resource.playbook (local-exec): TASK [wordpress : Enable new site] *********************************************
null_resource.playbook (local-exec): changed: [app.korotkovdmitry.ru]

null_resource.playbook (local-exec): TASK [wordpress : Disable default Apache site] *********************************
null_resource.playbook (local-exec): changed: [app.korotkovdmitry.ru]

null_resource.playbook (local-exec): TASK [wordpress : UFW - Allow HTTP on port 80] *********************************
null_resource.playbook: Still creating... [8m21s elapsed]
null_resource.playbook (local-exec): changed: [app.korotkovdmitry.ru]

null_resource.playbook (local-exec): TASK [wordpress : Download and unpack latest WordPress] ************************
null_resource.playbook (local-exec): changed: [app.korotkovdmitry.ru]

null_resource.playbook (local-exec): TASK [wordpress : Set ownership] ***********************************************
null_resource.playbook: Still creating... [8m31s elapsed]
null_resource.playbook (local-exec): changed: [app.korotkovdmitry.ru]

null_resource.playbook (local-exec): TASK [wordpress : Set permissions for directories] *****************************
null_resource.playbook (local-exec): changed: [app.korotkovdmitry.ru]

null_resource.playbook (local-exec): TASK [wordpress : Set permissions for files] ***********************************
null_resource.playbook (local-exec): changed: [app.korotkovdmitry.ru]

null_resource.playbook (local-exec): TASK [wordpress : Set up wp-config] ********************************************
null_resource.playbook: Still creating... [8m41s elapsed]
null_resource.playbook (local-exec): changed: [app.korotkovdmitry.ru]

null_resource.playbook (local-exec): RUNNING HANDLER [wordpress : reload apache] ************************************
null_resource.playbook (local-exec): changed: [app.korotkovdmitry.ru]

null_resource.playbook (local-exec): RUNNING HANDLER [wordpress : restart apache] ***********************************
null_resource.playbook (local-exec): changed: [app.korotkovdmitry.ru]

null_resource.playbook (local-exec): PLAY [gitlab] ******************************************************************

null_resource.playbook (local-exec): TASK [Gathering Facts] *********************************************************
null_resource.playbook: Still creating... [8m51s elapsed]
null_resource.playbook (local-exec): ok: [gitlab.korotkovdmitry.ru]

null_resource.playbook (local-exec): TASK [gitlab : Update and upgrade apt packages] ********************************
null_resource.playbook: Still creating... [9m1s elapsed]
null_resource.playbook: Still creating... [9m11s elapsed]
null_resource.playbook: Still creating... [9m21s elapsed]
null_resource.playbook: Still creating... [9m31s elapsed]
null_resource.playbook: Still creating... [9m41s elapsed]
null_resource.playbook (local-exec): changed: [gitlab.korotkovdmitry.ru]

null_resource.playbook (local-exec): TASK [gitlab : Include OS-specific variables.] *********************************
null_resource.playbook (local-exec): ok: [gitlab.korotkovdmitry.ru]

null_resource.playbook (local-exec): TASK [gitlab : Check if GitLab configuration file already exists.] *************
null_resource.playbook: Still creating... [9m51s elapsed]
null_resource.playbook (local-exec): ok: [gitlab.korotkovdmitry.ru]

null_resource.playbook (local-exec): TASK [gitlab : Check if GitLab is already installed.] **************************
null_resource.playbook (local-exec): ok: [gitlab.korotkovdmitry.ru]

null_resource.playbook (local-exec): TASK [gitlab : Install GitLab dependencies.] ***********************************
null_resource.playbook: Still creating... [10m1s elapsed]
null_resource.playbook: Still creating... [10m11s elapsed]
null_resource.playbook (local-exec): changed: [gitlab.korotkovdmitry.ru]

null_resource.playbook (local-exec): TASK [gitlab : Install GitLab dependencies (Debian).] **************************
null_resource.playbook (local-exec): changed: [gitlab.korotkovdmitry.ru]

null_resource.playbook (local-exec): TASK [gitlab : Download GitLab repository installation script.] ****************
null_resource.playbook: Still creating... [10m21s elapsed]
null_resource.playbook (local-exec): changed: [gitlab.korotkovdmitry.ru]

null_resource.playbook (local-exec): TASK [gitlab : Install GitLab repository.] *************************************
null_resource.playbook: Still creating... [10m31s elapsed]
null_resource.playbook (local-exec): changed: [gitlab.korotkovdmitry.ru]

null_resource.playbook (local-exec): TASK [gitlab : Define the Gitlab package name.] ********************************
null_resource.playbook (local-exec): skipping: [gitlab.korotkovdmitry.ru]

null_resource.playbook (local-exec): TASK [gitlab : Install GitLab] *************************************************
null_resource.playbook: Still creating... [10m41s elapsed]
null_resource.playbook (local-exec): ASYNC POLL on gitlab.korotkovdmitry.ru: jid=765078900027.9139 started=1 finished=0
null_resource.playbook (local-exec): ASYNC POLL on gitlab.korotkovdmitry.ru: jid=765078900027.9139 started=1 finished=0
null_resource.playbook: Still creating... [10m51s elapsed]
null_resource.playbook (local-exec): ASYNC POLL on gitlab.korotkovdmitry.ru: jid=765078900027.9139 started=1 finished=0
null_resource.playbook: Still creating... [11m1s elapsed]
null_resource.playbook (local-exec): ASYNC POLL on gitlab.korotkovdmitry.ru: jid=765078900027.9139 started=1 finished=0
null_resource.playbook (local-exec): ASYNC POLL on gitlab.korotkovdmitry.ru: jid=765078900027.9139 started=1 finished=0
null_resource.playbook: Still creating... [11m11s elapsed]
null_resource.playbook (local-exec): ASYNC POLL on gitlab.korotkovdmitry.ru: jid=765078900027.9139 started=1 finished=0
null_resource.playbook: Still creating... [11m21s elapsed]
null_resource.playbook (local-exec): ASYNC POLL on gitlab.korotkovdmitry.ru: jid=765078900027.9139 started=1 finished=0
null_resource.playbook (local-exec): ASYNC POLL on gitlab.korotkovdmitry.ru: jid=765078900027.9139 started=1 finished=0
null_resource.playbook: Still creating... [11m31s elapsed]
null_resource.playbook (local-exec): ASYNC POLL on gitlab.korotkovdmitry.ru: jid=765078900027.9139 started=1 finished=0
null_resource.playbook: Still creating... [11m41s elapsed]
null_resource.playbook (local-exec): ASYNC POLL on gitlab.korotkovdmitry.ru: jid=765078900027.9139 started=1 finished=0
null_resource.playbook (local-exec): ASYNC POLL on gitlab.korotkovdmitry.ru: jid=765078900027.9139 started=1 finished=0
null_resource.playbook: Still creating... [11m51s elapsed]
null_resource.playbook (local-exec): ASYNC POLL on gitlab.korotkovdmitry.ru: jid=765078900027.9139 started=1 finished=0
null_resource.playbook: Still creating... [12m1s elapsed]
null_resource.playbook (local-exec): ASYNC POLL on gitlab.korotkovdmitry.ru: jid=765078900027.9139 started=1 finished=0
null_resource.playbook (local-exec): ASYNC POLL on gitlab.korotkovdmitry.ru: jid=765078900027.9139 started=1 finished=0
null_resource.playbook: Still creating... [12m11s elapsed]
null_resource.playbook (local-exec): ASYNC POLL on gitlab.korotkovdmitry.ru: jid=765078900027.9139 started=1 finished=0
null_resource.playbook: Still creating... [12m21s elapsed]
null_resource.playbook (local-exec): ASYNC POLL on gitlab.korotkovdmitry.ru: jid=765078900027.9139 started=1 finished=0
null_resource.playbook: Still creating... [12m31s elapsed]
null_resource.playbook (local-exec): ASYNC POLL on gitlab.korotkovdmitry.ru: jid=765078900027.9139 started=1 finished=0
null_resource.playbook (local-exec): ASYNC POLL on gitlab.korotkovdmitry.ru: jid=765078900027.9139 started=1 finished=0
null_resource.playbook: Still creating... [12m41s elapsed]
null_resource.playbook (local-exec): ASYNC OK on gitlab.korotkovdmitry.ru: jid=765078900027.9139
null_resource.playbook (local-exec): changed: [gitlab.korotkovdmitry.ru]

null_resource.playbook (local-exec): TASK [gitlab : Reconfigure GitLab (first run).] ********************************
null_resource.playbook: Still creating... [12m51s elapsed]
null_resource.playbook: Still creating... [13m1s elapsed]
null_resource.playbook: Still creating... [13m11s elapsed]
null_resource.playbook: Still creating... [13m21s elapsed]
null_resource.playbook: Still creating... [13m31s elapsed]
null_resource.playbook: Still creating... [13m41s elapsed]
null_resource.playbook: Still creating... [13m51s elapsed]
null_resource.playbook: Still creating... [14m1s elapsed]
null_resource.playbook: Still creating... [14m11s elapsed]
null_resource.playbook: Still creating... [14m21s elapsed]
null_resource.playbook: Still creating... [14m31s elapsed]
null_resource.playbook: Still creating... [14m41s elapsed]
null_resource.playbook: Still creating... [14m51s elapsed]
null_resource.playbook: Still creating... [15m1s elapsed]
null_resource.playbook: Still creating... [15m11s elapsed]
null_resource.playbook: Still creating... [15m21s elapsed]
null_resource.playbook: Still creating... [15m31s elapsed]
null_resource.playbook: Still creating... [15m41s elapsed]
null_resource.playbook: Still creating... [15m51s elapsed]
null_resource.playbook: Still creating... [16m1s elapsed]
null_resource.playbook: Still creating... [16m11s elapsed]
null_resource.playbook (local-exec): changed: [gitlab.korotkovdmitry.ru]

null_resource.playbook (local-exec): TASK [gitlab : Create GitLab SSL configuration folder.] ************************
null_resource.playbook (local-exec): skipping: [gitlab.korotkovdmitry.ru]

null_resource.playbook (local-exec): TASK [gitlab : Create self-signed certificate.] ********************************
null_resource.playbook (local-exec): skipping: [gitlab.korotkovdmitry.ru]

null_resource.playbook (local-exec): TASK [gitlab : Copy GitLab configuration file.] ********************************
null_resource.playbook: Still creating... [16m21s elapsed]
null_resource.playbook (local-exec): changed: [gitlab.korotkovdmitry.ru]

null_resource.playbook (local-exec): RUNNING HANDLER [gitlab : restart gitlab] **************************************
null_resource.playbook: Still creating... [16m31s elapsed]
null_resource.playbook: Still creating... [16m41s elapsed]
null_resource.playbook: Still creating... [16m51s elapsed]
null_resource.playbook: Still creating... [17m1s elapsed]
null_resource.playbook: Still creating... [17m11s elapsed]
null_resource.playbook (local-exec): changed: [gitlab.korotkovdmitry.ru]

null_resource.playbook (local-exec): PLAY [runner] ******************************************************************

null_resource.playbook (local-exec): TASK [Gathering Facts] *********************************************************
null_resource.playbook (local-exec): ok: [runner.korotkovdmitry.ru]

null_resource.playbook (local-exec): TASK [gitlab-runner : Load platform-specific variables] ************************
null_resource.playbook (local-exec): ok: [runner.korotkovdmitry.ru]

null_resource.playbook (local-exec): TASK [gitlab-runner : (Container) Pull Image from Registry] ********************
null_resource.playbook (local-exec): skipping: [runner.korotkovdmitry.ru]

null_resource.playbook (local-exec): TASK [gitlab-runner : (Container) Define Container volume Path] ****************
null_resource.playbook (local-exec): skipping: [runner.korotkovdmitry.ru]

null_resource.playbook (local-exec): TASK [gitlab-runner : (Container) List configured runners] *********************
null_resource.playbook (local-exec): skipping: [runner.korotkovdmitry.ru]

null_resource.playbook (local-exec): TASK [gitlab-runner : (Container) Check runner is registered] ******************
null_resource.playbook (local-exec): skipping: [runner.korotkovdmitry.ru]

null_resource.playbook (local-exec): TASK [gitlab-runner : configured_runners?] *************************************
null_resource.playbook (local-exec): skipping: [runner.korotkovdmitry.ru]

null_resource.playbook (local-exec): TASK [gitlab-runner : verified_runners?] ***************************************
null_resource.playbook (local-exec): skipping: [runner.korotkovdmitry.ru]

null_resource.playbook (local-exec): TASK [gitlab-runner : (Container) Register GitLab Runner] **********************
null_resource.playbook (local-exec): skipping: [runner.korotkovdmitry.ru] => (item={'name': 'runner', 'state': 'present', 'executor': 'shell', 'output_limit': 4096, 'concurrent_specific': '0', 'docker_image': '', 'tags': [], 'run_untagged': True, 'protected': False, 'docker_privileged': False, 'locked': 'false', 'docker_network_mode': 'bridge', 'env_vars': []})

null_resource.playbook (local-exec): TASK [gitlab-runner : Create .gitlab-runner dir] *******************************
null_resource.playbook (local-exec): skipping: [runner.korotkovdmitry.ru]

null_resource.playbook (local-exec): TASK [gitlab-runner : Ensure config.toml exists] *******************************
null_resource.playbook (local-exec): skipping: [runner.korotkovdmitry.ru]

null_resource.playbook (local-exec): TASK [gitlab-runner : Set concurrent option] ***********************************
null_resource.playbook (local-exec): skipping: [runner.korotkovdmitry.ru]

null_resource.playbook (local-exec): TASK [gitlab-runner : Add listen_address to config] ****************************
null_resource.playbook (local-exec): skipping: [runner.korotkovdmitry.ru]

null_resource.playbook (local-exec): TASK [gitlab-runner : Add log_format to config] ********************************
null_resource.playbook (local-exec): skipping: [runner.korotkovdmitry.ru]

null_resource.playbook (local-exec): TASK [gitlab-runner : Add sentry dsn to config] ********************************
null_resource.playbook (local-exec): skipping: [runner.korotkovdmitry.ru]

null_resource.playbook (local-exec): TASK [gitlab-runner : Add session server listen_address to config] *************
null_resource.playbook (local-exec): skipping: [runner.korotkovdmitry.ru]

null_resource.playbook (local-exec): TASK [gitlab-runner : Add session server advertise_address to config] **********
null_resource.playbook (local-exec): skipping: [runner.korotkovdmitry.ru]

null_resource.playbook (local-exec): TASK [gitlab-runner : Add session server session_timeout to config] ************
null_resource.playbook (local-exec): skipping: [runner.korotkovdmitry.ru]

null_resource.playbook (local-exec): TASK [gitlab-runner : Get existing config.toml] ********************************
null_resource.playbook (local-exec): skipping: [runner.korotkovdmitry.ru]

null_resource.playbook (local-exec): TASK [gitlab-runner : Get pre-existing runner configs] *************************
null_resource.playbook (local-exec): skipping: [runner.korotkovdmitry.ru]

null_resource.playbook (local-exec): TASK [gitlab-runner : Create temporary directory] ******************************
null_resource.playbook (local-exec): skipping: [runner.korotkovdmitry.ru]

null_resource.playbook (local-exec): TASK [gitlab-runner : Write config section for each runner] ********************
null_resource.playbook (local-exec): skipping: [runner.korotkovdmitry.ru]

null_resource.playbook (local-exec): TASK [gitlab-runner : Assemble new config.toml] ********************************
null_resource.playbook (local-exec): skipping: [runner.korotkovdmitry.ru]

null_resource.playbook (local-exec): TASK [gitlab-runner : (Container) Start the container] *************************
null_resource.playbook (local-exec): skipping: [runner.korotkovdmitry.ru]

null_resource.playbook (local-exec): TASK [gitlab-runner : (Debian) Get Gitlab repository installation script] ******
null_resource.playbook: Still creating... [17m21s elapsed]
null_resource.playbook (local-exec): changed: [runner.korotkovdmitry.ru]

null_resource.playbook (local-exec): TASK [gitlab-runner : (Debian) Install Gitlab repository] **********************
null_resource.playbook: Still creating... [17m31s elapsed]
null_resource.playbook (local-exec): changed: [runner.korotkovdmitry.ru]

null_resource.playbook (local-exec): TASK [gitlab-runner : (Debian) Update gitlab_runner_package_name] **************
null_resource.playbook (local-exec): skipping: [runner.korotkovdmitry.ru]

null_resource.playbook (local-exec): TASK [gitlab-runner : (Debian) Set gitlab_runner_package_name] *****************
null_resource.playbook (local-exec): ok: [runner.korotkovdmitry.ru]

null_resource.playbook (local-exec): TASK [gitlab-runner : (Debian) Install GitLab Runner] **************************
null_resource.playbook (local-exec): skipping: [runner.korotkovdmitry.ru]

null_resource.playbook (local-exec): TASK [gitlab-runner : (Debian) Install GitLab Runner] **************************
null_resource.playbook: Still creating... [17m41s elapsed]
null_resource.playbook: Still creating... [17m51s elapsed]
null_resource.playbook: Still creating... [18m1s elapsed]
null_resource.playbook: Still creating... [18m11s elapsed]
null_resource.playbook: Still creating... [18m21s elapsed]
null_resource.playbook: Still creating... [18m31s elapsed]
null_resource.playbook: Still creating... [18m41s elapsed]
null_resource.playbook (local-exec): changed: [runner.korotkovdmitry.ru]

null_resource.playbook (local-exec): TASK [gitlab-runner : (Debian) Remove ~/gitlab-runner/.bash_logout on debian buster and ubuntu focal] ***
null_resource.playbook (local-exec): skipping: [runner.korotkovdmitry.ru]

null_resource.playbook (local-exec): TASK [gitlab-runner : Ensure /etc/systemd/system/gitlab-runner.service.d/ exists] ***
null_resource.playbook: Still creating... [18m51s elapsed]
null_resource.playbook (local-exec): changed: [runner.korotkovdmitry.ru]

null_resource.playbook (local-exec): TASK [gitlab-runner : Add reload command to GitLab Runner system service] ******
null_resource.playbook (local-exec): changed: [runner.korotkovdmitry.ru]

null_resource.playbook (local-exec): TASK [gitlab-runner : Configure graceful stop for GitLab Runner system service] ***
null_resource.playbook: Still creating... [19m1s elapsed]
null_resource.playbook (local-exec): changed: [runner.korotkovdmitry.ru]

null_resource.playbook (local-exec): TASK [gitlab-runner : Force systemd to reread configs] *************************
null_resource.playbook (local-exec): ok: [runner.korotkovdmitry.ru]

null_resource.playbook (local-exec): TASK [gitlab-runner : (RedHat) Get Gitlab repository installation script] ******
null_resource.playbook (local-exec): skipping: [runner.korotkovdmitry.ru]

null_resource.playbook (local-exec): TASK [gitlab-runner : (RedHat) Install Gitlab repository] **********************
null_resource.playbook (local-exec): skipping: [runner.korotkovdmitry.ru]

null_resource.playbook (local-exec): TASK [gitlab-runner : (RedHat) Update gitlab_runner_package_name] **************
null_resource.playbook (local-exec): skipping: [runner.korotkovdmitry.ru]

null_resource.playbook (local-exec): TASK [gitlab-runner : (RedHat) Set gitlab_runner_package_name] *****************
null_resource.playbook (local-exec): skipping: [runner.korotkovdmitry.ru]

null_resource.playbook (local-exec): TASK [gitlab-runner : (RedHat) Install GitLab Runner] **************************
null_resource.playbook (local-exec): skipping: [runner.korotkovdmitry.ru]

null_resource.playbook (local-exec): TASK [gitlab-runner : Ensure /etc/systemd/system/gitlab-runner.service.d/ exists] ***
null_resource.playbook (local-exec): skipping: [runner.korotkovdmitry.ru]

null_resource.playbook (local-exec): TASK [gitlab-runner : Add reload command to GitLab Runner system service] ******
null_resource.playbook (local-exec): skipping: [runner.korotkovdmitry.ru]

null_resource.playbook (local-exec): TASK [gitlab-runner : Configure graceful stop for GitLab Runner system service] ***
null_resource.playbook (local-exec): skipping: [runner.korotkovdmitry.ru]

null_resource.playbook (local-exec): TASK [gitlab-runner : Force systemd to reread configs] *************************
null_resource.playbook (local-exec): skipping: [runner.korotkovdmitry.ru]

null_resource.playbook (local-exec): TASK [gitlab-runner : (MacOS) Check gitlab-runner executable exists] ***********
null_resource.playbook (local-exec): skipping: [runner.korotkovdmitry.ru]

null_resource.playbook (local-exec): TASK [gitlab-runner : (MacOS) Set fact -> gitlab_runner_exists] ****************
null_resource.playbook (local-exec): skipping: [runner.korotkovdmitry.ru]

null_resource.playbook (local-exec): TASK [gitlab-runner : (MacOS) Get existing version] ****************************
null_resource.playbook (local-exec): skipping: [runner.korotkovdmitry.ru]

null_resource.playbook (local-exec): TASK [gitlab-runner : (MacOS) Set fact -> gitlab_runner_existing_version] ******
null_resource.playbook (local-exec): skipping: [runner.korotkovdmitry.ru]

null_resource.playbook (local-exec): TASK [gitlab-runner : (MacOS) Precreate gitlab-runner log directory] ***********
null_resource.playbook (local-exec): skipping: [runner.korotkovdmitry.ru]

null_resource.playbook (local-exec): TASK [gitlab-runner : (MacOS) Download GitLab Runner] **************************
null_resource.playbook (local-exec): skipping: [runner.korotkovdmitry.ru]

null_resource.playbook (local-exec): TASK [gitlab-runner : (MacOS) Setting Permissions for gitlab-runner executable] ***
null_resource.playbook (local-exec): skipping: [runner.korotkovdmitry.ru]

null_resource.playbook (local-exec): TASK [gitlab-runner : (MacOS) Install GitLab Runner] ***************************
null_resource.playbook (local-exec): skipping: [runner.korotkovdmitry.ru]

null_resource.playbook (local-exec): TASK [gitlab-runner : (MacOS) Start GitLab Runner] *****************************
null_resource.playbook (local-exec): skipping: [runner.korotkovdmitry.ru]

null_resource.playbook (local-exec): TASK [gitlab-runner : (MacOS) Stop GitLab Runner] ******************************
null_resource.playbook (local-exec): skipping: [runner.korotkovdmitry.ru]

null_resource.playbook (local-exec): TASK [gitlab-runner : (MacOS) Download GitLab Runner] **************************
null_resource.playbook (local-exec): skipping: [runner.korotkovdmitry.ru]

null_resource.playbook (local-exec): TASK [gitlab-runner : (MacOS) Setting Permissions for gitlab-runner executable] ***
null_resource.playbook (local-exec): skipping: [runner.korotkovdmitry.ru]

null_resource.playbook (local-exec): TASK [gitlab-runner : (MacOS) Start GitLab Runner] *****************************
null_resource.playbook (local-exec): skipping: [runner.korotkovdmitry.ru]

null_resource.playbook (local-exec): TASK [gitlab-runner : (Arch) Set gitlab_runner_package_name] *******************
null_resource.playbook (local-exec): skipping: [runner.korotkovdmitry.ru]

null_resource.playbook (local-exec): TASK [gitlab-runner : (Arch) Install GitLab Runner] ****************************
null_resource.playbook (local-exec): skipping: [runner.korotkovdmitry.ru]

null_resource.playbook (local-exec): TASK [gitlab-runner : Ensure /etc/systemd/system/gitlab-runner.service.d/ exists] ***
null_resource.playbook (local-exec): skipping: [runner.korotkovdmitry.ru]

null_resource.playbook (local-exec): TASK [gitlab-runner : Add reload command to GitLab Runner system service] ******
null_resource.playbook (local-exec): skipping: [runner.korotkovdmitry.ru]

null_resource.playbook (local-exec): TASK [gitlab-runner : Configure graceful stop for GitLab Runner system service] ***
null_resource.playbook (local-exec): skipping: [runner.korotkovdmitry.ru]

null_resource.playbook (local-exec): TASK [gitlab-runner : Force systemd to reread configs] *************************
null_resource.playbook (local-exec): skipping: [runner.korotkovdmitry.ru]

null_resource.playbook (local-exec): TASK [gitlab-runner : (Unix) List configured runners] **************************
null_resource.playbook (local-exec): ok: [runner.korotkovdmitry.ru]

null_resource.playbook (local-exec): TASK [gitlab-runner : (Unix) Check runner is registered] ***********************
null_resource.playbook (local-exec): ok: [runner.korotkovdmitry.ru]

null_resource.playbook (local-exec): TASK [gitlab-runner : (Unix) Register GitLab Runner] ***************************
null_resource.playbook (local-exec): included: /vagrant/ansible/roles/gitlab-runner/tasks/register-runner.yml for runner.korotkovdmitry.ru => (item={'name': 'runner', 'state': 'present', 'executor': 'shell', 'output_limit': 4096, 'concurrent_specific': '0', 'docker_image': '', 'tags': [], 'run_untagged': True, 'protected': False, 'docker_privileged': False, 'locked': 'false', 'docker_network_mode': 'bridge', 'env_vars': []})

null_resource.playbook (local-exec): TASK [gitlab-runner : remove config.toml file] *********************************
null_resource.playbook (local-exec): skipping: [runner.korotkovdmitry.ru]

null_resource.playbook (local-exec): TASK [gitlab-runner : Create .gitlab-runner dir] *******************************
null_resource.playbook (local-exec): skipping: [runner.korotkovdmitry.ru]

null_resource.playbook (local-exec): TASK [gitlab-runner : Ensure config.toml exists] *******************************
null_resource.playbook (local-exec): skipping: [runner.korotkovdmitry.ru]

null_resource.playbook (local-exec): TASK [gitlab-runner : Construct the runner command without secrets] ************
null_resource.playbook (local-exec): ok: [runner.korotkovdmitry.ru]

null_resource.playbook (local-exec): TASK [gitlab-runner : Register runner to GitLab] *******************************
null_resource.playbook: Still creating... [19m11s elapsed]
null_resource.playbook (local-exec): changed: [runner.korotkovdmitry.ru]

null_resource.playbook (local-exec): TASK [gitlab-runner : Create .gitlab-runner dir] *******************************
null_resource.playbook (local-exec): ok: [runner.korotkovdmitry.ru]

null_resource.playbook (local-exec): TASK [gitlab-runner : Ensure config.toml exists] *******************************
null_resource.playbook (local-exec): ok: [runner.korotkovdmitry.ru]

null_resource.playbook (local-exec): TASK [gitlab-runner : Set concurrent option] ***********************************
null_resource.playbook (local-exec): changed: [runner.korotkovdmitry.ru]

null_resource.playbook (local-exec): TASK [gitlab-runner : Add listen_address to config] ****************************
null_resource.playbook (local-exec): skipping: [runner.korotkovdmitry.ru]

null_resource.playbook (local-exec): TASK [gitlab-runner : Add log_format to config] ********************************
null_resource.playbook (local-exec): skipping: [runner.korotkovdmitry.ru]

null_resource.playbook (local-exec): TASK [gitlab-runner : Add sentry dsn to config] ********************************
null_resource.playbook (local-exec): skipping: [runner.korotkovdmitry.ru]

null_resource.playbook (local-exec): TASK [gitlab-runner : Add session server listen_address to config] *************
null_resource.playbook: Still creating... [19m21s elapsed]
null_resource.playbook (local-exec): ok: [runner.korotkovdmitry.ru]

null_resource.playbook (local-exec): TASK [gitlab-runner : Add session server advertise_address to config] **********
null_resource.playbook (local-exec): ok: [runner.korotkovdmitry.ru]

null_resource.playbook (local-exec): TASK [gitlab-runner : Add session server session_timeout to config] ************
null_resource.playbook (local-exec): ok: [runner.korotkovdmitry.ru]

null_resource.playbook (local-exec): TASK [gitlab-runner : Get existing config.toml] ********************************
null_resource.playbook (local-exec): ok: [runner.korotkovdmitry.ru]

null_resource.playbook (local-exec): TASK [gitlab-runner : Get pre-existing runner configs] *************************
null_resource.playbook (local-exec): ok: [runner.korotkovdmitry.ru]

null_resource.playbook (local-exec): TASK [gitlab-runner : Create temporary directory] ******************************
null_resource.playbook: Still creating... [19m31s elapsed]
null_resource.playbook (local-exec): ok: [runner.korotkovdmitry.ru]

null_resource.playbook (local-exec): TASK [gitlab-runner : Write config section for each runner] ********************
null_resource.playbook (local-exec): included: /vagrant/ansible/roles/gitlab-runner/tasks/config-runner.yml for runner.korotkovdmitry.ru => (item=concurrent = 4
null_resource.playbook (local-exec): check_interval = 0
null_resource.playbook (local-exec):
null_resource.playbook (local-exec): [session_server]
null_resource.playbook (local-exec):   session_timeout = 1800
null_resource.playbook (local-exec):
null_resource.playbook (local-exec): )
null_resource.playbook (local-exec): included: /vagrant/ansible/roles/gitlab-runner/tasks/config-runner.yml for runner.korotkovdmitry.ru => (item=  name = "runner"
null_resource.playbook (local-exec):   output_limit = 4096
null_resource.playbook (local-exec):   url = "http://gitlab.korotkovdmitry.ru"
null_resource.playbook (local-exec):   token = "HBZHVgYnKWXn6aA4imKP"
null_resource.playbook (local-exec):   executor = "shell"
null_resource.playbook (local-exec):   [runners.custom_build_dir]
null_resource.playbook (local-exec):   [runners.cache]
null_resource.playbook (local-exec):     [runners.cache.s3]
null_resource.playbook (local-exec):     [runners.cache.gcs]
null_resource.playbook (local-exec):     [runners.cache.azure]
null_resource.playbook (local-exec): )

null_resource.playbook (local-exec): TASK [gitlab-runner : conf[1/2]: Create temporary file] ************************
null_resource.playbook (local-exec): ok: [runner.korotkovdmitry.ru]

null_resource.playbook (local-exec): TASK [gitlab-runner : conf[1/2]: Isolate runner configuration] *****************
null_resource.playbook (local-exec): ok: [runner.korotkovdmitry.ru]

null_resource.playbook (local-exec): TASK [gitlab-runner : include_tasks] *******************************************
null_resource.playbook (local-exec): skipping: [runner.korotkovdmitry.ru] => (item={'name': 'runner', 'state': 'present', 'executor': 'shell', 'output_limit': 4096, 'concurrent_specific': '0', 'docker_image': '', 'tags': [], 'run_untagged': True, 'protected': False, 'docker_privileged': False, 'locked': 'false', 'docker_network_mode': 'bridge', 'env_vars': []})

null_resource.playbook (local-exec): TASK [gitlab-runner : conf[1/2]: Remove runner config] *************************
null_resource.playbook (local-exec): skipping: [runner.korotkovdmitry.ru] => (item={'name': 'runner', 'state': 'present', 'executor': 'shell', 'output_limit': 4096, 'concurrent_specific': '0', 'docker_image': '', 'tags': [], 'run_untagged': True, 'protected': False, 'docker_privileged': False, 'locked': 'false', 'docker_network_mode': 'bridge', 'env_vars': []})

null_resource.playbook (local-exec): TASK [gitlab-runner : conf[2/2]: Create temporary file] ************************
null_resource.playbook (local-exec): ok: [runner.korotkovdmitry.ru]

null_resource.playbook (local-exec): TASK [gitlab-runner : conf[2/2]: Isolate runner configuration] *****************
null_resource.playbook: Still creating... [19m41s elapsed]
null_resource.playbook (local-exec): ok: [runner.korotkovdmitry.ru]

null_resource.playbook (local-exec): TASK [gitlab-runner : include_tasks] *******************************************
null_resource.playbook (local-exec): included: /vagrant/ansible/roles/gitlab-runner/tasks/update-config-runner.yml for runner.korotkovdmitry.ru => (item={'name': 'runner', 'state': 'present', 'executor': 'shell', 'output_limit': 4096, 'concurrent_specific': '0', 'docker_image': '', 'tags': [], 'run_untagged': True, 'protected': False, 'docker_privileged': False, 'locked': 'false', 'docker_network_mode': 'bridge', 'env_vars': []})

null_resource.playbook (local-exec): TASK [gitlab-runner : conf[2/2]: runner[1/1]: Set concurrent limit option] *****
null_resource.playbook (local-exec): changed: [runner.korotkovdmitry.ru]

null_resource.playbook (local-exec): TASK [gitlab-runner : conf[2/2]: runner[1/1]: Set coordinator URL] *************
null_resource.playbook (local-exec): ok: [runner.korotkovdmitry.ru]

null_resource.playbook (local-exec): TASK [gitlab-runner : conf[2/2]: runner[1/1]: Set clone URL] *******************
null_resource.playbook (local-exec): skipping: [runner.korotkovdmitry.ru]

null_resource.playbook (local-exec): TASK [gitlab-runner : conf[2/2]: runner[1/1]: Set environment option] **********
null_resource.playbook: Still creating... [19m51s elapsed]
null_resource.playbook (local-exec): changed: [runner.korotkovdmitry.ru]

null_resource.playbook (local-exec): TASK [gitlab-runner : conf[2/2]: runner[1/1]: Set pre_clone_script] ************
null_resource.playbook (local-exec): skipping: [runner.korotkovdmitry.ru]

null_resource.playbook (local-exec): TASK [gitlab-runner : conf[2/2]: runner[1/1]: Set pre_build_script] ************
null_resource.playbook (local-exec): skipping: [runner.korotkovdmitry.ru]

null_resource.playbook (local-exec): TASK [gitlab-runner : conf[2/2]: runner[1/1]: Set tls_ca_file] *****************
null_resource.playbook (local-exec): skipping: [runner.korotkovdmitry.ru]

null_resource.playbook (local-exec): TASK [gitlab-runner : conf[2/2]: runner[1/1]: Set post_build_script] ***********
null_resource.playbook (local-exec): skipping: [runner.korotkovdmitry.ru]

null_resource.playbook (local-exec): TASK [gitlab-runner : conf[2/2]: runner[1/1]: Set runner executor option] ******
null_resource.playbook (local-exec): ok: [runner.korotkovdmitry.ru]

null_resource.playbook (local-exec): TASK [gitlab-runner : conf[2/2]: runner[1/1]: Set runner shell option] *********
null_resource.playbook (local-exec): ok: [runner.korotkovdmitry.ru]

null_resource.playbook (local-exec): TASK [gitlab-runner : conf[2/2]: runner[1/1]: Set runner executor section] *****
null_resource.playbook (local-exec): ok: [runner.korotkovdmitry.ru]

null_resource.playbook (local-exec): TASK [gitlab-runner : conf[2/2]: runner[1/1]: Set output_limit option] *********
null_resource.playbook: Still creating... [20m1s elapsed]
null_resource.playbook (local-exec): ok: [runner.korotkovdmitry.ru]

null_resource.playbook (local-exec): TASK [gitlab-runner : conf[2/2]: runner[1/1]: Set runner docker image option] ***
null_resource.playbook (local-exec): changed: [runner.korotkovdmitry.ru]

null_resource.playbook (local-exec): TASK [gitlab-runner : conf[2/2]: runner[1/1]: Set docker helper image option] ***
null_resource.playbook (local-exec): ok: [runner.korotkovdmitry.ru]

null_resource.playbook (local-exec): TASK [gitlab-runner : conf[2/2]: runner[1/1]: Set docker privileged option] ****
null_resource.playbook (local-exec): changed: [runner.korotkovdmitry.ru]

null_resource.playbook (local-exec): TASK [gitlab-runner : conf[2/2]: runner[1/1]: Set docker wait_for_services_timeout option] ***
null_resource.playbook (local-exec): ok: [runner.korotkovdmitry.ru]

null_resource.playbook (local-exec): TASK [gitlab-runner : conf[2/2]: runner[1/1]: Set docker tlsverify option] *****
null_resource.playbook: Still creating... [20m11s elapsed]
null_resource.playbook (local-exec): ok: [runner.korotkovdmitry.ru]

null_resource.playbook (local-exec): TASK [gitlab-runner : conf[2/2]: runner[1/1]: Set docker shm_size option] ******
null_resource.playbook (local-exec): ok: [runner.korotkovdmitry.ru]

null_resource.playbook (local-exec): TASK [gitlab-runner : conf[2/2]: runner[1/1]: Set docker disable_cache option] ***
null_resource.playbook (local-exec): ok: [runner.korotkovdmitry.ru]

null_resource.playbook (local-exec): TASK [gitlab-runner : conf[2/2]: runner[1/1]: Set docker DNS option] ***********
null_resource.playbook (local-exec): ok: [runner.korotkovdmitry.ru]

null_resource.playbook (local-exec): TASK [gitlab-runner : conf[2/2]: runner[1/1]: Set docker DNS search option] ****
null_resource.playbook: Still creating... [20m21s elapsed]
null_resource.playbook (local-exec): ok: [runner.korotkovdmitry.ru]

null_resource.playbook (local-exec): TASK [gitlab-runner : conf[2/2]: runner[1/1]: Set docker pull_policy option] ***
null_resource.playbook (local-exec): ok: [runner.korotkovdmitry.ru]

null_resource.playbook (local-exec): TASK [gitlab-runner : conf[2/2]: runner[1/1]: Set docker volumes option] *******
null_resource.playbook (local-exec): ok: [runner.korotkovdmitry.ru]

null_resource.playbook (local-exec): TASK [gitlab-runner : conf[2/2]: runner[1/1]: Set docker devices option] *******
null_resource.playbook (local-exec): ok: [runner.korotkovdmitry.ru]

null_resource.playbook (local-exec): TASK [gitlab-runner : conf[2/2]: runner[1/1]: Set runner docker network option] ***
null_resource.playbook (local-exec): changed: [runner.korotkovdmitry.ru]

null_resource.playbook (local-exec): TASK [gitlab-runner : conf[2/2]: runner[1/1]: Set custom_build_dir section] ****
null_resource.playbook: Still creating... [20m31s elapsed]
null_resource.playbook (local-exec): changed: [runner.korotkovdmitry.ru]

null_resource.playbook (local-exec): TASK [gitlab-runner : conf[2/2]: runner[1/1]: Set docker custom_build_dir-enabled option] ***
null_resource.playbook (local-exec): ok: [runner.korotkovdmitry.ru]

null_resource.playbook (local-exec): TASK [gitlab-runner : conf[2/2]: runner[1/1]: Set cache section] ***************
null_resource.playbook (local-exec): ok: [runner.korotkovdmitry.ru]

null_resource.playbook (local-exec): TASK [gitlab-runner : conf[2/2]: runner[1/1]: Set cache s3 section] ************
null_resource.playbook (local-exec): changed: [runner.korotkovdmitry.ru]

null_resource.playbook (local-exec): TASK [gitlab-runner : conf[2/2]: runner[1/1]: Set cache gcs section] ***********
null_resource.playbook: Still creating... [20m41s elapsed]
null_resource.playbook (local-exec): changed: [runner.korotkovdmitry.ru]

null_resource.playbook (local-exec): TASK [gitlab-runner : conf[2/2]: runner[1/1]: Set cache azure section] *********
null_resource.playbook (local-exec): changed: [runner.korotkovdmitry.ru]

null_resource.playbook (local-exec): TASK [gitlab-runner : conf[2/2]: runner[1/1]: Set cache type option] ***********
null_resource.playbook (local-exec): ok: [runner.korotkovdmitry.ru]

null_resource.playbook (local-exec): TASK [gitlab-runner : conf[2/2]: runner[1/1]: Set cache path option] ***********
null_resource.playbook (local-exec): ok: [runner.korotkovdmitry.ru]

null_resource.playbook (local-exec): TASK [gitlab-runner : conf[2/2]: runner[1/1]: Set cache shared option] *********
null_resource.playbook (local-exec): ok: [runner.korotkovdmitry.ru]

null_resource.playbook (local-exec): TASK [gitlab-runner : conf[2/2]: runner[1/1]: Set cache s3 server addresss] ****
null_resource.playbook: Still creating... [20m51s elapsed]
null_resource.playbook (local-exec): ok: [runner.korotkovdmitry.ru]

null_resource.playbook (local-exec): TASK [gitlab-runner : conf[2/2]: runner[1/1]: Set cache s3 access key] *********
null_resource.playbook (local-exec): ok: [runner.korotkovdmitry.ru]

null_resource.playbook (local-exec): TASK [gitlab-runner : conf[2/2]: runner[1/1]: Set cache s3 secret key] *********
null_resource.playbook (local-exec): ok: [runner.korotkovdmitry.ru]

null_resource.playbook (local-exec): TASK [gitlab-runner : conf[2/2]: runner[1/1]: Set cache s3 bucket name option] ***
null_resource.playbook (local-exec): skipping: [runner.korotkovdmitry.ru]

null_resource.playbook (local-exec): TASK [gitlab-runner : conf[2/2]: runner[1/1]: Set cache s3 bucket location option] ***
null_resource.playbook (local-exec): ok: [runner.korotkovdmitry.ru]

null_resource.playbook (local-exec): TASK [gitlab-runner : conf[2/2]: runner[1/1]: Set cache s3 insecure option] ****
null_resource.playbook: Still creating... [21m1s elapsed]
null_resource.playbook (local-exec): ok: [runner.korotkovdmitry.ru]

null_resource.playbook (local-exec): TASK [gitlab-runner : conf[2/2]: runner[1/1]: Set cache gcs bucket name] *******
null_resource.playbook (local-exec): skipping: [runner.korotkovdmitry.ru]

null_resource.playbook (local-exec): TASK [gitlab-runner : conf[2/2]: runner[1/1]: Set cache gcs credentials file] ***
null_resource.playbook (local-exec): ok: [runner.korotkovdmitry.ru]

null_resource.playbook (local-exec): TASK [gitlab-runner : conf[2/2]: runner[1/1]: Set cache gcs access id] *********
null_resource.playbook (local-exec): ok: [runner.korotkovdmitry.ru]

null_resource.playbook (local-exec): TASK [gitlab-runner : conf[2/2]: runner[1/1]: Set cache gcs private key] *******
null_resource.playbook (local-exec): ok: [runner.korotkovdmitry.ru]

null_resource.playbook (local-exec): TASK [gitlab-runner : conf[2/2]: runner[1/1]: Set cache azure account name] ****
null_resource.playbook (local-exec): ok: [runner.korotkovdmitry.ru]

null_resource.playbook (local-exec): TASK [gitlab-runner : conf[2/2]: runner[1/1]: Set cache azure account key] *****
null_resource.playbook: Still creating... [21m11s elapsed]
null_resource.playbook (local-exec): ok: [runner.korotkovdmitry.ru]

null_resource.playbook (local-exec): TASK [gitlab-runner : conf[2/2]: runner[1/1]: Set cache azure container name] ***
null_resource.playbook (local-exec): ok: [runner.korotkovdmitry.ru]

null_resource.playbook (local-exec): TASK [gitlab-runner : conf[2/2]: runner[1/1]: Set cache azure storage domain] ***
null_resource.playbook (local-exec): ok: [runner.korotkovdmitry.ru]

null_resource.playbook (local-exec): TASK [gitlab-runner : conf[2/2]: runner[1/1]: Set ssh user option] *************
null_resource.playbook (local-exec): ok: [runner.korotkovdmitry.ru]

null_resource.playbook (local-exec): TASK [gitlab-runner : conf[2/2]: runner[1/1]: Set ssh host option] *************
null_resource.playbook: Still creating... [21m21s elapsed]
null_resource.playbook (local-exec): ok: [runner.korotkovdmitry.ru]

null_resource.playbook (local-exec): TASK [gitlab-runner : conf[2/2]: runner[1/1]: Set ssh port option] *************
null_resource.playbook (local-exec): ok: [runner.korotkovdmitry.ru]

null_resource.playbook (local-exec): TASK [gitlab-runner : conf[2/2]: runner[1/1]: Set ssh password option] *********
null_resource.playbook (local-exec): ok: [runner.korotkovdmitry.ru]

null_resource.playbook (local-exec): TASK [gitlab-runner : conf[2/2]: runner[1/1]: Set ssh identity file option] ****
null_resource.playbook (local-exec): ok: [runner.korotkovdmitry.ru]

null_resource.playbook (local-exec): TASK [gitlab-runner : conf[2/2]: runner[1/1]: Set virtualbox base name option] ***
null_resource.playbook (local-exec): skipping: [runner.korotkovdmitry.ru]

null_resource.playbook (local-exec): TASK [gitlab-runner : conf[2/2]: runner[1/1]: Set virtualbox base snapshot option] ***
null_resource.playbook (local-exec): skipping: [runner.korotkovdmitry.ru]

null_resource.playbook (local-exec): TASK [gitlab-runner : conf[2/2]: runner[1/1]: Set virtualbox base folder option] ***
null_resource.playbook (local-exec): skipping: [runner.korotkovdmitry.ru]

null_resource.playbook (local-exec): TASK [gitlab-runner : conf[2/2]: runner[1/1]: Set virtualbox disable snapshots option] ***
null_resource.playbook (local-exec): skipping: [runner.korotkovdmitry.ru]

null_resource.playbook (local-exec): TASK [gitlab-runner : conf[2/2]: runner[1/1]: Set builds dir file option] ******
null_resource.playbook (local-exec): ok: [runner.korotkovdmitry.ru]
null_resource.playbook: Still creating... [21m31s elapsed]

null_resource.playbook (local-exec): TASK [gitlab-runner : conf[2/2]: runner[1/1]: Set cache dir file option] *******
null_resource.playbook (local-exec): ok: [runner.korotkovdmitry.ru]

null_resource.playbook (local-exec): TASK [gitlab-runner : conf[2/2]: runner[1/1]: Ensure directory permissions] ****
null_resource.playbook (local-exec): skipping: [runner.korotkovdmitry.ru] => (item=) 
null_resource.playbook (local-exec): skipping: [runner.korotkovdmitry.ru] => (item=) 

null_resource.playbook (local-exec): TASK [gitlab-runner : conf[2/2]: runner[1/1]: Ensure directory access test] ****
null_resource.playbook (local-exec): skipping: [runner.korotkovdmitry.ru] => (item=) 
null_resource.playbook (local-exec): skipping: [runner.korotkovdmitry.ru] => (item=) 

null_resource.playbook (local-exec): TASK [gitlab-runner : conf[2/2]: runner[1/1]: Ensure directory access fail on error] ***
null_resource.playbook (local-exec): skipping: [runner.korotkovdmitry.ru] => (item={'changed': False, 'skipped': True, 'skip_reason': 'Conditional result was False', 'item': '', 'ansible_loop_var': 'item'})
null_resource.playbook (local-exec): skipping: [runner.korotkovdmitry.ru] => (item={'changed': False, 'skipped': True, 'skip_reason': 'Conditional result was False', 'item': '', 'ansible_loop_var': 'item'})

null_resource.playbook (local-exec): TASK [gitlab-runner : include_tasks] *******************************************
null_resource.playbook (local-exec): skipping: [runner.korotkovdmitry.ru]

null_resource.playbook (local-exec): TASK [gitlab-runner : conf[2/2]: Remove runner config] *************************
null_resource.playbook (local-exec): skipping: [runner.korotkovdmitry.ru] => (item={'name': 'runner', 'state': 'present', 'executor': 'shell', 'output_limit': 4096, 'concurrent_specific': '0', 'docker_image': '', 'tags': [], 'run_untagged': True, 'protected': False, 'docker_privileged': False, 'locked': 'false', 'docker_network_mode': 'bridge', 'env_vars': []})

null_resource.playbook (local-exec): TASK [gitlab-runner : Assemble new config.toml] ********************************
null_resource.playbook (local-exec): changed: [runner.korotkovdmitry.ru]

null_resource.playbook (local-exec): TASK [gitlab-runner : (Windows) Check gitlab-runner executable exists] *********
null_resource.playbook (local-exec): skipping: [runner.korotkovdmitry.ru]

null_resource.playbook (local-exec): TASK [gitlab-runner : (Windows) Set fact -> gitlab_runner_exists] **************
null_resource.playbook (local-exec): skipping: [runner.korotkovdmitry.ru]

null_resource.playbook (local-exec): TASK [gitlab-runner : (Windows) Get existing version] **************************
null_resource.playbook (local-exec): skipping: [runner.korotkovdmitry.ru]

null_resource.playbook (local-exec): TASK [gitlab-runner : (Windows) Set fact -> gitlab_runner_existing_version] ****
null_resource.playbook (local-exec): skipping: [runner.korotkovdmitry.ru]

null_resource.playbook (local-exec): TASK [gitlab-runner : (Windows) Ensure install directory exists] ***************
null_resource.playbook (local-exec): skipping: [runner.korotkovdmitry.ru]

null_resource.playbook (local-exec): TASK [gitlab-runner : (Windows) Download GitLab Runner] ************************
null_resource.playbook (local-exec): skipping: [runner.korotkovdmitry.ru]

null_resource.playbook (local-exec): TASK [gitlab-runner : (Windows) Install GitLab Runner] *************************
null_resource.playbook (local-exec): skipping: [runner.korotkovdmitry.ru]

null_resource.playbook (local-exec): TASK [gitlab-runner : (Windows) Install GitLab Runner] *************************
null_resource.playbook (local-exec): skipping: [runner.korotkovdmitry.ru]

null_resource.playbook (local-exec): TASK [gitlab-runner : (Windows) Make sure runner is stopped] *******************
null_resource.playbook (local-exec): skipping: [runner.korotkovdmitry.ru]

null_resource.playbook (local-exec): TASK [gitlab-runner : (Windows) Download GitLab Runner] ************************
null_resource.playbook (local-exec): skipping: [runner.korotkovdmitry.ru]

null_resource.playbook (local-exec): TASK [gitlab-runner : (Windows) List configured runners] ***********************
null_resource.playbook (local-exec): skipping: [runner.korotkovdmitry.ru]

null_resource.playbook (local-exec): TASK [gitlab-runner : (Windows) Check runner is registered] ********************
null_resource.playbook (local-exec): skipping: [runner.korotkovdmitry.ru]

null_resource.playbook (local-exec): TASK [gitlab-runner : (Windows) Register GitLab Runner] ************************
null_resource.playbook (local-exec): skipping: [runner.korotkovdmitry.ru] => (item={'name': 'runner', 'state': 'present', 'executor': 'shell', 'output_limit': 4096, 'concurrent_specific': '0', 'docker_image': '', 'tags': [], 'run_untagged': True, 'protected': False, 'docker_privileged': False, 'locked': 'false', 'docker_network_mode': 'bridge', 'env_vars': []})

null_resource.playbook (local-exec): TASK [gitlab-runner : (Windows) Create .gitlab-runner dir] *********************
null_resource.playbook (local-exec): skipping: [runner.korotkovdmitry.ru]

null_resource.playbook (local-exec): TASK [gitlab-runner : (Windows) Ensure config.toml exists] *********************
null_resource.playbook (local-exec): skipping: [runner.korotkovdmitry.ru]

null_resource.playbook (local-exec): TASK [gitlab-runner : (Windows) Set concurrent option] *************************
null_resource.playbook (local-exec): skipping: [runner.korotkovdmitry.ru]

null_resource.playbook (local-exec): TASK [gitlab-runner : (Windows) Add listen_address to config] ******************
null_resource.playbook (local-exec): skipping: [runner.korotkovdmitry.ru]

null_resource.playbook (local-exec): TASK [gitlab-runner : (Windows) Add sentry dsn to config] **********************
null_resource.playbook (local-exec): skipping: [runner.korotkovdmitry.ru]

null_resource.playbook (local-exec): TASK [gitlab-runner : (Windows) Add session server listen_address to config] ***
null_resource.playbook (local-exec): skipping: [runner.korotkovdmitry.ru]

null_resource.playbook (local-exec): TASK [gitlab-runner : (Windows) Add session server advertise_address to config] ***
null_resource.playbook (local-exec): skipping: [runner.korotkovdmitry.ru]

null_resource.playbook (local-exec): TASK [gitlab-runner : (Windows) Add session server session_timeout to config] ***
null_resource.playbook (local-exec): skipping: [runner.korotkovdmitry.ru]

null_resource.playbook (local-exec): TASK [gitlab-runner : (Windows) Get existing config.toml] **********************
null_resource.playbook (local-exec): skipping: [runner.korotkovdmitry.ru]

null_resource.playbook (local-exec): TASK [gitlab-runner : (Windows) Get pre-existing global config] ****************
null_resource.playbook (local-exec): skipping: [runner.korotkovdmitry.ru]

null_resource.playbook (local-exec): TASK [gitlab-runner : (Windows) Get pre-existing runner configs] ***************
null_resource.playbook (local-exec): skipping: [runner.korotkovdmitry.ru]

null_resource.playbook (local-exec): TASK [gitlab-runner : (Windows) Create temporary directory] ********************
null_resource.playbook (local-exec): skipping: [runner.korotkovdmitry.ru]

null_resource.playbook (local-exec): TASK [gitlab-runner : (Windows) Write config section for each runner] **********
null_resource.playbook (local-exec): skipping: [runner.korotkovdmitry.ru] => (item=concurrent = 4
null_resource.playbook (local-exec): check_interval = 0
null_resource.playbook (local-exec):
null_resource.playbook (local-exec): [session_server]
null_resource.playbook (local-exec):   session_timeout = 1800
null_resource.playbook (local-exec):
null_resource.playbook (local-exec): ) 
null_resource.playbook (local-exec): skipping: [runner.korotkovdmitry.ru] => (item=  name = "runner"
null_resource.playbook (local-exec):   output_limit = 4096
null_resource.playbook (local-exec):   url = "http://gitlab.korotkovdmitry.ru"
null_resource.playbook (local-exec):   token = "HBZHVgYnKWXn6aA4imKP"
null_resource.playbook (local-exec):   executor = "shell"
null_resource.playbook (local-exec):   [runners.custom_build_dir]
null_resource.playbook (local-exec):   [runners.cache]
null_resource.playbook (local-exec):     [runners.cache.s3]
null_resource.playbook (local-exec):     [runners.cache.gcs]
null_resource.playbook (local-exec):     [runners.cache.azure]
null_resource.playbook (local-exec): ) 

null_resource.playbook (local-exec): TASK [gitlab-runner : (Windows) Create temporary file config.toml] *************
null_resource.playbook (local-exec): skipping: [runner.korotkovdmitry.ru]

null_resource.playbook (local-exec): TASK [gitlab-runner : (Windows) Write global config to file] *******************
null_resource.playbook (local-exec): skipping: [runner.korotkovdmitry.ru]

null_resource.playbook (local-exec): TASK [gitlab-runner : (Windows) Create temporary file runners-config.toml] *****
null_resource.playbook (local-exec): skipping: [runner.korotkovdmitry.ru]

null_resource.playbook (local-exec): TASK [gitlab-runner : (Windows) Assemble runners files in config dir] **********
null_resource.playbook (local-exec): skipping: [runner.korotkovdmitry.ru]

null_resource.playbook (local-exec): TASK [gitlab-runner : (Windows) Assemble new config.toml] **********************
null_resource.playbook (local-exec): skipping: [runner.korotkovdmitry.ru]

null_resource.playbook (local-exec): TASK [gitlab-runner : (Windows) Verify config] *********************************
null_resource.playbook (local-exec): skipping: [runner.korotkovdmitry.ru]

null_resource.playbook (local-exec): TASK [gitlab-runner : (Windows) Start GitLab Runner] ***************************
null_resource.playbook (local-exec): skipping: [runner.korotkovdmitry.ru]

null_resource.playbook (local-exec): RUNNING HANDLER [gitlab-runner : restart_gitlab_runner] ************************
null_resource.playbook (local-exec): changed: [runner.korotkovdmitry.ru]

null_resource.playbook (local-exec): RUNNING HANDLER [gitlab-runner : restart_gitlab_runner_macos] ******************
null_resource.playbook (local-exec): skipping: [runner.korotkovdmitry.ru]
null_resource.playbook (local-exec): [WARNING]: Could not match supplied host pattern, ignoring: MySQL

null_resource.playbook (local-exec): PLAY [MySQL app gitlab runner monitoring] **************************************

null_resource.playbook (local-exec): TASK [Gathering Facts] *********************************************************
null_resource.playbook: Still creating... [21m41s elapsed]
null_resource.playbook (local-exec): ok: [runner.korotkovdmitry.ru]
null_resource.playbook (local-exec): ok: [app.korotkovdmitry.ru]
null_resource.playbook (local-exec): ok: [gitlab.korotkovdmitry.ru]
null_resource.playbook (local-exec): ok: [monitoring.korotkovdmitry.ru]

null_resource.playbook (local-exec): TASK [install_node_exporter : Assert usage of systemd as an init system] *******
null_resource.playbook (local-exec): ok: [app.korotkovdmitry.ru] => {
null_resource.playbook (local-exec):     "changed": false,
null_resource.playbook (local-exec):     "msg": "All assertions passed"
null_resource.playbook (local-exec): }
null_resource.playbook (local-exec): ok: [gitlab.korotkovdmitry.ru] => {
null_resource.playbook (local-exec):     "changed": false,
null_resource.playbook (local-exec):     "msg": "All assertions passed"
null_resource.playbook (local-exec): }
null_resource.playbook (local-exec): ok: [runner.korotkovdmitry.ru] => {
null_resource.playbook (local-exec):     "changed": false,
null_resource.playbook (local-exec):     "msg": "All assertions passed"
null_resource.playbook (local-exec): }
null_resource.playbook (local-exec): ok: [monitoring.korotkovdmitry.ru] => {
null_resource.playbook (local-exec):     "changed": false,
null_resource.playbook (local-exec):     "msg": "All assertions passed"
null_resource.playbook (local-exec): }

null_resource.playbook (local-exec): TASK [install_node_exporter : Get systemd version] *****************************
null_resource.playbook (local-exec): ok: [app.korotkovdmitry.ru]
null_resource.playbook (local-exec): ok: [monitoring.korotkovdmitry.ru]
null_resource.playbook (local-exec): ok: [runner.korotkovdmitry.ru]
null_resource.playbook (local-exec): ok: [gitlab.korotkovdmitry.ru]

null_resource.playbook (local-exec): TASK [install_node_exporter : Set systemd version fact] ************************
null_resource.playbook (local-exec): ok: [app.korotkovdmitry.ru]
null_resource.playbook (local-exec): ok: [monitoring.korotkovdmitry.ru]
null_resource.playbook (local-exec): ok: [gitlab.korotkovdmitry.ru]
null_resource.playbook (local-exec): ok: [runner.korotkovdmitry.ru]

null_resource.playbook (local-exec): TASK [install_node_exporter : Naive assertion of proper listen address] ********
null_resource.playbook (local-exec): ok: [app.korotkovdmitry.ru] => {
null_resource.playbook (local-exec):     "changed": false,
null_resource.playbook (local-exec):     "msg": "All assertions passed"
null_resource.playbook (local-exec): }
null_resource.playbook (local-exec): ok: [gitlab.korotkovdmitry.ru] => {
null_resource.playbook (local-exec):     "changed": false,
null_resource.playbook (local-exec):     "msg": "All assertions passed"
null_resource.playbook (local-exec): }
null_resource.playbook (local-exec): ok: [runner.korotkovdmitry.ru] => {
null_resource.playbook (local-exec):     "changed": false,
null_resource.playbook (local-exec):     "msg": "All assertions passed"
null_resource.playbook (local-exec): }
null_resource.playbook (local-exec): ok: [monitoring.korotkovdmitry.ru] => {
null_resource.playbook (local-exec):     "changed": false,
null_resource.playbook (local-exec):     "msg": "All assertions passed"
null_resource.playbook (local-exec): }

null_resource.playbook (local-exec): TASK [install_node_exporter : Assert collectors are not both disabled and enabled at the same time] ***

null_resource.playbook (local-exec): TASK [install_node_exporter : Assert that TLS key and cert path are set] *******
null_resource.playbook (local-exec): skipping: [app.korotkovdmitry.ru]
null_resource.playbook (local-exec): skipping: [gitlab.korotkovdmitry.ru]
null_resource.playbook (local-exec): skipping: [runner.korotkovdmitry.ru]
null_resource.playbook (local-exec): skipping: [monitoring.korotkovdmitry.ru]

null_resource.playbook (local-exec): TASK [install_node_exporter : Check existence of TLS cert file] ****************
null_resource.playbook (local-exec): skipping: [app.korotkovdmitry.ru]
null_resource.playbook (local-exec): skipping: [gitlab.korotkovdmitry.ru]
null_resource.playbook (local-exec): skipping: [runner.korotkovdmitry.ru]
null_resource.playbook (local-exec): skipping: [monitoring.korotkovdmitry.ru]

null_resource.playbook (local-exec): TASK [install_node_exporter : Check existence of TLS key file] *****************
null_resource.playbook (local-exec): skipping: [app.korotkovdmitry.ru]
null_resource.playbook (local-exec): skipping: [gitlab.korotkovdmitry.ru]
null_resource.playbook (local-exec): skipping: [runner.korotkovdmitry.ru]
null_resource.playbook (local-exec): skipping: [monitoring.korotkovdmitry.ru]

null_resource.playbook (local-exec): TASK [install_node_exporter : Assert that TLS key and cert are present] ********
null_resource.playbook (local-exec): skipping: [app.korotkovdmitry.ru]
null_resource.playbook (local-exec): skipping: [gitlab.korotkovdmitry.ru]
null_resource.playbook (local-exec): skipping: [runner.korotkovdmitry.ru]
null_resource.playbook (local-exec): skipping: [monitoring.korotkovdmitry.ru]

null_resource.playbook (local-exec): TASK [install_node_exporter : Check if node_exporter is installed] *************
null_resource.playbook: Still creating... [21m51s elapsed]
null_resource.playbook (local-exec): ok: [runner.korotkovdmitry.ru]
null_resource.playbook (local-exec): ok: [monitoring.korotkovdmitry.ru]
null_resource.playbook (local-exec): ok: [app.korotkovdmitry.ru]
null_resource.playbook (local-exec): ok: [gitlab.korotkovdmitry.ru]

null_resource.playbook (local-exec): TASK [install_node_exporter : Gather currently installed node_exporter version (if any)] ***
null_resource.playbook (local-exec): skipping: [app.korotkovdmitry.ru]
null_resource.playbook (local-exec): skipping: [gitlab.korotkovdmitry.ru]
null_resource.playbook (local-exec): skipping: [runner.korotkovdmitry.ru]
null_resource.playbook (local-exec): skipping: [monitoring.korotkovdmitry.ru]

null_resource.playbook (local-exec): TASK [install_node_exporter : Get latest release] ******************************
null_resource.playbook (local-exec): skipping: [app.korotkovdmitry.ru]

null_resource.playbook (local-exec): TASK [install_node_exporter : Set node_exporter version to {{ _latest_release.json.tag_name[1:] }}] ***
null_resource.playbook (local-exec): skipping: [app.korotkovdmitry.ru]

null_resource.playbook (local-exec): TASK [install_node_exporter : Get checksum list from github] *******************
null_resource.playbook (local-exec): ok: [app.korotkovdmitry.ru -> localhost]

null_resource.playbook (local-exec): TASK [install_node_exporter : Get checksum for amd64 architecture] *************
null_resource.playbook (local-exec): skipping: [app.korotkovdmitry.ru] => (item=3919266f1dbad5f7e5ce7b4207057fc253a8322f570607cc0f3e73f4a53338e3  node_exporter-1.1.2.darwin-amd64.tar.gz)
null_resource.playbook (local-exec): skipping: [app.korotkovdmitry.ru] => (item=5b0195e203dedd3a8973cd1894a55097554a4af6d8f4f0614c2c67d6670ea8ae  node_exporter-1.1.2.linux-386.tar.gz)
null_resource.playbook (local-exec): ok: [app.korotkovdmitry.ru -> localhost] => (item=8c1f6a317457a658e0ae68ad710f6b4098db2cad10204649b51e3c043aa3e70d  node_exporter-1.1.2.linux-amd64.tar.gz)
null_resource.playbook (local-exec): skipping: [app.korotkovdmitry.ru] => (item=eb5e7d16f18bb3272d0d832986fc8ac6cb0b6c42d487c94e15dabb10feae8e04  node_exporter-1.1.2.linux-arm64.tar.gz)
null_resource.playbook (local-exec): skipping: [app.korotkovdmitry.ru] => (item=41892e451e80160491a1cc7bbe6bccd6cb842ae8340e1bc6e32f72cefb1aee80  node_exporter-1.1.2.linux-armv5.tar.gz)
null_resource.playbook (local-exec): skipping: [gitlab.korotkovdmitry.ru] => (item=3919266f1dbad5f7e5ce7b4207057fc253a8322f570607cc0f3e73f4a53338e3  node_exporter-1.1.2.darwin-amd64.tar.gz)
null_resource.playbook (local-exec): skipping: [gitlab.korotkovdmitry.ru] => (item=5b0195e203dedd3a8973cd1894a55097554a4af6d8f4f0614c2c67d6670ea8ae  node_exporter-1.1.2.linux-386.tar.gz)
null_resource.playbook (local-exec): skipping: [app.korotkovdmitry.ru] => (item=1cc1bf4cacb84d6c228d9ce8045b5b00b73afd954046f7b2add428a04d14daee  node_exporter-1.1.2.linux-armv6.tar.gz)
null_resource.playbook (local-exec): skipping: [app.korotkovdmitry.ru] => (item=a9fe816eb7b976b1587d6d654c437f7d78349f70686fa22ae33e94fe84281af2  node_exporter-1.1.2.linux-armv7.tar.gz)
null_resource.playbook (local-exec): skipping: [app.korotkovdmitry.ru] => (item=a99ab2cdc62db25ff01d184e21ad433e3949cd791fc2c80b6bacc6b90d5a62c2  node_exporter-1.1.2.linux-mips.tar.gz)
null_resource.playbook (local-exec): ok: [gitlab.korotkovdmitry.ru -> localhost] => (item=8c1f6a317457a658e0ae68ad710f6b4098db2cad10204649b51e3c043aa3e70d  node_exporter-1.1.2.linux-amd64.tar.gz)
null_resource.playbook (local-exec): skipping: [app.korotkovdmitry.ru] => (item=22d9c2a5363502c79e0645ba02eafd9561b33d1e0e819ce4df3fcf7dc96e3792  node_exporter-1.1.2.linux-mips64.tar.gz)
null_resource.playbook (local-exec): skipping: [gitlab.korotkovdmitry.ru] => (item=eb5e7d16f18bb3272d0d832986fc8ac6cb0b6c42d487c94e15dabb10feae8e04  node_exporter-1.1.2.linux-arm64.tar.gz)
null_resource.playbook (local-exec): skipping: [app.korotkovdmitry.ru] => (item=a66b70690c3c4fff953905a041c74834f96be85a806e74a1cc925e607ef50a26  node_exporter-1.1.2.linux-mips64le.tar.gz)
null_resource.playbook (local-exec): skipping: [runner.korotkovdmitry.ru] => (item=3919266f1dbad5f7e5ce7b4207057fc253a8322f570607cc0f3e73f4a53338e3  node_exporter-1.1.2.darwin-amd64.tar.gz)
null_resource.playbook (local-exec): skipping: [runner.korotkovdmitry.ru] => (item=5b0195e203dedd3a8973cd1894a55097554a4af6d8f4f0614c2c67d6670ea8ae  node_exporter-1.1.2.linux-386.tar.gz)
null_resource.playbook (local-exec): skipping: [app.korotkovdmitry.ru] => (item=f7fba791cbc758b021d0e9a2400c82d1f29337e568ab00edc84b053ca467ea3c  node_exporter-1.1.2.linux-mipsle.tar.gz)
null_resource.playbook (local-exec): skipping: [gitlab.korotkovdmitry.ru] => (item=41892e451e80160491a1cc7bbe6bccd6cb842ae8340e1bc6e32f72cefb1aee80  node_exporter-1.1.2.linux-armv5.tar.gz)
null_resource.playbook (local-exec): skipping: [app.korotkovdmitry.ru] => (item=294c0b05dff4f368512449de7268e3f06de679a9343e9885044adc702865080b  node_exporter-1.1.2.linux-ppc64.tar.gz)
null_resource.playbook (local-exec): skipping: [app.korotkovdmitry.ru] => (item=d1d201b16d757980db654bb9e448ab0c81ca4c2715243c3fa4305bef5967bd41  node_exporter-1.1.2.linux-ppc64le.tar.gz)
null_resource.playbook (local-exec): skipping: [app.korotkovdmitry.ru] => (item=6007420f425d08626c05de2dbe0e8bb785a16bba1b02c01cb06d37d7fab3bc97  node_exporter-1.1.2.linux-s390x.tar.gz)
null_resource.playbook (local-exec): skipping: [app.korotkovdmitry.ru] => (item=0596e9c1cc358e6fcc60cb83f0d1ba9a37ccee11eca035429c9791c0beb04389  node_exporter-1.1.2.netbsd-386.tar.gz)
null_resource.playbook (local-exec): skipping: [app.korotkovdmitry.ru] => (item=46c964efd336f0e35f62c739ce9edf5409911e7652604e411c9b684eb9c48386  node_exporter-1.1.2.netbsd-amd64.tar.gz)
null_resource.playbook (local-exec): skipping: [gitlab.korotkovdmitry.ru] => (item=1cc1bf4cacb84d6c228d9ce8045b5b00b73afd954046f7b2add428a04d14daee  node_exporter-1.1.2.linux-armv6.tar.gz)
null_resource.playbook (local-exec): skipping: [app.korotkovdmitry.ru] => (item=d81f86f57a4ed167a4062aa47f8a70b35c146c86bc8e40924c9d1fc3644ec8e6  node_exporter-1.1.2.openbsd-amd64.tar.gz)
null_resource.playbook (local-exec): ok: [runner.korotkovdmitry.ru -> localhost] => (item=8c1f6a317457a658e0ae68ad710f6b4098db2cad10204649b51e3c043aa3e70d  node_exporter-1.1.2.linux-amd64.tar.gz)
null_resource.playbook (local-exec): skipping: [gitlab.korotkovdmitry.ru] => (item=a9fe816eb7b976b1587d6d654c437f7d78349f70686fa22ae33e94fe84281af2  node_exporter-1.1.2.linux-armv7.tar.gz)
null_resource.playbook (local-exec): skipping: [runner.korotkovdmitry.ru] => (item=eb5e7d16f18bb3272d0d832986fc8ac6cb0b6c42d487c94e15dabb10feae8e04  node_exporter-1.1.2.linux-arm64.tar.gz)
null_resource.playbook (local-exec): skipping: [monitoring.korotkovdmitry.ru] => (item=3919266f1dbad5f7e5ce7b4207057fc253a8322f570607cc0f3e73f4a53338e3  node_exporter-1.1.2.darwin-amd64.tar.gz)
null_resource.playbook (local-exec): skipping: [monitoring.korotkovdmitry.ru] => (item=5b0195e203dedd3a8973cd1894a55097554a4af6d8f4f0614c2c67d6670ea8ae  node_exporter-1.1.2.linux-386.tar.gz)
null_resource.playbook (local-exec): skipping: [gitlab.korotkovdmitry.ru] => (item=a99ab2cdc62db25ff01d184e21ad433e3949cd791fc2c80b6bacc6b90d5a62c2  node_exporter-1.1.2.linux-mips.tar.gz)
null_resource.playbook (local-exec): ok: [monitoring.korotkovdmitry.ru -> localhost] => (item=8c1f6a317457a658e0ae68ad710f6b4098db2cad10204649b51e3c043aa3e70d  node_exporter-1.1.2.linux-amd64.tar.gz)
null_resource.playbook (local-exec): skipping: [runner.korotkovdmitry.ru] => (item=41892e451e80160491a1cc7bbe6bccd6cb842ae8340e1bc6e32f72cefb1aee80  node_exporter-1.1.2.linux-armv5.tar.gz)
null_resource.playbook (local-exec): skipping: [monitoring.korotkovdmitry.ru] => (item=eb5e7d16f18bb3272d0d832986fc8ac6cb0b6c42d487c94e15dabb10feae8e04  node_exporter-1.1.2.linux-arm64.tar.gz)
null_resource.playbook (local-exec): skipping: [gitlab.korotkovdmitry.ru] => (item=22d9c2a5363502c79e0645ba02eafd9561b33d1e0e819ce4df3fcf7dc96e3792  node_exporter-1.1.2.linux-mips64.tar.gz)
null_resource.playbook (local-exec): skipping: [monitoring.korotkovdmitry.ru] => (item=41892e451e80160491a1cc7bbe6bccd6cb842ae8340e1bc6e32f72cefb1aee80  node_exporter-1.1.2.linux-armv5.tar.gz)
null_resource.playbook (local-exec): skipping: [runner.korotkovdmitry.ru] => (item=1cc1bf4cacb84d6c228d9ce8045b5b00b73afd954046f7b2add428a04d14daee  node_exporter-1.1.2.linux-armv6.tar.gz)
null_resource.playbook (local-exec): skipping: [monitoring.korotkovdmitry.ru] => (item=1cc1bf4cacb84d6c228d9ce8045b5b00b73afd954046f7b2add428a04d14daee  node_exporter-1.1.2.linux-armv6.tar.gz)
null_resource.playbook (local-exec): skipping: [gitlab.korotkovdmitry.ru] => (item=a66b70690c3c4fff953905a041c74834f96be85a806e74a1cc925e607ef50a26  node_exporter-1.1.2.linux-mips64le.tar.gz)
null_resource.playbook (local-exec): skipping: [monitoring.korotkovdmitry.ru] => (item=a9fe816eb7b976b1587d6d654c437f7d78349f70686fa22ae33e94fe84281af2  node_exporter-1.1.2.linux-armv7.tar.gz)
null_resource.playbook (local-exec): skipping: [runner.korotkovdmitry.ru] => (item=a9fe816eb7b976b1587d6d654c437f7d78349f70686fa22ae33e94fe84281af2  node_exporter-1.1.2.linux-armv7.tar.gz)
null_resource.playbook (local-exec): skipping: [monitoring.korotkovdmitry.ru] => (item=a99ab2cdc62db25ff01d184e21ad433e3949cd791fc2c80b6bacc6b90d5a62c2  node_exporter-1.1.2.linux-mips.tar.gz)
null_resource.playbook (local-exec): skipping: [monitoring.korotkovdmitry.ru] => (item=22d9c2a5363502c79e0645ba02eafd9561b33d1e0e819ce4df3fcf7dc96e3792  node_exporter-1.1.2.linux-mips64.tar.gz)
null_resource.playbook (local-exec): skipping: [runner.korotkovdmitry.ru] => (item=a99ab2cdc62db25ff01d184e21ad433e3949cd791fc2c80b6bacc6b90d5a62c2  node_exporter-1.1.2.linux-mips.tar.gz)
null_resource.playbook (local-exec): skipping: [gitlab.korotkovdmitry.ru] => (item=f7fba791cbc758b021d0e9a2400c82d1f29337e568ab00edc84b053ca467ea3c  node_exporter-1.1.2.linux-mipsle.tar.gz)
null_resource.playbook (local-exec): skipping: [monitoring.korotkovdmitry.ru] => (item=a66b70690c3c4fff953905a041c74834f96be85a806e74a1cc925e607ef50a26  node_exporter-1.1.2.linux-mips64le.tar.gz)
null_resource.playbook (local-exec): skipping: [monitoring.korotkovdmitry.ru] => (item=f7fba791cbc758b021d0e9a2400c82d1f29337e568ab00edc84b053ca467ea3c  node_exporter-1.1.2.linux-mipsle.tar.gz)
null_resource.playbook (local-exec): skipping: [gitlab.korotkovdmitry.ru] => (item=294c0b05dff4f368512449de7268e3f06de679a9343e9885044adc702865080b  node_exporter-1.1.2.linux-ppc64.tar.gz)
null_resource.playbook (local-exec): skipping: [monitoring.korotkovdmitry.ru] => (item=294c0b05dff4f368512449de7268e3f06de679a9343e9885044adc702865080b  node_exporter-1.1.2.linux-ppc64.tar.gz)
null_resource.playbook (local-exec): skipping: [runner.korotkovdmitry.ru] => (item=22d9c2a5363502c79e0645ba02eafd9561b33d1e0e819ce4df3fcf7dc96e3792  node_exporter-1.1.2.linux-mips64.tar.gz)
null_resource.playbook (local-exec): skipping: [monitoring.korotkovdmitry.ru] => (item=d1d201b16d757980db654bb9e448ab0c81ca4c2715243c3fa4305bef5967bd41  node_exporter-1.1.2.linux-ppc64le.tar.gz)
null_resource.playbook (local-exec): skipping: [gitlab.korotkovdmitry.ru] => (item=d1d201b16d757980db654bb9e448ab0c81ca4c2715243c3fa4305bef5967bd41  node_exporter-1.1.2.linux-ppc64le.tar.gz)
null_resource.playbook (local-exec): skipping: [monitoring.korotkovdmitry.ru] => (item=6007420f425d08626c05de2dbe0e8bb785a16bba1b02c01cb06d37d7fab3bc97  node_exporter-1.1.2.linux-s390x.tar.gz)
null_resource.playbook (local-exec): skipping: [runner.korotkovdmitry.ru] => (item=a66b70690c3c4fff953905a041c74834f96be85a806e74a1cc925e607ef50a26  node_exporter-1.1.2.linux-mips64le.tar.gz)
null_resource.playbook (local-exec): skipping: [monitoring.korotkovdmitry.ru] => (item=0596e9c1cc358e6fcc60cb83f0d1ba9a37ccee11eca035429c9791c0beb04389  node_exporter-1.1.2.netbsd-386.tar.gz)
null_resource.playbook (local-exec): skipping: [monitoring.korotkovdmitry.ru] => (item=46c964efd336f0e35f62c739ce9edf5409911e7652604e411c9b684eb9c48386  node_exporter-1.1.2.netbsd-amd64.tar.gz)
null_resource.playbook (local-exec): skipping: [gitlab.korotkovdmitry.ru] => (item=6007420f425d08626c05de2dbe0e8bb785a16bba1b02c01cb06d37d7fab3bc97  node_exporter-1.1.2.linux-s390x.tar.gz)
null_resource.playbook (local-exec): skipping: [monitoring.korotkovdmitry.ru] => (item=d81f86f57a4ed167a4062aa47f8a70b35c146c86bc8e40924c9d1fc3644ec8e6  node_exporter-1.1.2.openbsd-amd64.tar.gz)
null_resource.playbook (local-exec): skipping: [gitlab.korotkovdmitry.ru] => (item=0596e9c1cc358e6fcc60cb83f0d1ba9a37ccee11eca035429c9791c0beb04389  node_exporter-1.1.2.netbsd-386.tar.gz)
null_resource.playbook (local-exec): skipping: [runner.korotkovdmitry.ru] => (item=f7fba791cbc758b021d0e9a2400c82d1f29337e568ab00edc84b053ca467ea3c  node_exporter-1.1.2.linux-mipsle.tar.gz)
null_resource.playbook (local-exec): skipping: [runner.korotkovdmitry.ru] => (item=294c0b05dff4f368512449de7268e3f06de679a9343e9885044adc702865080b  node_exporter-1.1.2.linux-ppc64.tar.gz)
null_resource.playbook (local-exec): skipping: [gitlab.korotkovdmitry.ru] => (item=46c964efd336f0e35f62c739ce9edf5409911e7652604e411c9b684eb9c48386  node_exporter-1.1.2.netbsd-amd64.tar.gz)
null_resource.playbook (local-exec): skipping: [runner.korotkovdmitry.ru] => (item=d1d201b16d757980db654bb9e448ab0c81ca4c2715243c3fa4305bef5967bd41  node_exporter-1.1.2.linux-ppc64le.tar.gz)
null_resource.playbook (local-exec): skipping: [gitlab.korotkovdmitry.ru] => (item=d81f86f57a4ed167a4062aa47f8a70b35c146c86bc8e40924c9d1fc3644ec8e6  node_exporter-1.1.2.openbsd-amd64.tar.gz)
null_resource.playbook (local-exec): skipping: [runner.korotkovdmitry.ru] => (item=6007420f425d08626c05de2dbe0e8bb785a16bba1b02c01cb06d37d7fab3bc97  node_exporter-1.1.2.linux-s390x.tar.gz)
null_resource.playbook (local-exec): skipping: [runner.korotkovdmitry.ru] => (item=0596e9c1cc358e6fcc60cb83f0d1ba9a37ccee11eca035429c9791c0beb04389  node_exporter-1.1.2.netbsd-386.tar.gz)
null_resource.playbook (local-exec): skipping: [runner.korotkovdmitry.ru] => (item=46c964efd336f0e35f62c739ce9edf5409911e7652604e411c9b684eb9c48386  node_exporter-1.1.2.netbsd-amd64.tar.gz)
null_resource.playbook (local-exec): skipping: [runner.korotkovdmitry.ru] => (item=d81f86f57a4ed167a4062aa47f8a70b35c146c86bc8e40924c9d1fc3644ec8e6  node_exporter-1.1.2.openbsd-amd64.tar.gz)

null_resource.playbook (local-exec): TASK [install_node_exporter : Create the node_exporter group] ******************
null_resource.playbook (local-exec): changed: [monitoring.korotkovdmitry.ru]
null_resource.playbook (local-exec): changed: [app.korotkovdmitry.ru]
null_resource.playbook (local-exec): changed: [gitlab.korotkovdmitry.ru]
null_resource.playbook (local-exec): changed: [runner.korotkovdmitry.ru]

null_resource.playbook (local-exec): TASK [install_node_exporter : Create the node_exporter user] *******************
null_resource.playbook (local-exec): changed: [runner.korotkovdmitry.ru]
null_resource.playbook (local-exec): changed: [app.korotkovdmitry.ru]
null_resource.playbook (local-exec): changed: [monitoring.korotkovdmitry.ru]
null_resource.playbook (local-exec): changed: [gitlab.korotkovdmitry.ru]

null_resource.playbook (local-exec): TASK [install_node_exporter : Download node_exporter binary to local folder] ***
null_resource.playbook (local-exec): ok: [app.korotkovdmitry.ru -> localhost]
null_resource.playbook: Still creating... [22m1s elapsed]
null_resource.playbook (local-exec): ok: [gitlab.korotkovdmitry.ru -> localhost]
null_resource.playbook (local-exec): ok: [runner.korotkovdmitry.ru -> localhost]
null_resource.playbook (local-exec): ok: [monitoring.korotkovdmitry.ru -> localhost]

null_resource.playbook (local-exec): TASK [install_node_exporter : Unpack node_exporter binary] *********************
null_resource.playbook (local-exec): skipping: [app.korotkovdmitry.ru]
null_resource.playbook (local-exec): skipping: [runner.korotkovdmitry.ru]
null_resource.playbook (local-exec): skipping: [gitlab.korotkovdmitry.ru]
null_resource.playbook (local-exec): skipping: [monitoring.korotkovdmitry.ru]

null_resource.playbook (local-exec): TASK [install_node_exporter : Propagate node_exporter binaries] ****************
null_resource.playbook: Still creating... [22m11s elapsed]
null_resource.playbook (local-exec): changed: [app.korotkovdmitry.ru]
null_resource.playbook (local-exec): changed: [runner.korotkovdmitry.ru]
null_resource.playbook (local-exec): changed: [gitlab.korotkovdmitry.ru]
null_resource.playbook (local-exec): changed: [monitoring.korotkovdmitry.ru]

null_resource.playbook (local-exec): TASK [install_node_exporter : propagate locally distributed node_exporter binary] ***
null_resource.playbook (local-exec): skipping: [app.korotkovdmitry.ru]
null_resource.playbook (local-exec): skipping: [gitlab.korotkovdmitry.ru]
null_resource.playbook (local-exec): skipping: [runner.korotkovdmitry.ru]
null_resource.playbook (local-exec): skipping: [monitoring.korotkovdmitry.ru]

null_resource.playbook (local-exec): TASK [install_node_exporter : Install selinux python packages [RHEL]] **********
null_resource.playbook (local-exec): skipping: [app.korotkovdmitry.ru]
null_resource.playbook (local-exec): skipping: [gitlab.korotkovdmitry.ru]
null_resource.playbook (local-exec): skipping: [runner.korotkovdmitry.ru]
null_resource.playbook (local-exec): skipping: [monitoring.korotkovdmitry.ru]

null_resource.playbook (local-exec): TASK [install_node_exporter : Install selinux python packages [Fedora]] ********
null_resource.playbook (local-exec): skipping: [app.korotkovdmitry.ru]
null_resource.playbook (local-exec): skipping: [gitlab.korotkovdmitry.ru]
null_resource.playbook (local-exec): skipping: [runner.korotkovdmitry.ru]
null_resource.playbook (local-exec): skipping: [monitoring.korotkovdmitry.ru]

null_resource.playbook (local-exec): TASK [install_node_exporter : Install selinux python packages [clearlinux]] ****
null_resource.playbook (local-exec): skipping: [app.korotkovdmitry.ru]
null_resource.playbook (local-exec): skipping: [gitlab.korotkovdmitry.ru]
null_resource.playbook (local-exec): skipping: [runner.korotkovdmitry.ru]
null_resource.playbook (local-exec): skipping: [monitoring.korotkovdmitry.ru]

null_resource.playbook (local-exec): TASK [install_node_exporter : Copy the node_exporter systemd service file] *****
null_resource.playbook (local-exec): changed: [app.korotkovdmitry.ru]
null_resource.playbook (local-exec): changed: [gitlab.korotkovdmitry.ru]
null_resource.playbook (local-exec): changed: [runner.korotkovdmitry.ru]
null_resource.playbook (local-exec): changed: [monitoring.korotkovdmitry.ru]

null_resource.playbook (local-exec): TASK [install_node_exporter : Create node_exporter config directory] ***********
null_resource.playbook (local-exec): skipping: [app.korotkovdmitry.ru]
null_resource.playbook (local-exec): skipping: [gitlab.korotkovdmitry.ru]
null_resource.playbook (local-exec): skipping: [runner.korotkovdmitry.ru]
null_resource.playbook (local-exec): skipping: [monitoring.korotkovdmitry.ru]

null_resource.playbook (local-exec): TASK [install_node_exporter : Copy the node_exporter config file] **************
null_resource.playbook (local-exec): skipping: [app.korotkovdmitry.ru]
null_resource.playbook (local-exec): skipping: [gitlab.korotkovdmitry.ru]
null_resource.playbook (local-exec): skipping: [runner.korotkovdmitry.ru]
null_resource.playbook (local-exec): skipping: [monitoring.korotkovdmitry.ru]

null_resource.playbook (local-exec): TASK [install_node_exporter : Create textfile collector dir] *******************
null_resource.playbook (local-exec): changed: [app.korotkovdmitry.ru]
null_resource.playbook (local-exec): changed: [runner.korotkovdmitry.ru]
null_resource.playbook (local-exec): changed: [monitoring.korotkovdmitry.ru]
null_resource.playbook (local-exec): changed: [gitlab.korotkovdmitry.ru]

null_resource.playbook (local-exec): TASK [install_node_exporter : Allow node_exporter port in SELinux on RedHat OS family] ***
null_resource.playbook (local-exec): skipping: [app.korotkovdmitry.ru]
null_resource.playbook (local-exec): skipping: [gitlab.korotkovdmitry.ru]
null_resource.playbook (local-exec): skipping: [runner.korotkovdmitry.ru]
null_resource.playbook (local-exec): skipping: [monitoring.korotkovdmitry.ru]

null_resource.playbook (local-exec): TASK [install_node_exporter : Ensure Node Exporter is enabled on boot] *********
null_resource.playbook: Still creating... [22m21s elapsed]
null_resource.playbook (local-exec): changed: [runner.korotkovdmitry.ru]
null_resource.playbook (local-exec): changed: [monitoring.korotkovdmitry.ru]
null_resource.playbook (local-exec): changed: [app.korotkovdmitry.ru]
null_resource.playbook (local-exec): changed: [gitlab.korotkovdmitry.ru]

null_resource.playbook (local-exec): RUNNING HANDLER [install_node_exporter : restart node_exporter] ****************
null_resource.playbook (local-exec): changed: [runner.korotkovdmitry.ru]
null_resource.playbook (local-exec): changed: [gitlab.korotkovdmitry.ru]
null_resource.playbook (local-exec): changed: [app.korotkovdmitry.ru]
null_resource.playbook (local-exec): changed: [monitoring.korotkovdmitry.ru]

null_resource.playbook (local-exec): PLAY [monitoring] **************************************************************

null_resource.playbook (local-exec): TASK [Gathering Facts] *********************************************************
null_resource.playbook (local-exec): ok: [monitoring.korotkovdmitry.ru]

null_resource.playbook (local-exec): TASK [monitoring : Prepare For Install Prometheus] *****************************
null_resource.playbook (local-exec): included: /vagrant/ansible/roles/monitoring/tasks/prepare.yml for monitoring.korotkovdmitry.ru

null_resource.playbook (local-exec): TASK [monitoring : Allow Ports] ************************************************
null_resource.playbook (local-exec): skipping: [monitoring.korotkovdmitry.ru] => (item=9090/tcp) 
null_resource.playbook (local-exec): skipping: [monitoring.korotkovdmitry.ru] => (item=9093/tcp) 
null_resource.playbook (local-exec): skipping: [monitoring.korotkovdmitry.ru] => (item=9094/tcp) 
null_resource.playbook (local-exec): skipping: [monitoring.korotkovdmitry.ru] => (item=9100/tcp) 
null_resource.playbook (local-exec): skipping: [monitoring.korotkovdmitry.ru] => (item=9094/udp) 

null_resource.playbook (local-exec): TASK [monitoring : Disable SELinux] ********************************************
null_resource.playbook (local-exec): skipping: [monitoring.korotkovdmitry.ru]

null_resource.playbook (local-exec): TASK [monitoring : Stop SELinux] ***********************************************
null_resource.playbook (local-exec): skipping: [monitoring.korotkovdmitry.ru]

null_resource.playbook (local-exec): TASK [monitoring : Allow TCP Ports] ********************************************
null_resource.playbook: Still creating... [22m31s elapsed]
null_resource.playbook (local-exec): changed: [monitoring.korotkovdmitry.ru] => (item=9090)
null_resource.playbook (local-exec): changed: [monitoring.korotkovdmitry.ru] => (item=9093)
null_resource.playbook (local-exec): changed: [monitoring.korotkovdmitry.ru] => (item=9094)
null_resource.playbook (local-exec): changed: [monitoring.korotkovdmitry.ru] => (item=9100)

null_resource.playbook (local-exec): TASK [monitoring : Allow UDP Ports] ********************************************
null_resource.playbook (local-exec): changed: [monitoring.korotkovdmitry.ru]

null_resource.playbook (local-exec): TASK [monitoring : Install Prometheus] *****************************************
null_resource.playbook: Still creating... [22m41s elapsed]
null_resource.playbook (local-exec): included: /vagrant/ansible/roles/monitoring/tasks/install_prometheus.yml for monitoring.korotkovdmitry.ru

null_resource.playbook (local-exec): TASK [monitoring : Create User prometheus] *************************************
null_resource.playbook (local-exec): changed: [monitoring.korotkovdmitry.ru]

null_resource.playbook (local-exec): TASK [monitoring : Create directories for prometheus] **************************
null_resource.playbook (local-exec): changed: [monitoring.korotkovdmitry.ru] => (item=/tmp/prometheus)
null_resource.playbook (local-exec): changed: [monitoring.korotkovdmitry.ru] => (item=/etc/prometheus)
null_resource.playbook (local-exec): changed: [monitoring.korotkovdmitry.ru] => (item=/var/lib/prometheus)

null_resource.playbook (local-exec): TASK [monitoring : Download And Unzipped Prometheus] ***************************
null_resource.playbook: Still creating... [22m51s elapsed]
null_resource.playbook: Still creating... [23m1s elapsed]
null_resource.playbook (local-exec): changed: [monitoring.korotkovdmitry.ru]

null_resource.playbook (local-exec): TASK [monitoring : Copy Bin Files From Unzipped to Prometheus] *****************
null_resource.playbook (local-exec): changed: [monitoring.korotkovdmitry.ru] => (item=prometheus)
null_resource.playbook (local-exec): changed: [monitoring.korotkovdmitry.ru] => (item=promtool)

null_resource.playbook (local-exec): TASK [monitoring : Copy Conf Files From Unzipped to Prometheus] ****************
null_resource.playbook (local-exec): changed: [monitoring.korotkovdmitry.ru] => (item=console_libraries)
null_resource.playbook: Still creating... [23m12s elapsed]
null_resource.playbook (local-exec): changed: [monitoring.korotkovdmitry.ru] => (item=consoles)
null_resource.playbook (local-exec): changed: [monitoring.korotkovdmitry.ru] => (item=prometheus.yml)

null_resource.playbook (local-exec): TASK [monitoring : Create File for Prometheus Systemd] *************************
null_resource.playbook (local-exec): changed: [monitoring.korotkovdmitry.ru]

null_resource.playbook (local-exec): TASK [monitoring : copy config] ************************************************
null_resource.playbook: Still creating... [23m22s elapsed]
null_resource.playbook (local-exec): changed: [monitoring.korotkovdmitry.ru]

null_resource.playbook (local-exec): TASK [monitoring : copy alert] *************************************************
null_resource.playbook (local-exec): changed: [monitoring.korotkovdmitry.ru]

null_resource.playbook (local-exec): TASK [monitoring : Systemctl Prometheus Start] *********************************
null_resource.playbook: Still creating... [23m32s elapsed]
null_resource.playbook (local-exec): changed: [monitoring.korotkovdmitry.ru]

null_resource.playbook (local-exec): TASK [monitoring : Install Alertmanager] ***************************************
null_resource.playbook (local-exec): included: /vagrant/ansible/roles/monitoring/tasks/install_alertmanager.yml for monitoring.korotkovdmitry.ru

null_resource.playbook (local-exec): TASK [monitoring : Create User Alertmanager] ***********************************
null_resource.playbook (local-exec): changed: [monitoring.korotkovdmitry.ru]

null_resource.playbook (local-exec): TASK [monitoring : Create Directories For Alertmanager] ************************
null_resource.playbook (local-exec): changed: [monitoring.korotkovdmitry.ru] => (item=/tmp/alertmanager)
null_resource.playbook (local-exec): changed: [monitoring.korotkovdmitry.ru] => (item=/etc/alertmanager)
null_resource.playbook (local-exec): changed: [monitoring.korotkovdmitry.ru] => (item=/var/lib/prometheus/alertmanager)

null_resource.playbook (local-exec): TASK [monitoring : Download And Unzipped Alertmanager] *************************
null_resource.playbook: Still creating... [23m42s elapsed]
null_resource.playbook (local-exec): changed: [monitoring.korotkovdmitry.ru]

null_resource.playbook (local-exec): TASK [monitoring : Copy Bin Files From Unzipped to Alertmanager] ***************
null_resource.playbook: Still creating... [23m52s elapsed]
null_resource.playbook (local-exec): changed: [monitoring.korotkovdmitry.ru] => (item=alertmanager)
null_resource.playbook (local-exec): changed: [monitoring.korotkovdmitry.ru] => (item=amtool)

null_resource.playbook (local-exec): TASK [monitoring : Copy Conf File From Unzipped to Alertmanager] ***************
null_resource.playbook (local-exec): changed: [monitoring.korotkovdmitry.ru]

null_resource.playbook (local-exec): TASK [monitoring : Create File for Alertmanager Systemd] ***********************
null_resource.playbook (local-exec): changed: [monitoring.korotkovdmitry.ru]

null_resource.playbook (local-exec): TASK [monitoring : Systemctl Alertmanager Start] *******************************
null_resource.playbook: Still creating... [24m2s elapsed]
null_resource.playbook (local-exec): changed: [monitoring.korotkovdmitry.ru]

null_resource.playbook (local-exec): TASK [grafana : Allow Ports] ***************************************************
null_resource.playbook (local-exec): skipping: [monitoring.korotkovdmitry.ru]

null_resource.playbook (local-exec): TASK [grafana : Disable SELinux] ***********************************************
null_resource.playbook (local-exec): skipping: [monitoring.korotkovdmitry.ru]

null_resource.playbook (local-exec): TASK [grafana : Stop SELinux] **************************************************
null_resource.playbook (local-exec): skipping: [monitoring.korotkovdmitry.ru]

null_resource.playbook (local-exec): TASK [grafana : Add Repository] ************************************************
null_resource.playbook (local-exec): skipping: [monitoring.korotkovdmitry.ru]

null_resource.playbook (local-exec): TASK [grafana : Install Grafana on RedHat Family] ******************************
null_resource.playbook (local-exec): skipping: [monitoring.korotkovdmitry.ru]

null_resource.playbook (local-exec): TASK [grafana : Allow TCP Ports] ***********************************************
null_resource.playbook (local-exec): changed: [monitoring.korotkovdmitry.ru]

null_resource.playbook (local-exec): TASK [grafana : Import Grafana Apt Key] ****************************************
null_resource.playbook (local-exec): changed: [monitoring.korotkovdmitry.ru]

null_resource.playbook (local-exec): TASK [grafana : Add APT Repository] ********************************************
null_resource.playbook: Still creating... [24m12s elapsed]
null_resource.playbook: Still creating... [24m22s elapsed]
null_resource.playbook (local-exec): changed: [monitoring.korotkovdmitry.ru]

null_resource.playbook (local-exec): TASK [grafana : Install Grafana on Debian Family] ******************************
null_resource.playbook: Still creating... [24m32s elapsed]
null_resource.playbook: Still creating... [24m42s elapsed]
null_resource.playbook: Still creating... [24m52s elapsed]
null_resource.playbook: Still creating... [25m2s elapsed]
null_resource.playbook (local-exec): changed: [monitoring.korotkovdmitry.ru]

null_resource.playbook (local-exec): RUNNING HANDLER [monitoring : systemd reload] **********************************
null_resource.playbook (local-exec): ok: [monitoring.korotkovdmitry.ru]

null_resource.playbook (local-exec): RUNNING HANDLER [grafana : grafana systemd] ************************************
null_resource.playbook (local-exec): changed: [monitoring.korotkovdmitry.ru]

null_resource.playbook (local-exec): PLAY RECAP *********************************************************************
null_resource.playbook (local-exec): app.korotkovdmitry.ru      : ok=34   changed=24   unreachable=0    failed=0    skipped=16   rescued=0    ignored=0
null_resource.playbook (local-exec): db01.korotkovdmitry.ru     : ok=42   changed=15   unreachable=0    failed=0    skipped=14   rescued=0    ignored=0
null_resource.playbook (local-exec): db02.korotkovdmitry.ru     : ok=42   changed=14   unreachable=0    failed=0    skipped=14   rescued=0    ignored=0
null_resource.playbook (local-exec): gitlab.korotkovdmitry.ru   : ok=28   changed=16   unreachable=0    failed=0    skipped=17   rescued=0    ignored=0
null_resource.playbook (local-exec): korotkovdmitry.ru          : ok=22   changed=20   unreachable=0    failed=0    skipped=0    rescued=0    ignored=0
null_resource.playbook (local-exec): monitoring.korotkovdmitry.ru : ok=43   changed=30   unreachable=0    failed=0    skipped=22   rescued=0    ignored=0        
null_resource.playbook (local-exec): runner.korotkovdmitry.ru   : ok=96   changed=26   unreachable=0    failed=0    skipped=125  rescued=0    ignored=0

null_resource.playbook: Creation complete after 25m8s [id=7384201265079343389]

Apply complete! Resources: 12 added, 0 changed, 0 destroyed.
```
</details>

```
mysql> SHOW DATABASES;
+--------------------+
| Database           |
+--------------------+
| information_schema |
| mysql              |
| performance_schema |
| sys                |
| wordpress          |
+--------------------+
5 rows in set (0.01 sec)

mysql> SHOW MASTER STATUS;
+------------------+----------+--------------+------------------+-------------------+
| File             | Position | Binlog_Do_DB | Binlog_Ignore_DB | Executed_Gtid_Set |
+------------------+----------+--------------+------------------+-------------------+
| mysql-bin.000002 |      154 | wordpress    |                  |                   |
+------------------+----------+--------------+------------------+-------------------+
1 row in set (0.00 sec)

mysql> SELECT USER from mysql. user;
+------------------+
| USER             |
+------------------+
| repuser          |
| wordpress        |
| debian-sys-maint |
| mysql.session    |
| mysql.sys        |
| repuser          |
| root             |
| ubuntu           |
+------------------+
8 rows in set (0.00 sec)
```

```
root@app:/var/www/www.korotkovdmitry.ru.net/wordpress# ls -la
total 236
drwxr-x---  5 www-data www-data  4096 Aug  1 02:39 .
drwxr-xr-x  3 www-data www-data  4096 Aug  1 01:46 ..
-rw-r--r--  1 www-data www-data   385 Aug  1 01:47 .htaccess
-rw-r-----  1 www-data www-data   405 Feb  6  2020 index.php
-rw-r-----  1 www-data www-data 19915 Jan  1  2022 license.txt
-rw-r-----  1 www-data www-data  7401 Mar 22 21:11 readme.html
-rw-rw-r--  1 www-data ubuntu    6256 Aug  1 02:39 README.md
-rw-r-----  1 www-data www-data  7165 Jan 21  2021 wp-activate.php
drwxr-x---  9 www-data www-data  4096 Jul 12 16:16 wp-admin
-rw-r-----  1 www-data www-data   351 Feb  6  2020 wp-blog-header.php
-rw-r-----  1 www-data www-data  2338 Nov  9  2021 wp-comments-post.php
-rw-r--r--  1 www-data root      3140 Aug  1 01:46 wp-config.php
-rw-r-----  1 www-data www-data  3001 Dec 14  2021 wp-config-sample.php
drwxr-x---  6 www-data www-data  4096 Aug  1 01:47 wp-content
-rw-r-----  1 www-data www-data  3943 Apr 28 09:49 wp-cron.php
drwxr-x--- 26 www-data www-data 12288 Jul 12 16:16 wp-includes
-rw-r-----  1 www-data www-data  2494 Mar 19 20:31 wp-links-opml.php
-rw-r-----  1 www-data www-data  3973 Apr 12 01:47 wp-load.php
-rw-r-----  1 www-data www-data 48498 Apr 29 14:36 wp-login.php
-rw-r-----  1 www-data www-data  8577 Mar 22 16:25 wp-mail.php
-rw-r-----  1 www-data www-data 23706 Apr 12 09:26 wp-settings.php
-rw-r-----  1 www-data www-data 32051 Apr 11 11:42 wp-signup.php
-rw-r-----  1 www-data www-data  4748 Apr 11 11:42 wp-trackback.php
-rw-r-----  1 www-data www-data  3236 Jun  8  2020 xmlrpc.php

root@app:/var/www/www.korotkovdmitry.ru.net/wordpress# git init
Initialized empty Git repository in /var/www/www.korotkovdmitry.ru.net/wordpress/.git/

root@app:/var/www/www.korotkovdmitry.ru.net/wordpress# git config --global --add safe.directory /var/www/www.korotkovdmitry.ru.net/wordpress

root@app:/var/www/www.korotkovdmitry.ru.net/wordpress# git remote add origin  http://gitlab.korotkovdmitry.ru/gitlab-instance-f3bcdc96/wordpress.git
root@app:/var/www/www.korotkovdmitry.ru.net/wordpress# git status
On branch master

No commits yet

Untracked files:
  (use "git add <file>..." to include in what will be committed)

        .htaccess
        README.md
        index.php
        license.txt
        readme.html
        wp-activate.php
        wp-admin/
        wp-blog-header.php
        wp-comments-post.php
        wp-config-sample.php
        wp-config.php
        wp-content/
        wp-cron.php
        wp-includes/
        wp-links-opml.php
        wp-load.php
        wp-login.php
        wp-mail.php
        wp-settings.php
        wp-signup.php
        wp-trackback.php
        xmlrpc.php

nothing added to commit but untracked files present (use "git add" to track)
root@app:/var/www/www.korotkovdmitry.ru.net/wordpress# git add .
...
root@app:/var/www/www.korotkovdmitry.ru.net/wordpress# git commit -m 'init'
...
root@app:/var/www/www.korotkovdmitry.ru.net/wordpress# git push --set-upstream origin master

root@app:/var/www/www.korotkovdmitry.ru.net/wordpress# cat index.php
<?php
/**
 * Front to the WordPress application. This file doesn't do anything, but loads
 * wp-blog-header.php which does and tells WordPress to load the theme.
 *
 * @package WordPress
  */

/**
TEST DEPLOY
**/

/**
 * Tells WordPress to load the WordPress theme and output it.
 *
 * @var bool
 */
define( 'WP_USE_THEMES', true );

/** Loads the WordPress Environment and Template */
require __DIR__ . '/wp-blog-header.php';
```