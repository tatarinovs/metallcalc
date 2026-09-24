# Шпаргалка по командам — Металлокалькулятор

Все команды выполняются из корня проекта (`d:\PROJECT\metallcalc\`).
Все готовые бинарники копируются напрямую в папку **`releases/`** (папка `dist/` служит исключительно для фронтенда Vite).

---

## Сборка в один клик (.bat)

| Скрипт | Назначение | Результат в `releases/` |
|---|---|---|
| `build-exe.bat [x64\|x86\|all]` | Собрать Windows `.exe` и установщик NSIS под x64 и/или x86 | `releases\metallcalc.exe` (~2.7 МБ)<br>`releases\metallcalc-setup.exe` (~1.0 МБ)<br>`releases\metallcalc-x86.exe` (~2.5 МБ)<br>`releases\metallcalc-x86-setup.exe` (~1.0 МБ) |
| `build-apk.bat [arm64\|armv7\|x86\|all]` | Собрать подписанные релизные `.apk` (ARM64, ARMv7, x86) | `releases\metallcalc-arm64-release.apk` (~5.7 МБ)<br>`releases\metallcalc-armv7-release.apk` (~5.2 МБ)<br>`releases\metallcalc-x86-release.apk` (~5.5 МБ) |

---

## Тестирование

| Команда | Что делает |
|---|---|
| `npm test` | Запуск Vitest: 19 тестов проверки геометрии, формул, массы и линейной плотности |

---

## Веб-версия и встраивание на сайт

| Команда | Что делает |
|---|---|
| `npm run dev` | Dev-сервер с горячей перезагрузкой → `http://localhost:5173` |
| `npm run build` | Сборка статики в `dist/` (`assets/index.js` и `assets/index.css`) |
| `npm run preview` | Локальный предпросмотр продакшен-сборки `dist/` |

Для встраивания на сайт (например, в CMS или статическую страницу):
1. Скопировать `dist/assets/index.js` и `dist/assets/index.css` на сервер.
2. Подключить в HTML:
   ```html
   <link rel="stylesheet" href="assets/index.css">
   <div id="app"></div>
   <script type="module" src="assets/index.js"></script>
   ```

---

## Десктоп (.exe) — Tauri

| Команда | Что делает |
|---|---|
| `npm run tauri dev` | Окно приложения в режиме разработки с горячей перезагрузкой |
| `npm run tauri build -- --target x86_64-pc-windows-msvc` | Сборка x64 установщика и `.exe` |
| `npm run tauri build -- --target i686-pc-windows-msvc` | Сборка x86 (32-bit) установщика и `.exe` |

---

## Android (.apk) — Tauri Mobile

| Команда | Что делает |
|---|---|
| `npm run tauri android dev` | Запуск на подключённом смартфоне / эмуляторе с hot-reload |
| `npm run tauri android build -- --target aarch64 --split-per-abi --apk` | Сборка релизного подписанного APK под arm64-v8a |
| `npm run tauri android build -- --target armv7 --split-per-abi --apk` | Сборка релизного подписанного APK под armeabi-v7a (ARMv7) |
| `npm run tauri android build -- --target i686 --split-per-abi --apk` | Сборка релизного подписанного APK под x86 |

Ключ подписи и конфигурация:
- `src-tauri/gen/android/keystore.properties`
- `src-tauri/gen/android/release.keystore`
