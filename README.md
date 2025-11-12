# Hexlib

Библиотека для работы с Lua for Barotrauma.

## Быстрый старт

```lua
local HexLib = require("hexlib")

-- Чат: отправка сообщения всем клиентам
HexLib.IChat.SendMessageToAll("Система", "Привет, экипаж!", HexLib.IEnum.Green)

-- Проверка недуга
if HexLib.IAffliction.HasAffliction(character, "huskinfection") then
  HexLib.IChat.PrintChat("Медскан", "Внимание: инфекция!", HexLib.IEnum.Red)
end

-- Применение недуга на тело
HexLib.IAffliction.GiveAffliction(character, nil, "burn", 10)

-- Поиск предмета по идентификатору в инвентаре
local oxy = HexLib.IItem.FindItemByIdentifier(character, "oxygentank")

-- Проверка тега/идентификатора у предмета
if oxy and hexlib.IItem.HasIdentifierOrTags(oxy, {"oxygensource", "tank"}) then
  HexLib.IChat.PrintChat("Инвентарь", "Найден источник кислорода", Color(255,255,255,255))
end
```

## Структура модуля

Модуль возвращает таблицу с неймспейсами: `IAffliction`, `ITable`, `IChat`, `IItem`, `IEnum`, `IGame`.

```lua
local hexlib = require("hexlib")
-- пример: hexlib.IChat.PrintChat(...)
```

## Перечисления IEnum

```lua
--- Константы для обращения к слотам экипировки.​
IEnum.InvSlotType: None=0, Any=1, LeftHand=4, RightHand=2, Head=8, InnerClothes=16, OuterClothes=32, Headset=64, Card=128, Bag=256, HealthInterface=512
```

```lua
--- Шаблоны цветного текста в чате
IEnum.Color: готовые RGBA‑цвета Color(r,g,b,a): Red, Green, Blue, Yellow, Cyan, Magenta, White, Black, Orange, Gray, LightGray, DarkGray
```

Пример:

```lua
hexlib.IChat.PrintChat("Система", "Осторожно!", hexlib.IEnum.Color.Yellow)
```

## API

### IAffliction

Класс для работы с аффликшенами.

| Метод         | Значение      | Описание        |
| ------------- | ------------- | -------------   |
| HasAffliction(character, affliction) | boolean | Проверяет наличие недуга по идентификатору у персонажа |
| GiveAffliction(character, limb, identifier, strength) | true|nil | Применяет аффликшен к конечности или телу: при отсутствии limb накладывает на тело (LimbType.Body) |

### Примеры

```lua
-- Проверка кровотечения
if hexlib.IAffliction.HasAffliction(character, "bleeding") then ... end

-- Наложить ожог на тело
hexlib.IAffliction.GiveAffliction(character, nil, "burn", 15)
```

### ITable

Класс для работы со структурой таблиц языка Lua.

| Метод | Значение | Описание |
| ----- | ----- | ----- |
| IsInTable(array, value) | boolean | Проверяет наличие значения в массиве |
| RemoveElementByName(array, value) | - | Удаляет первое вхождение значения из массива |
| ClearTable(array) | - | Очищает массив в обратном цикле от #array до 1 |

### IChat

Игровой чат и отправка сообщений всем игрокам или отдельным клиентам.

| Метод | Значение | Описание |
| ----- | ----- | ----- |
| PrintChat(message, title, color?) | - | Вывод сообщения в чат; по умолчанию белый цвет из IEnum.Color.White |
| DMClient(client, title, message, color?) | - | Личное сообщение конкретному клиенту на сервере; при отсутствии SERVER вызывается PrintChat |
| SendMessageToAll(messageAuthor, message, color?) | - | Пересылает сообщение всем клиентам на сервере |
