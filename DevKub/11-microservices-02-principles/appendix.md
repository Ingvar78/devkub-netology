## Задача 3: API Gateway * (необязательная)

### Есть три сервиса:

**minio**
- Хранит загруженные файлы в бакете images
- S3 протокол

**uploader**
- Принимает файл, если он картинка сжимает и загружает его в minio
- POST /v1/upload

**security**
- Регистрация пользователя POST /v1/user
- Получение информации о пользователе GET /v1/user
- Логин пользователя POST /v1/token
- Проверка токена GET /v1/token/validation

### Необходимо воспользоваться любым балансировщиком и сделать API Gateway:

**POST /v1/register**
- Анонимный доступ.
- Запрос направляется в сервис security POST /v1/user

**POST /v1/token**
- Анонимный доступ.
- Запрос направляется в сервис security POST /v1/token

**GET /v1/user**
- Проверка токена. Токен ожидается в заголовке Authorization. Токен проверяется через вызов сервиса security GET /v1/token/validation/
- Запрос направляется в сервис security GET /v1/user

**POST /v1/upload**
- Проверка токена. Токен ожидается в заголовке Authorization. Токен проверяется через вызов сервиса security GET /v1/token/validation/
- Запрос направляется в сервис uploader POST /v1/upload

**GET /v1/user/{image}**
- Проверка токена. Токен ожидается в заголовке Authorization. Токен проверяется через вызов сервиса security GET /v1/token/validation/
- Запрос направляется в сервис minio  GET /images/{image}

### Ожидаемый результат

Результатом выполнения задачи должен быть docker compose файл запустив который можно локально выполнить следующие команды с успешным результатом.
Предполагается что для реализации API Gateway будет написан конфиг для NGinx или другого балансировщика нагрузки который будет запущен как сервис через docker-compose и будет обеспечивать балансировку и проверку аутентификации входящих запросов.
Авторизаци
curl -X POST -H 'Content-Type: application/json' -d '{"login":"bob", "password":"qwe123"}' http://localhost/token

**Загрузка файла**

curl -X POST -H 'Authorization: Bearer eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9.eyJzdWIiOiJib2IifQ.hiMVLmssoTsy1MqbmIoviDeFPvo-nCd92d4UFiN2O2I' -H 'Content-Type: octet/stream' --data-binary @yourfilename.jpg http://localhost/upload

**Получение файла**
curl -X GET http://localhost/images/4e6df220-295e-4231-82bc-45e4b1484430.jpg

---

#### [Дополнительные материалы: как запускать, как тестировать, как проверить](https://github.com/netology-code/devkub-homeworks/tree/main/11-microservices-02-principles)

---

# Как запускать
После написания nginx.conf для запуска выполните команду
```
docker-compose up --build
```

# Как тестировать

## Login
Получить токен
```
curl -X POST -H 'Content-Type: application/json' -d '{"login":"bob", "password":"qwe123"}' http://localhost/token
```

Пример
```
$ curl -X POST -H 'Content-Type: application/json' -d '{"login":"bob", "password":"qwe123"}' http://localhost/token
eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9.eyJzdWIiOiJib2IifQ.hiMVLmssoTsy1MqbmIoviDeFPvo-nCd92d4UFiN2O2I
```

```bash
iva@c9v:~/Documents $ curl -X POST -H 'Content-Type: application/json' -d '{"login":"bob", "password":"qwe123"}' http://localhost/token
eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9.eyJzdWIiOiJib2IifQ.hiMVLmssoTsy1MqbmIoviDeFPvo-nCd92d4UFiN2O2I
iva@c9v:~/Documents $ 
```


## Test
Использовать полученный токен для загрузки картинки
```
curl -X POST -H 'Authorization: Bearer <TODO: INSERT TOKEN>' -H 'Content-Type: octet/stream' --data-binary @1.jpg http://localhost/upload
```
Пример
```
$ curl -X POST -H 'Authorization: Bearer eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9.eyJzdWIiOiJib2IifQ.hiMVLmssoTsy1MqbmIoviDeFPvo-nCd92d4UFiN2O2I' -H 'Content-Type: octet/stream' --data-binary @1.jpg http://localhost/upload
{"filename":"c31e9789-3fab-4689-aa67-e7ac2684fb0e.jpg"}
```

```
iva@c9v:~/Documents/img $ curl -X POST -H 'Authorization: Bearer eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9.eyJzdWIiOiJib2IifQ.hiMVLmssoTsy1MqbmIoviDeFPvo-nCd92d4UFiN2O2I' -H 'Content-Type: octet/stream' --data-binary @dashboard1.png http://localhost/upload
<html>
<head><title>502 Bad Gateway</title></head>
<body>
<center><h1>502 Bad Gateway</h1></center>
<hr><center>nginx/1.23.1</center>
</body>
</html>
iva@c9v:~/Documents/img $ curl -X POST -H 'Authorization: Bearer eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9.eyJzdWIiOiJib2IifQ.hiMVLmssoTsy1MqbmIoviDeFPvo-nCd92d4UFiN2O2I' -H 'Content-Type: octet/stream' --data-binary @dashboard1.png http://localhost/upload
{"filename":"2a17fb32-c949-4eac-b885-36d8ca164ef5.png"}
iva@c9v:~/Documents/img $
```

 ## Проверить
Загрузить картинку и проверить что она открывается
```
curl localhost/image/<filnename> > <filnename>
```
Example
```
$ curl localhost/images/c31e9789-3fab-4689-aa67-e7ac2684fb0e.jpg > c31e9789-3fab-4689-aa67-e7ac2684fb0e.jpg
  % Total    % Received % Xferd  Average Speed   Time    Time     Time  Current
                                 Dload  Upload   Total   Spent    Left  Speed
100 13027  100 13027    0     0   706k      0 --:--:-- --:--:-- --:--:--  748k

$ ls
c31e9789-3fab-4689-aa67-e7ac2684fb0e.jpg
```


```
iva@c9v:~/Documents/img $ curl localhost/images/2a17fb32-c949-4eac-b885-36d8ca164ef5.png >2a17fb32-c949-4eac-b885-36d8ca164ef5.png
  % Total    % Received % Xferd  Average Speed   Time    Time     Time  Current
                                 Dload  Upload   Total   Spent    Left  Speed
100  144k  100  144k    0     0  47.1M      0 --:--:-- --:--:-- --:--:-- 47.1M
iva@c9v:~/Documents/img $ ls -la
total 2616
drwxrwxr-x   2 iva iva   4096 Aug 10 00:55 .
drwxr-xr-x. 10 iva iva    139 Aug 10 00:40 ..
-rw-rw-r--   1 iva iva 148271 Aug 10 00:55 2a17fb32-c949-4eac-b885-36d8ca164ef5.png
-rw-r--r--   1 iva iva 148271 Jun 30 00:58 dashboard1.png
-rw-r--r--   1 iva iva 150611 Jun 30 01:13 dashboard2.png
-rw-r--r--   1 iva iva 161129 Jun 30 02:15 dashboard3.png
-rw-r--r--   1 iva iva  92039 Jun 30 00:39 grafana1.png
-rw-r--r--   1 iva iva 126612 Jul  3 15:50 kibana01.png
-rw-r--r--   1 iva iva 129199 Jul  3 15:55 Kibana02.png
-rw-r--r--   1 iva iva 221046 Jul  7 11:14 Sentry01.png
-rw-r--r--   1 iva iva 248409 Jul  7 11:14 Sentry02.png
-rw-r--r--   1 iva iva  76802 Jul  7 11:15 Sentry03.png
-rw-r--r--   1 iva iva 280465 Jul  7 11:39 Sentry04_st.png
-rw-r--r--   1 iva iva 250857 Jul  7 12:21 Sentry_05.png
-rw-r--r--   1 iva iva 234133 Jul  7 13:02 Sentry06.png
-rw-r--r--   1 iva iva 241592 Jul  7 13:46 Sentry07_Issues.png
-rw-r--r--   1 iva iva 135549 Jul  7 13:07 Sentry_slack.png

```
