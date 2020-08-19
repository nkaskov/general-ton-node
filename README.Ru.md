# Инструкция по установке полной ноды сети ton-rocks
Проверялась на Ubuntu 18.04

1. Скачиваем репозиторий
```bash
git clone https://github.com/ton-rocks/general-ton-node.git
```

2. Переходим в папку scripts
```bash
cd ./general-ton-node/scripts
```

Обратите внимание, далее все команды выполняются из папки scripts!

3. Устанавливаем зависимости (только ubuntu, можно установить необходимые пакеты руками)
```bash
./system_init.sh
```

Возможно, для запуска докера понадобится создать группу и добавить туда текущего пользователя

```bash
newgrp docker
sudo usermod -a -G docker текущий_пользователь
```

Так же желательно установить chrony (пример https://www.tecmint.com/install-chrony-in-centos-ubuntu-linux/)

4. Собираем докер контейнер (будет собрана нода TON, нужно RAM не менее 4GB)
```bash
./docker_build.sh
```

5. Открываем файл env.sh в любом текстовом редакторе. При необходимости меняем IP и порты.

6. Открываем указанные порты в файрволе. Для ubuntu команды будут выглядеть так:
```bash
sudo ufw allow порт
```

Открыть порты нужно для следующих сервисов, упомянутых в env.sh 
```
ADNL_PORT
LITE_PORT
WS_PORT
BLOCK_EXPLORER_PORT
```

Возможно так же указать рабочую директорию TON_DIR для докер контейнера вместо VOLUME_NAME
```bash
#export VOLUME_NAME="ton-rocks-db"
# or
export TON_DIR="/var/ton-work"
```
В этом случае база данных, логи и вспомогательные файлы будут располагаться в директории TON_DIR.

Количество потоков ноды CORE_COUNT не должно превышать количество ядер сервера.
Так же имеются ограничения по оперативной памяти - необходимо резервировать примерно по 2ГБ на поток.
Т.е. на сервере с RAM 16ГБ CORE_COUNT должен быть равен 7
```bash
export CORE_COUNT=7
```

7. Первый запуск ноды
```bash
./docker_create_storage.sh
./docker_run.sh
```
Ждём несколько минут, при первом запуске сгенерируются ключи кошелька валидатора, а так же некоторые конфиги

8. Экспортируем сгенерированные файлы из контейнера
```bash
./docker_export_wallet.sh
```

Экспортируются следующие файлы:
адрес и ключи кошелька валидатора
```
validator.hexaddr
validator.addr
validator.pk
```

Сохраните их в доступном месте, при следующем запуске ./docker_export_wallet.sh они перепишутся!

9. Экспортируем конфигурацию

```bash
./docker_export_conf.sh
```

Конфигурации DHT и lite-server
```
dht_node.conf
liteserver.conf
```

Ключи для доступа к lite-server и консоли ноды
```
liteserver.pub
console_server.pub
console_client
```

Если скрипты говорят, что некоторых файлов нет, ждём ещё и перезапускаем

10. Отправляем запрос на тестовые монеты. В запросе указываем следующую информацию:
- адрес кошелька валидатора, из файла validator.hexaddr
- содержимое файлов dht_node.conf и liteserver.conf
- порт BLOCK_EXPLORER_PORT (не нужно, если файл env.sh не меняли)

11. Дожидаемся синхронизации ноды командой
```bash
./docker_status.sh
```
Разница TIME_DIFF должна быть в пределах 20
```
INFO: TIME_DIFF = -4
```

12. Дожидаемся зачисления монет на кошелёк. Состояние кошелька можно проверить командой
```bash
./docker_wallet_status.sh
```
```Account state is EMPTY with balance 0``` говорит о том, что монет в аккаунте нет.

```Account state is UNINIT with balance 100000000000000ng``` говорит о том, на кошельке 100000 монет, но код кошелька не задеплоен.

Состояние кошелька так же можно посмотреть в блокчейн эксплорере, который доступен у вас по BLOCK_EXPLORER_PORT порту.

Когда появится ненулевой баланс, кошелёк нужно задеплоить командой
```bash
./docker_wallet_deploy.sh
```

после чего состояние должно измениться на
```Account state is ACTIVE with balance 99999956409603ng```

13. Когда нода синхронизировалась, нужно установить в cron запуск скриптов участия в выборах
Выполняем ```crontab -e```
и вставляем строку

```
*/10 * * * *     cd путь_к_папке_scripts && ./docker_participate.sh
```

14. Командой 
```bash
./docker_logs.sh
```
можно получить логи регистрации в выборах (participate.log и reap.log)


# Если возникают проблемы

1. Получить лог ноды TON можно командой
```./docker_node_logs.sh``` (осторожно, он большой!).
Логи остальных сервисов и скриптов
```./docker_logs.sh```
2. Состояние файрвола командой
```sudo ufw status```
3. Открытые порты
```sudo netstat -ntlp | grep LISTEN```
4. Нагрузку на сервер
```htop```
5. Нагрузку на диски 
```iostat -dx -N 2```
6. Скорость сети
```https://www.speedtest.net/ru/apps/cli```
7. Состояние сети
```sudo iftop```

# Перезапуск ноды


1. Останавливаем командой
```bash
./docker_stop.sh
```

2. Удаляем ноду, но оставляем хранилище
```bash
./docker_clean.sh
Do you want to stop and delete node? (y/n): y
Do you want to delete permanent storage? (y/n): n
```

3. Запускаем снова. Постоянное хранилище, созданное на этапе 7, примантируется автоматически
```bash
./docker_run.sh
```


# Если сменился IP

1. Останавливаем запущенный контейнер
```bash
./docker_stop.sh
```

2. Меняем PUBLIC_IP в файле env.sh

3. Удаляем ноду, но оставляем хранилище
```bash
./docker_clean.sh
Do you want to stop and delete node? (y/n): y
Do you want to delete permanent storage? (y/n): n
```

4. Запускаем снова
```bash
./docker_run.sh
```

5. Выполняем команду
```bash
./docker_export_conf.sh
```

6. Отсылаем файлы dht_node.conf и liteserver.conf


# Перенос ноды на другой сервер

1. Дожидаемся, когда выборы закончатся. Проверить можно в логе participate.log
Фраза "No active election, exiting" означает, что выборы закончены

2. Убираем запуск скрипта из крона. 
Запускаем ```crontab -e``` и удаляем строку
```
*/10 * * * *     cd путь_к_папке_scripts && ./docker_participate.sh
```

3. На новом сервере выполняем шаги 1-7 основной инструкции

4. Копируем файлы 
```
validator.hexaddr
validator.addr
validator.pk
```
в папку scripts

5. Запускаем команду импорта ключей
```bash
./docker_import.sh
```

6. Выполняем шаги 9-14 основной инструкции



# Запускаем несколько нод на 1 сервере

Проще всего сделать несколько копий папки scripts и поменять в каждой env.sh. 
Затем выполнить все действия из инструкции в каждой папке

# Что ещё?
Входим в контейнер
```bash
./docker_bash.sh
```

Параметры выборов
```bash
lite-client -C /var/ton-work/db/my-ton-global.config.json -v 0 -rc "getconfig 15" -rc "getconfig 16" -rc "getconfig 17" -rc "quit"
```

Номер текущих выборов (0 - выборов нет)
```bash
lite-client -C /var/ton-work/db/my-ton-global.config.json -v 0 -rc "runmethod -1:3333333333333333333333333333333333333333333333333333333333333333 active_election_id" -rc "quit" | grep "result: "
```

Список public ключей (в формате int) зарегистрированных участников выборов
```bash
lite-client -C /var/ton-work/db/my-ton-global.config.json -v 0 -rc "runmethod -1:3333333333333333333333333333333333333333333333333333333333333333 participant_list" -rc "quit" | grep "result: "
```

Список текущих валидаторов
```bash
lite-client -C /var/ton-work/db/my-ton-global.config.json -v 0 -rc "getconfig 34" -rc "quit"
```

Список следующих валидаторов
```bash
lite-client -C /var/ton-work/db/my-ton-global.config.json -v 0 -rc "getconfig 36" -rc "quit"
```

Список предыдущих валидаторов
```bash
lite-client -C /var/ton-work/db/my-ton-global.config.json -v 0 -rc "getconfig 32" -rc "quit"
```

Список выборов, в которых участвовал валидатор
```bash
ls /var/ton-work/contracts/*.elect
```
В самих файлах находятся параметры участия, в т.ч. public ключ в формате base64 (PUBKEY=)
Перевести public ключ в int можно командой
```bash
python -c "k='ваш_PUBKEY'; import base64; import codecs; print(int(codecs.encode(base64.b64decode(k)[4:], 'hex'), 16))"
```
а в hex формат
```bash
python -c "k='ваш_PUBKEY'; import base64; import codecs; print('%x' % int(codecs.encode(base64.b64decode(k)[4:], 'hex'), 16))"
```


# Запускаем песочницу

1. Собираем докер контейнер
```bash
./docker_build.sh
```

2. Запускаем песочницу
```
cd sandbox && ./sandbox_run.sh
```

3. Ждём, когда всё запустится и начнутся выборы. 

3. Если наигрались, нажимаем CTRL-C и чистим за собой
```bash
./sandbox_cleanup.sh
```
