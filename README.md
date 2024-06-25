3./# rempc

## install run build  on MacOs

install brew
install java
install Android Studio
install FVM (Flutter version manager)
##### Flutter prepare
*In termianal*

    run fvm install 3.13.7

    run fvm use 3.13.7

    run ./scripts/start.sh -f  


## env
**Настройка конфигурации запуска в Android Studio**
##### билд смотрит в dev
entry point: $DIR/rempc-app-dart/app/lib/main_dev.dart  
build flavor: dev

##### билд смотрит в prod
entry point: /Users/dev/work/rempc-app-dart/app/lib/main_prod.dart  
build flavor: prod

## Code generation
run ./scripts/codegen_build.sh

##### Build Android APK
run ./scripts/build.sh -a

##### Build Android AAB
run ./scripts/build_release_appbundle.sh


## Структура проекта
Папка `app` - приложение для компиляции
Папка `codegen_config` - служебная папка для кодогенерации. в неё скриптом копируются все файлы для кодогена, выполняется кодоген и из неё всё переносится на свои места в проекте.
Папка `modules` - флаттер модули приложения для конкретных целей
Папка `packages` - кастомные флаттер пакеты для приложения
Папка `scripts` - bash скрипты для развертывания всего "маскарада"

 