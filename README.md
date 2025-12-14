# Rails 8 Code Review Agent

Специализированный агент Claude Code для проверки Rails 8 кода на соответствие современным лучшим практикам из **"The Rails 8 Way"** by Obie Fernandez.

## 🎯 Назначение

Этот проект содержит настраиваемый агент Claude Code (`rails-way-agent.md`), который автоматически проверяет Rails приложения на:

- ✅ Использование новых фич Rails 8 (Solid Queue, Solid Cache, Solid Cable, Kamal 2)
- ✅ Современные паттерны аутентификации (встроенная `has_secure_password` вместо Devise)
- ✅ Правильное использование Turbo 8 и Hotwire
- ✅ Оптимизацию БД запросов (N+1, индексы, PostgreSQL типы)
- ✅ Стратегии кэширования (Russian Doll, fragment caching)
- ✅ Безопасность (CSP, credentials, encryption, rate limiting)
- ✅ Качество тестов (system tests, job tests, request specs)

## 📁 Структура проекта

```
rails-way-agent/
├── README.md                     # Этот файл
├── CLAUDE.md                     # Инструкции для Claude Code
├── rails-way-agent.md            # Определение кастомного агента
└── .idea/                        # IDE конфигурация (JetBrains)
```

## 🚀 Использование

### Установка агента

Агент уже определён в файле `rails-way-agent.md`. Чтобы использовать его:

1. Скопируйте `rails-way-agent.md` в папку `.claude/agents/` вашего Rails проекта:
   ```bash
   mkdir -p .claude/agents/
   cp rails-way-agent.md .claude/agents/
   ```

2. Используйте агента в Claude Code с помощью команды `/agent rails8-review` или вызовите его по названию

### Примеры использования

**Полный аудит проекта:**
```
Проверь проект на соответствие Rails 8 best practices
```

**Проверка конкретного файла:**
```
Проверь app/controllers/posts_controller.rb на использование Rails 8 паттернов
```

**Поиск конкретных проблем:**
```
Найди все N+1 queries в контроллерах
Проверь использование Turbo в views
Найди устаревшие gem (devise, sidekiq)
```

## 🔍 Что проверяет агент

### 🔴 Критичные проблемы

- Отсутствие или неправильная аутентификация
- N+1 запросы без оптимизации
- Использование устаревших gem (devise, sidekiq, resque)
- Небезопасное использование параметров (permit!)

### 🟡 Высокий приоритет

- Отсутствие Turbo интеграции
- Неэффективные БД запросы
- Отсутствие кэширования
- Неправильное использование background jobs

### 🟢 Средний и низкий приоритеты

- Отсутствие rate limiting
- Устаревшие подходы к тестированию
- Возможности для рефакторинга

## 📚 Ключевые темы Rails 8

### No PaaS Architecture
```ruby
# Solid Queue вместо Sidekiq
# Solid Cache вместо Memcached/Redis
# Solid Cable для websockets
# Kamal 2 для деплоя
```

### Встроенная аутентификация
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

## 🛠️ Модификация агента

Чтобы добавить новые правила проверки:

1. Отредактируйте `rails-way-agent.md`
2. Добавьте новую секцию в систем промпт
3. Включите примеры anti-pattern (❌) и correct pattern (✅)
4. Классифицируйте приоритет проблемы
5. Добавьте команду проверки в раздел "Команды для проверки кода"

## 📖 Документация

- **CLAUDE.md** — детальное описание архитектуры агента и концепций
- **rails-way-agent.md** — полное определение агента с примерами код

## 🔗 Полезные ссылки

- [Rails 8 Release Notes](https://edgeguides.rubyonrails.org/8_0_release_notes.html)
- [Solid Queue](https://github.com/rails/solid_queue)
- [Solid Cache](https://github.com/rails/solid_cache)
- [Turbo Handbook](https://turbo.hotwired.dev/handbook/introduction)
- [Rails Security Guide](https://guides.rubyonrails.org/security.html)

## 📝 Примеры отчётов

Агент предоставляет структурированные отчёты с примерами кода:

```
🔴 КРИТИЧНО: Использование устаревшего Devise
Файл: app/models/user.rb:1
Проблема: Используется gem 'devise' вместо встроенной has_secure_password
Рекомендация: Замените на встроенную аутентификацию Rails 8

🟡 ВНИМАНИЕ: Потенциальная N+1 проблема
Файл: app/views/posts/index.html.erb:8
Проблема: @posts.each без includes(:comments)
Рекомендация: @posts = Post.includes(:comments).all
```

## 🤝 Авторство

- **Основана на:** The Rails 8 Way by Obie Fernandez
- **Язык документации:** Русский
- **Интеграция:** Claude Code agent format

## 📄 Лицензия

Этот проект предоставляется в образовательных целях для использования с Claude Code.

---

**Последнее обновление:** 2025-12-14
