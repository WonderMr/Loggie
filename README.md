# Loggie
Детальное логгирование изменений данных в 1С
# Что это?
Расширение для платформы 1С (с режимом совместимости не менее 8.3.11), детализируещее изменение данных данных констант, справочников, документов, регистров сведений и накоплений.
Для каждого изменения объекта или поля его Табличной Части запоминается состояние до и после, при условии их наличия.
# Для чего это?
Чтобы разбор того, кто накосячил с документами, всегда завершался за минуты.

# Как это работает?
Через механизм 1С подписка на события. Включено 5 подписок перед записью для всех перечисленных объектов. И перед записью мы узнаём, что же меняется.
Изменения связанных объектов привязываются к регистратору, при проведении. Таким образом, по проведённому документ мы сможем увидеть и все движения по регистрам, которые он породил.
# Как мне получить?
1. Нужно зайти в Releases
2. Скачать там последнее расширение
3. Встроить его в режиме конфигуратора в свою базу 1С
4. Включить безопасный режим

# Как использовать?
После включения расширения никаких дополнительных действий не нужно!
В событиях журнала регистрации появится новое - Лог. Изменение данных.
Используйте его для отбора.