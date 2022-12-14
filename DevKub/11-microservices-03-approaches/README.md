# Домашнее задание к занятию "11.03 Микросервисы: подходы"

Вы работаете в крупной компанию, которая строит систему на основе микросервисной архитектуры.
Вам как DevOps специалисту необходимо выдвинуть предложение по организации инфраструктуры, для разработки и эксплуатации.


## Задача 1: Обеспечить разработку

Предложите решение для обеспечения процесса разработки: хранение исходного кода, непрерывная интеграция и непрерывная поставка. 
Решение может состоять из одного или нескольких программных продуктов и должно описывать способы и принципы их взаимодействия.

Решение должно соответствовать следующим требованиям:
- Облачная система;
- Система контроля версий Git;
- Репозиторий на каждый сервис;
- Запуск сборки по событию из системы контроля версий;
- Запуск сборки по кнопке с указанием параметров;
- Возможность привязать настройки к каждой сборке;
- Возможность создания шаблонов для различных конфигураций сборок;
- Возможность безопасного хранения секретных данных: пароли, ключи доступа;
- Несколько конфигураций для сборки из одного репозитория;
- Кастомные шаги при сборке;
- Собственные докер образы для сборки проектов;
- Возможность развернуть агентов сборки на собственных серверах;
- Возможность параллельного запуска нескольких сборок;
- Возможность параллельного запуска тестов;

Обоснуйте свой выбор.

---

| Решение                                       | Teamcity | GitLab CI | Github actions | Jenkins | Nexus | Bitbucket | Travis CI |
|:----------------------------------------------|:---------|:----------|:---------------|:--------|:------|:----------|:----------|
| Облачная система | + | + | + | - | - | - | + |
| Система контроля версий Git | s | + | + | s | POM | + | s |
| Репозиторий на каждый сервис | + | + | + | + | + | + | + |
| Запуск сборки по событию из системы контроля версий | + | + | + | + | - | - | + |
| Запуск сборки по кнопке с указанием параметров | + | + | + | + | - | - | + |
| Возможность привязать настройки к каждой сборке | + | + | + | + | + | + | + |
| Возможность создания шаблонов для различных конфигураций сборок | + | + | + | + | + | + | + |
| Возможность безопасного хранения секретных данных: пароли, ключи доступа | + | + | + | + | - | - | + |
| Несколько конфигураций для сборки из одного репозитория | + | + | + | + |  +- |  +- | + |
| Кастомные шаги при сборке | + | + | + | + |  |  | + |
| Собственные докер образы для сборки проектов | + | + | - | + | s | - | + |
| Возможность развернуть агентов сборки на собственных серверах | + | + | - | + |  |  | - |
| Возможность параллельного запуска нескольких сборок | + | + | + | + |  |  | + |
| Возможность параллельного запуска тестов | + | + | + | + |  |  | + |

's' - условно подерживает возможность работы

'+' - имеется соответсвующий функционал

'-' - отсутствует соответсвующий функционал

'+-' -  поддерживает частично

В сводной таблице приведены такие инструменты как Teamcity, GitLab CI, Github actions, Jenkins, Nexus, Bitbucket, Travis CI. 

Стоит выделить следующие группы: 1) Teamcity, GitLab CI, Github actions, Jenkins, Travis CI - инструменты для организации самого процесса непрерывной поставки 2) Nexus, Bitbucket - инструменты для хранения исходного кода, готовых сборок и Docker-образов.

Для обеспечения процесса разработки возможно ограничиться одним инструментом - GitLab CI, т.к. данный инструмент поддерживает большинство необходимых функций из коробки, однако это несёт некоторые риски - при его недоступности будет потеряна вся цепочка данных, включая исходный код и готовые поставки, что может быть очень критично.

Для снижения рисков возникновения ситуации с полной потерей, я бы рассмотрел возможность использования различных инструментов для храннения исходного кода, построения CI/CD и хранения готовых сборок и Docker-образов.

Для построения процесса разработки можно рекомендовать следующие инструменты: TeamCity/Jenkins + Bitbucket/GitLab/GitHub + Nexus. TeamCity/Jenkins - для организации CI/CD, Bitbucket/GitLab/GitHub - для хранения исходного кода, Nexus - для хранения готовых сборок и Docker-образов.

Дополнительные материалы по теме:

[Jenkins vs Travis CI vs Circle CI vs TeamCity vs Codeship vs GitLab CI vs Bamboo](https://www.overops.com/blog/jenkins-vs-travis-ci-vs-circle-ci-vs-teamcity-vs-codeship-vs-gitlab-ci-vs-bamboo/)


## Задача 2: Логи

Предложите решение для обеспечения сбора и анализа логов сервисов в микросервисной архитектуре.
Решение может состоять из одного или нескольких программных продуктов и должно описывать способы и принципы их взаимодействия.

Решение должно соответствовать следующим требованиям:
- Сбор логов в центральное хранилище со всех хостов обслуживающих систему;
- Минимальные требования к приложениям, сбор логов из stdout;
- Гарантированная доставка логов до центрального хранилища;
- Обеспечение поиска и фильтрации по записям логов;
- Обеспечение пользовательского интерфейса с возможностью предоставления доступа разработчикам для поиска по записям логов;
- Возможность дать ссылку на сохраненный поиск по записям логов;

Обоснуйте свой выбор.

---

Одним из самых распространенных вариантов является ELK стек, с некоторыми дополнениями: E - elasticsearch - хранение логов, L - logstash - сбор, парсинг и преобразование логов, K - kibana - интерфейс для визуализации и удобной работы с информацией.

Основным преимуществом можно считать достаточную простоту настройки и хорошую документацию по стеку, так же возможность интеграции дополнительных сборщиков логов - где это требуется - например filebeat.

ELK соответствует большинству предъявленных требований, однако использование данного решения связано с высоким потреблением ресурсов, в частности из-за использования JVM (elasticsearch и logstash), так же есть проблема информ безопасности связанная с elasticsearch.

В качестве альтернативы ELK можно рассмотреть вариант с использованием хранилища логов - ClickHouse, для отображения и работы с логами использовать Grafana.

Ещё одной альтернативой ELK является использование ClickHouse, Vector и lighthouse.

Так же под текущие требования подходит вариант использования Prometheus, Filebeat.

Выбор правильного решения сбора и анализа логов зависит от конкретных потребностей и требований. Например, если у нас приложение IoT, требующее небольшого потребления ресурсов, для сбора логов лучше использовать Vector или Fluent Bit, а не Logstash.

В случае если наш микросервис построен на наборе docker-контейнеров, то логично было бы использовать Filebeat + Prometeus.


Дополнительные материалы по теме:

[Logstash, Fluentd, Fluent Bit, or Vector? How to choose the right open-source log collector](https://www.cncf.io/blog/2022/02/10/logstash-fluentd-fluent-bit-or-vector-how-to-choose-the-right-open-source-log-collector/)

[5 КЛЮЧЕВЫХ ДОСТОИНСТВ И 3 ГЛАВНЫХ НЕДОСТАТКА ELK-СТЕКА: РАЗБИРАЕМСЯ С ELASTICSEARCH, LOGSTASH И KIBANA НА РЕАЛЬНЫХ BIG DATA КЕЙСАХ](https://www.bigdataschool.ru/blog/elk-stack-key-features.html)

[Logstash + ClickHouse + Grafana: Как сделать Logger для логов ИБ умнее и эффективнее?](https://temofeev.ru/info/articles/logstash-clickhouse-grafana-kak-sdelat-logger-dlya-logov-ib-umnee-i-effektivnee/)

## Задача 3: Мониторинг

Предложите решение для обеспечения сбора и анализа состояния хостов и сервисов в микросервисной архитектуре.
Решение может состоять из одного или нескольких программных продуктов и должно описывать способы и принципы их взаимодействия.

Решение должно соответствовать следующим требованиям:
- Сбор метрик со всех хостов, обслуживающих систему;
- Сбор метрик состояния ресурсов хостов: CPU, RAM, HDD, Network;
- Сбор метрик потребляемых ресурсов для каждого сервиса: CPU, RAM, HDD, Network;
- Сбор метрик, специфичных для каждого сервиса;
- Пользовательский интерфейс с возможностью делать запросы и агрегировать информацию;
- Пользовательский интерфейс с возможность настраивать различные панели для отслеживания состояния системы;

Обоснуйте свой выбор.

---

Исходя из предложенных выше вариантов (при ответе на задачу 2), предлагаю использовать Prometheus и Grafana. 
Prometheus поддерживает сбор и хранение различных метрик, при необходимости возможно написать свой exporter. 
Grafana - как средство визуализации метрик хранящихся в Prometheus, позволяющее создавать свои панели и дашборды, настроить нотификации и пороги срабатывания.

* Exporters — это часть ПО, которая собирает и передаёт Prometheus-метрики серверу. Существуют разные экспортёры, например HAProxy, StatsD, Graphite. Они устанавливаются на целевые объекты и собирают определённые метрики.


## Задача 4: Логи * (необязательная)

Продолжить работу по задаче API Gateway: сервисы используемые в задаче пишут логи в stdout. 

Добавить в систему сервисы для сбора логов Vector + ElasticSearch + Kibana со всех сервисов обеспечивающих работу API.

### Результат выполнения: 

docker compose файл запустив который можно перейти по адресу http://localhost:8081 по которому доступна Kibana.
Логин в Kibana должен быть admin пароль qwerty123456


## Задача 5: Мониторинг * (необязательная)

Продолжить работу по задаче API Gateway: сервисы используемые в задаче предоставляют набор метрик в формате prometheus:

- Сервис security по адресу /metrics
- Сервис uploader по адресу /metrics
- Сервис storage (minio) по адресу /minio/v2/metrics/cluster

Добавить в систему сервисы для сбора метрик (Prometheus и Grafana) со всех сервисов обеспечивающих работу API.
Построить в Graphana dashboard показывающий распределение запросов по сервисам.

### Результат выполнения: 

docker compose файл запустив который можно перейти по адресу http://localhost:8081 по которому доступна Grafana с настроенным Dashboard.
Логин в Grafana должен быть admin пароль qwerty123456

---

### Как оформить ДЗ?

Выполненное домашнее задание пришлите ссылкой на .md-файл в вашем репозитории.

---
