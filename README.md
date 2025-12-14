# Rails 8 Code Review Agent

Агент Claude Code для проверки Rails 8 кода. Основан на книге "The Rails 8 Way" от Obie Fernandez.

## Что делает

Проверяет Rails приложения на:

- Новые фичи Rails 8: Solid Queue, Solid Cache, Solid Cable, Kamal 2
- Аутентификацию: встроенная `has_secure_password` вместо Devise
- Turbo 8 и Hotwire
- N+1 запросы, индексы БД, типы PostgreSQL
- Кэширование: Russian Doll, fragment caching
- Безопасность: CSP, credentials, encryption, rate limiting
- Тесты: system tests, job tests, request specs

## Структура проекта

```
rails-way-agent/
├── README.md              # Документация
├── CLAUDE.md              # Инструкции для Claude Code
├── rails-way-agent.md     # Определение агента
├── setup.sh               # Скрипт установки
└── LICENSE                # MIT лицензия
```

## Установка

### Автоматическая (рекомендуется)

```bash
git clone https://github.com/dog-64/rails-way-agent.git
cd rails-way-agent
./setup.sh
```

Скрипт:
- Копирует агента в `~/.claude/agents/rails8-review/`
- Настраивает глобальные hooks для .rb файлов
- Проверяет наличие Claude CLI

### Ручная

```bash
mkdir -p ~/.claude/agents/rails8-review/
cp rails-way-agent.md ~/.claude/agents/rails8-review/
```

## Использование

В Claude Code вызовите агента командой `/agent rails8-review`.

### Примеры

**Аудит всего проекта:**
```
Проверь проект на соответствие Rails 8 best practices
```

**Проверка файла:**
```
Проверь app/controllers/posts_controller.rb на Rails 8 паттерны
```

**Поиск проблем:**
```
Найди все N+1 queries в контроллерах
Проверь Turbo в views
Найди устаревшие gem (devise, sidekiq)
```

## Что проверяет

### Критичные проблемы

- Отсутствие или неправильная аутентификация
- N+1 запросы без оптимизации
- Устаревшие gem: devise, sidekiq, resque
- Небезопасные параметры: `permit!`

### Высокий приоритет

- Отсутствие Turbo интеграции
- Неэффективные БД запросы
- Отсутствие кэширования
- Неправильные background jobs

### Средний и низкий приоритеты

- Отсутствие rate limiting
- Устаревшие подходы к тестированию
- Возможности для рефакторинга

## Ключевые темы Rails 8

### No PaaS Architecture

Деплой без Heroku — на своих серверах:

```ruby
# Solid Queue вместо Sidekiq
# Solid Cache вместо Memcached/Redis
# Solid Cable для websockets
# Kamal 2 для деплоя
```

### Встроенная аутентификация

Devise больше не нужен:

```ruby
class User < ApplicationRecord
  has_secure_password
  has_many :sessions, dependent: :destroy
  normalizes :email_address, with: ->(e) { e.strip.downcase }
end
```

### Turbo Streams для real-time обновлений

```erb
<%= turbo_stream.append "messages", @message %>
<%= turbo_stream.replace "form", partial: "form" %>
```

### Advanced Database Features

- Virtual columns и generated columns
- Composite primary keys
- PostgreSQL JSONB, ranges, arrays
- Query logs для отладки

### Russian Doll Caching

```erb
<% cache @product do %>
  <%= render @product %>
  <% cache [@product, "reviews"] do %>
    <%= render @product.reviews %>
  <% end %>
<% end %>
```

## Как изменить агента

Добавьте новые правила проверки:

1. Откройте `rails-way-agent.md`
2. Добавьте секцию в систем промпт
3. Покажите anti-pattern (❌) и correct pattern (✅)
4. Укажите приоритет проблемы
5. Добавьте команду проверки в раздел "Команды для проверки кода"

## Документация

- **CLAUDE.md** — архитектура агента и концепции
- **rails-way-agent.md** — полное определение агента с примерами

## Полезные ссылки

- [Rails 8 Release Notes](https://edgeguides.rubyonrails.org/8_0_release_notes.html)
- [Solid Queue](https://github.com/rails/solid_queue)
- [Solid Cache](https://github.com/rails/solid_cache)
- [Turbo Handbook](https://turbo.hotwired.dev/handbook/introduction)
- [Rails Security Guide](https://guides.rubyonrails.org/security.html)

## Примеры отчётов

Агент показывает проблемы с примерами кода:

```
КРИТИЧНО: Устаревший Devise
Файл: app/models/user.rb:1
Проблема: Используется gem 'devise' вместо has_secure_password
Рекомендация: Замените на встроенную аутентификацию Rails 8

ВНИМАНИЕ: Потенциальная N+1 проблема
Файл: app/views/posts/index.html.erb:8
Проблема: @posts.each без includes(:comments)
Рекомендация: @posts = Post.includes(:comments).all
```

## Авторство

- **Основан на:** The Rails 8 Way by Obie Fernandez
- **Язык документации:** Русский
- **Интеграция:** Claude Code agent format

## Лицензия

Образовательный проект для Claude Code.

---

**Последнее обновление:** 2025-12-14
