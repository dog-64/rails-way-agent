# CLAUDE.md

Инструкции для Claude Code при работе с этим репозиторием.

## О проекте

Кастомный агент Claude Code для проверки Rails 8 кода по стандартам "The Rails 8 Way".

## Структура

```
rails-way-agent/
├── rails-way-agent.md     # Определение агента (frontmatter + system prompt)
├── setup.sh               # Скрипт установки
├── README.md              # Документация
├── CLAUDE.md              # Этот файл
└── LICENSE                # MIT лицензия
```

## Формат агента

Файл `rails-way-agent.md` содержит:

**Frontmatter (YAML):**
- `name`: rails8-review
- `description`: Когда и зачем использовать агента
- `tools`: Bash, Read, Write, Grep, Glob
- `model`: sonnet

**System prompt:** Инструкции, примеры кода, команды проверки.

## Приоритеты проверки

1. **КРИТИЧНО:** Аутентификация, N+1, устаревшие gem (devise, sidekiq), permit!
2. **ВЫСОКИЙ:** Нет Turbo, плохие запросы БД, нет кэширования
3. **СРЕДНИЙ:** Нет rate limiting, устаревшие тесты
4. **НИЗКИЙ:** Рефакторинг, оптимизация

## Разработка

### Изменение агента

1. Редактируй `rails-way-agent.md`
2. Добавляй примеры: anti-pattern (❌) и correct pattern (✅)
3. Указывай приоритет проблемы
4. Добавляй команды проверки в секцию grep/find

### Тестирование

```bash
./setup.sh  # Переустановит агента
```

## Ссылки

- [Rails 8 Release Notes](https://edgeguides.rubyonrails.org/8_0_release_notes.html)
- [Solid Queue](https://github.com/rails/solid_queue)
- [Turbo Handbook](https://turbo.hotwired.dev/handbook/introduction)
