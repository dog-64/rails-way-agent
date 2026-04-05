#!/bin/bash

# Rails 8 Code Review Agent - Setup Script
# Устанавливает агента в ~/.claude/agents/rails8-review

set -e  # Остановка при ошибке

# Цвета для вывода
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m' # No Color

echo -e "${BLUE}╔════════════════════════════════════════════════════════════════╗${NC}"
echo -e "${BLUE}║      Rails 8 Code Review Agent - Installation                 ║${NC}"
echo -e "${BLUE}╚════════════════════════════════════════════════════════════════╝${NC}"
echo ""

# Проверка, что скрипт запущен из корня репозитория
if [ ! -f "rails-way-agent.md" ]; then
    echo -e "${RED}❌ Ошибка: rails-way-agent.md не найден${NC}"
    echo -e "${YELLOW}Запустите скрипт из корня репозитория rails-way-agent${NC}"
    exit 1
fi

# Определяем директорию установки
INSTALL_DIR="$HOME/.claude/agents/rails8-review"

echo -e "${BLUE}📁 Директория установки:${NC} $INSTALL_DIR"
echo ""

# Создаём директорию если её нет
if [ -d "$INSTALL_DIR" ]; then
    echo -e "${YELLOW}⚠️  Директория $INSTALL_DIR уже существует${NC}"
    read -p "Перезаписать? (y/N): " -n 1 -r
    echo
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        echo -e "${RED}Установка отменена${NC}"
        exit 0
    fi
    echo -e "${BLUE}🗑️  Удаляю старую версию...${NC}"
    rm -rf "$INSTALL_DIR"
fi

echo -e "${BLUE}📦 Создаю директорию...${NC}"
mkdir -p "$INSTALL_DIR"

# Копируем файлы
echo -e "${BLUE}📋 Копирую файлы агента...${NC}"

# Основной файл агента
cp rails-way-agent.md "$INSTALL_DIR/"
echo -e "${GREEN}  ✓${NC} rails-way-agent.md"

echo ""
echo -e "${GREEN}✅ Установка агента завершена!${NC}"
echo ""

# Настройка глобальных hooks
echo -e "${BLUE}⚙️  Настройка глобальных hooks...${NC}"
echo ""

GLOBAL_SETTINGS="$HOME/.claude/settings.json"
HOOKS_CONFIG=$(cat <<'HOOKS_EOF'
{
  "PostToolUse": [
    {
      "matcher": "Write|Edit",
      "hooks": [
        {
          "type": "command",
          "command": "file=$(cat | jq -r '.tool_input.file_path // empty' 2>/dev/null); [[ \"$file\" == *.rb ]] || [[ \"$file\" == *Gemfile ]] && echo '📋 Rails 8: Consider running /agent rails8-review' || true"
        }
      ]
    }
  ]
}
HOOKS_EOF
)

# Создаём ~/.claude директорию если её нет
mkdir -p "$HOME/.claude"

# Проверяем есть ли jq
if ! command -v jq &> /dev/null; then
    echo -e "${YELLOW}⚠️  jq не найден, не удалось настроить hooks${NC}"
    echo -e "${BLUE}Установите jq: brew install jq${NC}"
    echo ""
    echo -e "${BLUE}Или добавьте это вручную в $GLOBAL_SETTINGS:${NC}"
    echo "$HOOKS_CONFIG" | sed 's/^/  /'
    echo ""
else
    # Проверяем существование файла settings.json
    if [ ! -f "$GLOBAL_SETTINGS" ]; then
        echo -e "${BLUE}📝 Создаю $GLOBAL_SETTINGS...${NC}"
        echo "{\"hooks\": $HOOKS_CONFIG}" | jq '.' > "$GLOBAL_SETTINGS"
        echo -e "${GREEN}  ✓${NC} Глобальные hooks установлены"
    else
        # Проверяем, не установлен ли уже наш hook
        if grep -q "rails8-review" "$GLOBAL_SETTINGS" 2>/dev/null; then
            echo -e "${YELLOW}⚠️  Hook для rails8-review уже установлен${NC}"
            echo -e "${GREEN}  ✓${NC} Пропускаю добавление hooks"
        else
            echo -e "${BLUE}📝 Обновляю $GLOBAL_SETTINGS...${NC}"
            TEMP_FILE=$(mktemp)

            if jq -e '.hooks.PostToolUse' "$GLOBAL_SETTINGS" > /dev/null 2>&1; then
                # Есть PostToolUse - добавляем в массив
                jq ".hooks.PostToolUse += ($HOOKS_CONFIG | .PostToolUse)" "$GLOBAL_SETTINGS" > "$TEMP_FILE"
            elif jq -e '.hooks' "$GLOBAL_SETTINGS" > /dev/null 2>&1; then
                # Есть hooks, но нет PostToolUse
                jq ".hooks += $HOOKS_CONFIG" "$GLOBAL_SETTINGS" > "$TEMP_FILE"
            else
                # Нет hooks вообще
                jq ". + {\"hooks\": $HOOKS_CONFIG}" "$GLOBAL_SETTINGS" > "$TEMP_FILE"
            fi

            mv "$TEMP_FILE" "$GLOBAL_SETTINGS"
            echo -e "${GREEN}  ✓${NC} Hooks добавлены"
        fi
    fi
fi

echo ""

# Настройка разрешений в ~/.claude/settings.json
SETTINGS_FILE="$HOME/.claude/settings.json"

# Разрешения, необходимые агенту
# grep используется как самостоятельная команда при анализе кода
REQUIRED_PERMISSIONS=(
    'Bash(grep *)'
)

if [ -f "$SETTINGS_FILE" ]; then
    echo -e "${BLUE}Настройка разрешений инструментов...${NC}"

    SETTINGS_UPDATED=false

    for perm in "${REQUIRED_PERMISSIONS[@]}"; do
        # Проверяем, есть ли уже такое разрешение
        if ! jq -e --arg p "$perm" '.permissions.allow | index($p)' "$SETTINGS_FILE" > /dev/null 2>&1; then
            # Добавляем разрешение
            tmp=$(mktemp)
            jq --arg p "$perm" '.permissions.allow += [$p]' "$SETTINGS_FILE" > "$tmp" && mv "$tmp" "$SETTINGS_FILE"
            echo -e "${GREEN}  +${NC} Добавлено разрешение: ${perm}"
            SETTINGS_UPDATED=true
        else
            echo -e "${YELLOW}  o${NC} Уже разрешено: ${perm}"
        fi
    done

    if [ "$SETTINGS_UPDATED" = true ]; then
        echo -e "${GREEN}  Разрешения обновлены в ${SETTINGS_FILE}${NC}"
    else
        echo -e "${YELLOW}  Все разрешения уже настроены${NC}"
    fi
else
    echo -e "${YELLOW}Файл ${SETTINGS_FILE} не найден${NC}"
    echo -e "${YELLOW}   Добавьте вручную в permissions.allow:${NC}"
    for perm in "${REQUIRED_PERMISSIONS[@]}"; do
        echo -e "     \"${perm}\""
    done
fi

echo ""

# Проверяем наличие Claude CLI
if command -v claude &> /dev/null; then
    echo -e "${GREEN}✓ Claude CLI обнаружен${NC}"
    echo ""
    echo -e "${BLUE}🚀 Использование:${NC}"
    echo ""
    echo -e "  ${YELLOW}claude --include ~/.claude/agents/rails8-review/rails-way-agent.md \"Проверь контроллер на N+1 queries\"${NC}"
    echo ""
    echo -e "${BLUE}💡 Рекомендация:${NC} Добавьте alias в ~/.zshrc или ~/.bashrc:"
    echo ""
    echo -e "  ${YELLOW}alias rails-review='claude --include ~/.claude/agents/rails8-review/rails-way-agent.md'${NC}"
    echo ""
    echo -e "Затем используйте:"
    echo ""
    echo -e "  ${YELLOW}rails-review \"Проверь app/controllers/posts_controller.rb на Rails 8 best practices\"${NC}"
    echo ""
else
    echo -e "${YELLOW}⚠️  Claude CLI не найден${NC}"
    echo -e "${BLUE}Установите Claude CLI:${NC} https://docs.anthropic.com/claude/docs/claude-code"
    echo ""
fi

echo -e "${BLUE}╔════════════════════════════════════════════════════════════════╗${NC}"
echo -e "${BLUE}║      ✨ Rails 8 Code Review Agent готов к работе!             ║${NC}"
echo -e "${BLUE}╚════════════════════════════════════════════════════════════════╝${NC}"
echo ""
echo -e "${GREEN}✅ Что было сделано:${NC}"
echo -e "  • Агент установлен в: $INSTALL_DIR"
echo -e "  • Глобальные hooks настроены в: $GLOBAL_SETTINGS"
echo -e "  • Ruby/Rails файлы будут предлагать запуск агента"
echo ""
echo -e "${BLUE}💡 Tip:${NC} Hooks работают во ВСЕХ Rails проектах на вашей машине!"
