
# Домашнее задание к занятию "11.02 Микросервисы: принципы"

Вы работаете в крупной компанию, которая строит систему на основе микросервисной архитектуры.
Вам как DevOps специалисту необходимо выдвинуть предложение по организации инфраструктуры, для разработки и эксплуатации.

## Задача 1: API Gateway 

Предложите решение для обеспечения реализации API Gateway. Составьте сравнительную таблицу возможностей различных программных решений. На основе таблицы сделайте выбор решения.

Решение должно соответствовать следующим требованиям:
- Маршрутизация запросов к нужному сервису на основе конфигурации
- Возможность проверки аутентификационной информации в запросах
- Обеспечение терминации HTTPS

Обоснуйте свой выбор.

---

API Gateway можно разделить условно на два класса: Cloud-Based - облачные (предоставляемые облачными провайдерами: AWS API Gateway, Google Cloud API Gateway, Azure API Management, IBM API Connect, SberCloud API Gateway, Yandex API Gateway) 
и "Self-Hosted" - разворачиваемые на 'своём' сервере (Kong, Tyk.io,KrakenD). 

Не смотря на условное деление на облачные и self-hosted, большинство из представленных на текущий момент API Gateway поддерживают маршрутизацию запросов к нужному сервису на основе конфигурации, обладают возможностью проверки аутентификационной информации в запросах и обеспечивают терминацию HTTPS. При выборе конкретного API Gatawey я бы ориентировался на следующие дополниетельные моменты: 
    1) наличие api-gatawey у провайдера
    2) при использовании self-hosted рассмотрел бы варианты приведённые в таблице ниже.

[G2 Grid® for API Management Tools](https://www.g2.com/categories/api-management?utf8=%E2%9C%93&selected_view=grid#grid)

| Название             |               язык/плагины/основа           |                            |                       Хранение конфигурации               | Authentication check | HTTPS Termination |
|:----------------------|:-------------------------------------------|:--------------------------------|:---------------------------------------------------------|:---------------------|:-----------------|
| Kong                 | OpenResty + Lua (on top of Nginx)         |  условнобесплатен   https://konghq.com/pricing |               Database (Postges, Cassandra)               |          Да           |         Да         |
| | |    (дополнительная функциональность за плату)    |                             |                    |                  |
| Tyk.io               |         Go + JavaScript plugins         | условнобесплатен | Files, JSON  |          Да           |        Да         |
|               |                  | https://tyk.io/price-comparison/ |  |                    |                  |
| Express Gateway      |                JavaScript                 |               Да                |                        Files, JSON                        |          Да           |         Да         |
| KrakenD              | Go + поддержка плагинов на других языках  |               Да                |            Files, JSON + другие форматы            |       Да (JWT)        |         Да         |


Относительно Cloud-Based решений - практически все они обладают необходимыми возможностями, по этой причине основным критерием при использовании других сервисов того же провайдера предпочтение можно отдать API Gateway этого же провайдера. 
В качестве нескольких примеров: 
    - компания размещает сервисы на серверах Amazon - логично выбрать решение от той же компании: AWS API Gateway.
    - используем сервера и сервисы SberCloud - SberCloud API Gateway.

Отдельно стоит рассмотреть ценовую политику Cloud-Based решений, т.к. она может сильно отличаться в зависимости от предполагаемой нагрузки и облачного провайдера, в некоторых случаях будет предпочтительней поднять/использовать Self-Hosted решения.

[G2 Grid® for API Management Tools](https://www.g2.com/categories/api-management?utf8=%E2%9C%93&selected_view=grid#grid)

[API Gateway's](https://landscape.cncf.io/card-mode?category=api-gateway)

[Облачные API Gateway: зачем нужны подобные сервисы и чем они отличаются у разных платформ](https://habr.com/ru/post/557004/)

[Прокладываем тропинки до микросервисов](https://habr.com/ru/company/otus/blog/669342/)


## Задача 2: Брокер сообщений

Составьте таблицу возможностей различных брокеров сообщений. На основе таблицы сделайте обоснованный выбор решения.

Решение должно соответствовать следующим требованиям:
- Поддержка кластеризации для обеспечения надежности
- Хранение сообщений на диске в процессе доставки
- Высокая скорость работы
- Поддержка различных форматов сообщений
- Разделение прав доступа к различным потокам сообщений
- Простота эксплуатации

Обоснуйте свой выбор.

---

[Комплексное сравнение Kafka, Rabbitmq, RocketMQ, ActiveMQ](https://russianblogs.com/article/20011881592/)

[Кафка против RabbitMQ - прямое сравнение на 2022 год](https://translated.turbopages.org/proxy_u/en-ru.ru.1766beef-62ec38d4-59484eb9-74722d776562/https/www.projectpro.io/article/kafka-vs-rabbitmq/451)

[Kafka, RabbitMQ или AWS SNS/SQS: какой брокер выбрать?](https://habr.com/ru/post/573358/)

[Kafka vs ActiveMQ vs RabbitMQ vs Amazon SNS vs Amazon SQS vs Google pub/sub](https://medium.com/double-pointer/kafka-vs-activemq-vs-rabbitmq-vs-amazon-sns-vs-amazon-sqs-vs-google-pub-sub-4b57976438db)

[G2 Grid® for Message Queue (MQ)](https://www.g2.com/categories/message-queue-mq#grid)


|Брокер      | Поддержка кластеризации | Хранение сообщений на диске| Высокая скорость | Поддержка различных форматов | Разделение прав доступа | Проcтота эксплуатации |
|:-----------|:-----------------------:|:--------------------------:|:----------------:|:----------------------------:|:-----------------------:|:---------------------:|
|Kafka       | + | + | + | BINARY over TCP | + | + |
|RabbitMQ    | + | + | + | STOMP/AMQP/MQTT | + | + |
|ActiveMQ    | + | + | + | AMQP/MQTT/REST и пр. | + | - |
|Redis       | + | - | + |  RESP | + | + |

На текущий момент одними из наиболее распространённых являются Kafka, RabbitMQ и Redis. Каждый из них обладает своими достоинствами и недостатками. 

Для обоснования выбора того или иного брокера очередей необходимо ответить на дополнительные вопросы: цель использования, предполагаемая нагрузка, количество потребителей, приоритетность гарантированной доставки над производительностью, предполагается ли совместное (комунальное) использование.

Можно выделить как наиболее популярный и поддерживающий больше различных протоколов - RabbitMQ, в то же время в случае необходимости унификации используемого протокола совместно с другими системами предпочтение можно отдать Apache Kafka.

## Задача 3: API Gateway * (необязательная)

