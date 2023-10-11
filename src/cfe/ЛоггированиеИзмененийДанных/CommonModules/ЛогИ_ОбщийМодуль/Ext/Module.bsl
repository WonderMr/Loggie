﻿Функция ЕстьСвойство(Переменная, ИмяСвойства)
    СтруктураПроверка                               =   Новый Структура;
    СтруктураПроверка.Вставить(ИмяСвойства, NULL);
    ЗаполнитьЗначенияСвойств(СтруктураПроверка, Переменная);
    Возврат ?(СтруктураПроверка[ИмяСвойства] = NULL, Ложь, Истина)
КонецФункции

Функция ЕстьПользователь()
    Если
        ЗначениеЗаполнено(ПараметрыСеанса.ТекущийПользователь)
    Тогда
        Возврат Истина
    Иначе
        Возврат Ложь
    КонецЕсли;
КонецФункции

Функция ОбработатьОшибку(Ошибка, Источник, ЧтоИзменилось)
    Событие                                         =   "Лог. Изменение Данных";
    ТекстОшибки                                     =   СокрЛП(Ошибка.Описание) + " : " + СокрЛП(?(Ошибка.Причина = Неопределено,"", Ошибка.Причина.Описание)) + Символы.ПС
                                                    +   "Имя модуля : " + СокрЛП(Ошибка.ИмяМодуля) + Символы.ПС
                                                    +   "Номер строки : " + СокрЛП(Ошибка.НомерСтроки) + Символы.ПС
                                                    +   "Исходная строка : " + СокрЛП(Ошибка.ИсходнаяСтрока) + Символы.ПС
                                                    +   "Накопленные изменения : " + ЧтоИзменилось;
    ЗаписьЖурналаРегистрации(Событие,
                            УровеньЖурналаРегистрации.Ошибка,
                            Источник.Метаданные(),
                            Источник,
                            ТекстОшибки,
                            РежимТранзакцииЗаписиЖурналаРегистрации.Независимая);
    Возврат ТекстОшибки;
КонецФункции

Процедура ЗаписатьИзменения(ЧтоИзменилось, Источник)
    Если
        Не ЗначениеЗаполнено(ЧтоИзменилось)
    Тогда
        Возврат
    КонецЕсли;
    ТипИсточника                                    =   Строка(ТипЗнч(Источник));
    Если
        СтрНачинаетсяС(ТипИсточника,"Справочник объект:")
    Или СтрНачинаетсяС(ТипИсточника,"Документ объект:")
    Тогда
        Если
            ЕстьСвойство(Источник, "Ссылка")
        Тогда
            Если
                ЗначениеЗаполнено(Источник.Ссылка)
            Тогда
                Данные                              =   Источник.Ссылка;
            Иначе
                Данные                              =   Источник.ЭтотОбъект;
            КонецЕсли;
        КонецЕсли;
    ИначеЕсли
        СтрНачинаетсяС(ТипИсточника,"Регистр сведений набор записей:")
    Или СтрНачинаетсяС(ТипИсточника,"Регистр накопления набор записей:")
    Тогда
        Если
            ЕстьСвойство(Источник, "ЭтотОбъект")
        Тогда
            Если
                ЕстьСвойство(Источник.ЭтотОбъект, "Отбор")
            Тогда
                Если
                    ЕстьСвойство(Источник.ЭтотОбъект.Отбор, "Регистратор")
                Тогда
                    Если
                        ЕстьСвойство(Источник.ЭтотОбъект.Отбор.Регистратор, "Значение")
                    Тогда
                        Попытка
                            Данные                  =   Источник.ЭтотОбъект.Отбор.Регистратор.Значение;
                        Исключение
                            Инфо                    =   ИнформацияОбОшибке();
                            ДанныеОшибки            =   "Описание='" + Инфо.Описание +
                                                        "' ИмяМодуля='" + Инфо.ИмяМодуля +
                                                        "' НомерСтроки=" + Инфо.НомерСтроки;
                            Данные                  =   "Не удалось получить данные по причине: " + ДанныеОшибки;
                        КонецПопытки;
                    КонецЕсли;
                ИначеЕсли
                    Источник.ЭтотОбъект.Отбор.Количество()>0
                Тогда
                    Для Каждого Отбор
                    Из          Источник.ЭтотОбъект.Отбор
                    Цикл
                        Если
                            ЕстьСвойство(Отбор, "Значение")
                        Тогда
                            Если
                                ЗначениеЗаполнено(Отбор.Значение)
                            Тогда
                                ТипЗначения         =   ТипЗнч(Отбор.Значение);
                                Если
                                    Не ТипЗначения = Тип("Число")
                                И   Не ТипЗначения = Тип("Строка")
                                И   Не ТипЗначения = Тип("Дата")
                                И   Не ТипЗначения = Тип("UUID")
                                И   Не ТипЗначения = Тип("Булево")
                                И   Не ТипЗначения = Тип("Структура")
                                И   Не ТипЗначения = Тип("Соответствие")
                                И   Не ТипЗначения = Тип("Массив")
                                Тогда
                                    Данные         =   Отбор.Значение;
                                    Прервать;
                                Иначе
                                    Данные         =   "";
                                КонецЕсли;
                            КонецЕсли;
                        КонецЕсли;
                    КонецЦикла;
                КонецЕсли;
            КонецЕсли;
        Иначе
            Данные                                  =   "Неопределено";
        КонецЕсли;
    ИначеЕсли
        СтрНачинаетсяС(ТипИсточника, "Константа менеджер значения:")
    Тогда
        Данные                                      =   Источник;
    Иначе
        Данные                                      =   "Неопределено";
    КонецЕсли;
    ЗаписьЖурналаРегистрации(   "Лог. Изменение Данных",
                                УровеньЖурналаРегистрации.Информация,
                                Источник.Метаданные(),
                                Данные,
                                ЧтоИзменилось,
                                РежимТранзакцииЗаписиЖурналаРегистрации.Независимая);
КонецПроцедуры

Функция ПолучитьКолонкиТЧ(ТЧ)
    Колонки                                         =   "";
    Для Каждого Колонка
    Из          ТЧ.Колонки
    Цикл
        Если
            Не Колонка.Имя = "Вспом"
        И   Не Колонка.Имя = "НомерСтроки"
        Тогда
            Колонки                                 =   Колонки + Колонка.Имя + ",";
        КонецЕсли;
    КонецЦикла;
    Возврат Новый Структура("Массив, Строка",
                            СтрРазделить(Колонки, ",", Ложь),
                            Лев(Колонки, СтрДлина(Колонки) - 1));
КонецФункции

Функция ПолучитьИзмененияТЧ(СтараяТЧ, НоваяТЧ, ТЧИмя)
    ЧтоИзменено                                     =   "";
    Колонки                                         =   ПолучитьКолонкиТЧ(СтараяТЧ).Массив;
    Если
        0 = НоваяТЧ.Количество()
    Тогда
        Для Каждого СтрТЧ
        Из          СтараяТЧ
        Цикл
            ЧтоИзменено                             =   ЧтоИзменено + "Удалена строка табличной части " + ТЧИмя + Символы.ПС;
            Для Каждого Колонка
            Из          Колонки
            Цикл
                НовыйРеквизит                       =   Строка(СтрТЧ[Колонка]);
                Если
                    ЗначениеЗаполнено(НовыйРеквизит)
                Тогда
                    ЧтоИзменено                     =   ЧтоИзменено + "Удален реквизит ТЧ " + Колонка + ", содержащий значение "
                                                    +   НовыйРеквизит + Символы.ПС;
                КонецЕсли;
            КонецЦикла;
        КонецЦикла;
    ИначеЕсли
        0 = СтараяТЧ.Количество()
    Тогда
        Для Каждого СтрТЧ
        Из          НоваяТЧ
        Цикл
            ЧтоИзменено                             =   ЧтоИзменено + "Добавлена строка табличной части " + ТЧИмя + Символы.ПС;
            Для Каждого Колонка
            Из          Колонки
            Цикл
                УдалённыйРеквизит                   =   Строка(СтрТЧ[Колонка]);
                Если
                    ЗначениеЗаполнено(УдалённыйРеквизит)
                Тогда
                    ЧтоИзменено                     =   ЧтоИзменено + "Добавлен реквизит ТЧ " + Колонка + ", содержащий значение "
                                                    +   УдалённыйРеквизит + Символы.ПС;
                КонецЕсли;
            КонецЦикла;
        КонецЦикла;
    Иначе
        КопияСтаройТЧ                               =   СтараяТЧ.Скопировать();
        Для Каждого СтрТЧ
        Из          СтараяТЧ
        Цикл
            ИндексН                                 =   НайтиИндексСтрокиВТЧ(СтрТЧ, НоваяТЧ);
            Если
                -1 = ИндексН
            Тогда
                //Строка была удалена
                ЧтоИзменено                         =   ЧтоИзменено + "Удалена строка табличной части " + ТЧИмя + Символы.ПС;
                Для Каждого Колонка
                Из          Колонки
                Цикл
                    УдалённоеЗначение               =   Строка(СтрТЧ[Колонка]);
                    Если
                        ЗначениеЗаполнено(УдалённоеЗначение)
                    Тогда
                        ЧтоИзменено                 =   ЧтоИзменено + "Удалён реквизит ТЧ " + Колонка + ", содержащий значение "
                                                    +   УдалённоеЗначение + Символы.ПС;
                    КонецЕсли;
                КонецЦикла;
            Иначе
                //Сравниваем старую и новую строки
                Для Каждого Колонка
                Из          Колонки
                Цикл
                    Если
                        Не СтрТЧ[Колонка] = НоваяТЧ[ИндексН][Колонка]
                    Тогда
                        Если
                            ЗначениеЗаполнено(Строка(СтрТЧ[Колонка]))
                        Тогда
                            НовоеЗначение           =   Строка(НоваяТЧ[ИндексН][Колонка]);
                            ЧтоИзменено             =   ЧтоИзменено + "Реквизит ТЧ " + Колонка
                                                    +   " Табличной части " + ТЧИмя
                                                    +   " изменился с " + Строка(СтрТЧ[Колонка])
                                                    +   " на " + ?(ЗначениеЗаполнено(НовоеЗначение), НовоеЗначение, "пусное значение") + Символы.ПС;
                        КонецЕсли;
                    КонецЕсли;
                КонецЦикла;
                //Нашли и сравнили
                Если
                    //Если в новой ТЧ больше записей
                    НоваяТЧ.Количество()>КопияСтаройТЧ.Количество()
                Тогда
                    //То удаляем одинаковые записи и из копии СтаройТЧ
                    ИндексO                         =   НайтиИндексСтрокиВТЧ(НоваяТЧ[ИндексН], КопияСтаройТЧ);
                    КопияСтаройТЧ.Удалить(ИндексO);
                КонецЕсли;
                //И из новой ТЧ
                НоваяТЧ.Удалить(ИндексН);
            КонецЕсли;
        КонецЦикла;
        //Здесь нам уже нужно использовать копию старой ТЧ
        СтараяТЧ                                    =   КопияСтаройТЧ.Скопировать();
        //Проходим по тем реквизитам, что есть в новой ТЧ и их нет в старой
        Для Каждого СтрТЧ
        Из          НоваяТЧ
        Цикл
            ИндексН                                 =   НайтиИндексСтрокиВТЧ(СтрТЧ, СтараяТЧ);
            Если
                //Они все должны прилететь сюда
                -1 = ИндексН
            Тогда
                ЧтоИзменено                         =   ЧтоИзменено + "Добавлена строка табличной части " + ТЧИмя + Символы.ПС;
                Для Каждого Колонка
                Из          Колонки
                Цикл
                    ЗначениеЭлемента                =   Строка(СтрТЧ[Колонка]);
                    Если
                        ЗначениеЗаполнено(ЗначениеЭлемента)
                    Тогда
                        ЧтоИзменено                 =   ЧтоИзменено + "Добавлен реквизит ТЧ " + Колонка + ", содержащий значение "
                                                    +   ЗначениеЭлемента + Символы.ПС;
                    КонецЕсли;
                КонецЦикла;
            Иначе
                ЧтоИзменено                         =   ЧтоИзменено + "Ошибка в логике" + ТЧИмя + Символы.ПС;
            КонецЕсли;
        КонецЦикла;
    КонецЕсли;
    Возврат ЧтоИзменено;
КонецФункции

Функция НайтиИндексСтрокиВТЧ(СНайти, ТЧ)
    Веса                                            =   Новый ТаблицаЗначений();
    Веса.Колонки.Добавить("Совпадений");
    Веса.Колонки.Добавить("Индекс");
    Колонки                                         =   ПолучитьКолонкиТЧ(ТЧ).Массив;
    T                                               =   0;
    Для Каждого СТЧ
    Из          ТЧ
    Цикл
        СтрокаТЗ                                    =   Веса.Добавить();
        СтрокаТЗ.Совпадений                         =   0;
        СтрокаТЗ.Индекс                             =   T;
        Для Каждого Колонка
        Из          Колонки
        Цикл
            Если
                ЗначениеЗаполнено(СНайти[Колонка])
            И   ЗначениеЗаполнено(СТЧ[Колонка])
            И   СНайти[Колонка] = СТЧ[Колонка]
            Тогда
                СтрокаТЗ.Совпадений                 =   СтрокаТЗ.Совпадений + 1;
            КонецЕсли;
        КонецЦикла;
        T                                           =   T + 1;
    КонецЦикла;
    Веса.Сортировать("Совпадений Убыв");
    Если
        Веса.Количество() = 1
    Тогда
        Возврат ?(Веса.Получить(0).Совпадений > 0, Веса.Получить(0).Индекс, -1)
    ИначеЕсли
        Веса.Количество() = 0
    Тогда
        Возврат -1;
    ИначеЕсли
        Веса.Получить(0).Совпадений = Веса.Получить(1).Совпадений
    Тогда
        Возврат -1;
    Иначе
        Возврат Веса.Получить(0).Индекс;
    КонецЕсли;
КонецФункции

Процедура ЛогИ_ОбъектПередЗаписью(Источник, Отказ) Экспорт
    Если
        Не ЕстьПользователь()
    Тогда
        Возврат;
    КонецЕсли;
    Событие                                         =   "Лог. Изменение Данных";
    Если
        Не Отказ
    Тогда
        Попытка
            ЧтоИзменилось                           =   "";
            СтарыйОбъект                            =   ?(ЕстьСвойство(Источник.ЭтотОбъект,"Ссылка"),Источник.ЭтотОбъект.Ссылка, Источник.ЭтотОбъект);
            НовыйОбъект                             =   Источник.ЭтотОбъект;
            ТипИсточника                            =   ТипЗнч(Источник);
            Если
                СтрНачинаетсяС(ТипИсточника, "Документ")
            Тогда
                Реквизиты                           =   ЗначенияСвойствДокумента(Источник);
            ИначеЕсли
                СтрНачинаетсяС(ТипИсточника, "Справочник")
            Тогда
                Реквизиты                           =   ЗначенияСвойствСправочника(Источник);
            КонецЕсли;
            Для Каждого Реквизит
            Из          Реквизиты
            Цикл
                Если
                    НЕ СтарыйОбъект[Реквизит] = НовыйОбъект[Реквизит]
                Тогда
                    Если
                        ЗначениеЗаполнено(СтарыйОбъект[Реквизит])
                    Тогда
                        НовыйРеквизит               =   Строка(НовыйОбъект[Реквизит]);
                        ЧтоИзменилось               =   ЧтоИзменилось + "Реквизит " + Строка(Реквизит)
                                                    +   " изменился с " + Строка(СтарыйОбъект[Реквизит])
                                                    +   " на " + ?(ЗначениеЗаполнено(НовыйРеквизит), НовыйРеквизит, "пустое значение") + Символы.ПС;
                    Иначе
                        НовыйРеквизит               =   Строка(НовыйОбъект[Реквизит]);
                        Если
                            ЗначениеЗаполнено(НовыйРеквизит)
                        Тогда
                            ЧтоИзменилось           =   ЧтоИзменилось + "Установлено новое значение Реквизита " + Строка(Реквизит)
                                                    +   " = " + НовыйРеквизит + Символы.ПС;
                        КонецЕсли;
                    КонецЕсли;
                КонецЕсли;
            КонецЦикла;
            Если
                ЕстьСвойство(Источник.ЭтотОбъект.Метаданные(), "ТабличныеЧасти")
            Тогда
                Для Каждого ТабличнаяЧасть
                Из          Источник.ЭтотОбъект.Метаданные().ТабличныеЧасти
                Цикл
                    СтараяТЧ                        =   СтарыйОбъект[ТабличнаяЧасть.Имя].Выгрузить();
                    НоваяТЧ                         =   НовыйОбъект[ТабличнаяЧасть.Имя].Выгрузить();
                    Если
                        Не (0   = СтараяТЧ.Количество()
                            И 0 = НоваяТЧ.Количество())
                    Тогда
                        ЧтоИзменилось               =   ЧтоИзменилось + ПолучитьИзмененияТЧ(СтараяТЧ, НоваяТЧ, ТабличнаяЧасть.Имя);
                    КонецЕсли;
                КонецЦикла;
            КонецЕсли;
            ЗаписатьИзменения(ЧтоИзменилось, Источник);
        Исключение
            Ошибка                                  =   ИнформацияОбОшибке();
            ОбработатьОшибку(Ошибка, Источник, ЧтоИзменилось);
        КонецПопытки;
    КонецЕсли;
КонецПроцедуры

Процедура ЛогИ_ДокументПередЗаписью(Источник, Отказ, РежимЗаписи, РежимПроведения) Экспорт
    ЛогИ_ОбъектПередЗаписью(Источник, Отказ);
    Если
        Не РежимЗаписи = РежимЗаписиДокумента.Запись
    Тогда
        ЗаписатьИзменения(Строка(РежимЗаписи), Источник);
    КонецЕсли;
КонецПроцедуры

Функция ЗначенияСвойствРегистра(Регистр)
    МассивСвойств                                   =   Новый Массив();
    Для Каждого Измерение
    Из          Регистр.Метаданные().Измерения
    Цикл
        МассивСвойств.Добавить(Измерение.Имя)
    КонецЦикла;
    Для Каждого Измерение
    Из          Регистр.Метаданные().СтандартныеРеквизиты
    Цикл
        МассивСвойств.Добавить(Измерение.Имя)
    КонецЦикла;
    Для Каждого Измерение
    Из          Регистр.Метаданные().Ресурсы
    Цикл
        МассивСвойств.Добавить(Измерение.Имя)
    КонецЦикла;
    Для Каждого Измерение
    Из          Регистр.Метаданные().Реквизиты
    Цикл
        МассивСвойств.Добавить(Измерение.Имя)
    КонецЦикла;
    Возврат МассивСвойств;
КонецФункции

Функция ЗначенияСвойствСправочника(Источник)
    МассивСвойств                                   =   Новый Массив();
    Для Каждого Реквизит
    Из          Источник.ЭтотОбъект.Метаданные().Реквизиты
    Цикл
        МассивСвойств.Добавить(Реквизит.Имя);
    КонецЦикла;
    Для Каждого Реквизит
    Из          Источник.ЭтотОбъект.Метаданные().СтандартныеРеквизиты
    Цикл
        МассивСвойств.Добавить(Реквизит.Имя);
    КонецЦикла;
    Возврат МассивСвойств;
КонецФункции

Функция ЗначенияСвойствДокумента(Источник)
    МассивСвойств                                   =   Новый Массив();
    Для Каждого Реквизит
    Из          Источник.ЭтотОбъект.Метаданные().Реквизиты
    Цикл
        МассивСвойств.Добавить(Реквизит.Имя);
    КонецЦикла;
    Для Каждого Реквизит
    Из          Источник.ЭтотОбъект.Метаданные().СтандартныеРеквизиты
    Цикл
        МассивСвойств.Добавить(Реквизит.Имя);
    КонецЦикла;
    Возврат МассивСвойств;
КонецФункции

Функция ПолучитьНовыеСвойствРегистра(Регистр, Префикс="Новый элемент регистра ")
    Если
        Регистр.ЭтотОбъект.Количество()
    Тогда
        ВернутьТекст                                =   Префикс + Символы.ПС;
        Для Каждого Элемент
        Из          Регистр.ЭтотОбъект
        Цикл
            Для Каждого Свойство
            Из          ЗначенияСвойствРегистра(Регистр)
            Цикл
                Попытка
                    ЗначениеЭлемента                =   Строка(Элемент[Свойство]);
                    Если
                        ЗначениеЗаполнено(ЗначениеЭлемента)
                    Тогда
                        ВернутьТекст                =   ВернутьТекст + Свойство + " = " + ЗначениеЭлемента + Символы.ПС;
                    КонецЕсли;
                Исключение
                    Ошибка                          =   ИнформацияОбОшибке();
                    ВернутьТекст                    =   ВернутьТекст + ОбработатьОшибку(Ошибка, Регистр, ВернутьТекст);
                КонецПопытки;
            КонецЦикла;
        КонецЦикла;
        Возврат ВернутьТекст
    Иначе
        Возврат ""
    КонецЕсли;
КонецФункции

Функция ПолучитьИзменениеСвойствРегистра(НРегистр, СТРегистр)
    ВернутьТекст                                    =   "";
    Если
        НРегистр.Количество() > СТРегистр.Количество()
    Тогда
        ВернутьТекст                                =   ПолучитьНовыеСвойствРегистра(НРегистр, "Добавлена запись регистра");
    ИначеЕсли
        НРегистр.Количество() < СТРегистр.Количество()
    Тогда
        ВернутьТекст                                =   ПолучитьНовыеСвойствРегистра(СТРегистр, "Удалена запись регистра");
    Иначе
        Для I=0
        По  НРегистр.Количество()-1
        Цикл
            Для Каждого Свойство
            Из          ЗначенияСвойствРегистра(НРегистр)
            Цикл
                Если
                    Не НРегистр[I][Свойство] = СТРегистр[I][Свойство]
                Тогда
                    ВернутьТекст                    =   ВернутьТекст + "Реквизит " + Свойство + " изменился с " + СТРегистр[I][Свойство] + " на "
                                                    +   ?(ЗначениеЗаполнено(НРегистр[I][Свойство]), НРегистр[I][Свойство], "пустое значение") + Символы.ПС;
                КонецЕсли;
            КонецЦикла;
        КонецЦикла;
    КонецЕсли;
    Возврат ВернутьТекст
КонецФункции

Процедура ЛогИ_РегистрПередЗаписью(Источник, Отказ, Замещение) Экспорт
    Если
        Не ЕстьПользователь()
    Тогда
        Возврат;
    КонецЕсли;
    Если
        Не Отказ
    Тогда
        Событие                                     =   "Лог. Изменение Регистров";
        Попытка
            Если
                Замещение
            Тогда
                ЧтоИзменилось                       =   "";
                НовыйОбъект                         =   Источник.ЭтотОбъект;
                Если
                    СтрНайти(Тип(Источник), "Регистр накопления")>0
                Тогда
                    Регистр                         =   РегистрыНакопления[Источник.ЭтотОбъект.Метаданные().Имя].СоздатьНаборЗаписей();
                ИначеЕсли
                    СтрНайти(Тип(Источник), "Регистр сведений")>0
                Тогда
                    Регистр                         =   РегистрыСведений[Источник.ЭтотОбъект.Метаданные().Имя].СоздатьНаборЗаписей();
                КонецЕсли;
                Если
                    Не Неопределено = Регистр
                Тогда
                    Для Каждого ЭлементОтбора
                    Из          НовыйОбъект.Отбор
                    Цикл
                        Регистр.Отбор[ЭлементОтбора.Имя].Установить(ЭлементОтбора.Значение);
                    КонецЦикла;
                    Регистр.Прочитать();
                    Если
                        Регистр.ЭтотОбъект.Количество() = 0
                    Тогда
                        ЧтоИзменилось               =   ПолучитьНовыеСвойствРегистра(Источник.ЭтотОбъект);
                    Иначе
                        ЧтоИзменилось               =   ПолучитьИзменениеСвойствРегистра(Источник.ЭтотОбъект, Регистр.ЭтотОбъект);
                    КонецЕсли
                КонецЕсли;
            Иначе
                ЧтоИзменилось                       =   ПолучитьНовыеСвойствРегистра(Источник.ЭтотОбъект);
            КонецЕсли;
            ЗаписатьИзменения(ЧтоИзменилось, Источник);
        Исключение
            Ошибка                                  =   ИнформацияОбОшибке();
            ОбработатьОшибку(Ошибка, Источник, ЧтоИзменилось);
        КонецПопытки;
    КонецЕсли;
КонецПроцедуры

Процедура ЛогИ_РегистрРасчетаНаборЗаписейПередЗаписью(Источник, Отказ, Замещение, ТолькоЗапись, ЗаписьФактическогоПериодаДействия, ЗаписьПерерасчетов) Экспорт
    ЛогИ_РегистрПередЗаписью(Источник, Отказ, Замещение);
КонецПроцедуры

Процедура ЛогИ_КонстантаМенеджерЗначенияПередЗаписью(Источник, Отказ) Экспорт
    Если
        Не ЕстьПользователь()
    Тогда
        Возврат;
    КонецЕсли;
    Событие                                         =   "Лог. Изменение Данных";
    Если
        Не Отказ
    Тогда
        ЧтоИзменилось                               =   "";
        Попытка
            ЧтоИзменилось                           =   "Значение изменилось с " + Строка(Константы[Источник.Метаданные().Имя].Получить())
                                                    +   " на " + Строка(Источник.Значение);
            ЗаписатьИзменения(ЧтоИзменилось, Источник);
        Исключение
            Ошибка                                  =   ИнформацияОбОшибке();
            ОбработатьОшибку(Ошибка, Источник, ЧтоИзменилось);
        КонецПопытки;
    КонецЕсли;
КонецПроцедуры

