# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

This repository contains a custom Claude Code agent configuration (`rails-way-agent.md`) that implements a specialized Rails 8 code review agent. The agent is designed to review Rails code against modern best practices from "The Rails 8 Way".

## What This Project Does

The `rails-way-agent.md` file defines a custom agent that:
- Reviews Rails 8 code against contemporary best practices
- Checks for modern Rails 8 features (Solid Queue, Solid Cache, Solid Cable, Kamal 2)
- Validates authentication patterns (Rails 8 built-in authentication vs. Devise)
- Reviews Turbo 8 and Hotwire usage
- Analyzes database queries for N+1 problems and optimization
- Checks security implementations (CSP, credentials, encryption, rate limiting)
- Validates testing approaches for Rails 8
- Provides actionable recommendations in Russian

## File Structure

```
rails-way-agent/
├── CLAUDE.md                 # This file
├── rails-way-agent.md        # Custom agent definition for Rails 8 review
└── .idea/                    # IDE configuration (JetBrains)
```

## Key Concepts & Architecture

### Agent Definition Format

The `rails-way-agent.md` file uses Claude Code's custom agent format:
- **Frontmatter** (lines 1-6): YAML metadata containing:
  - `name`: Agent identifier
  - `description`: What the agent does and when to use it
  - `tools`: Which tools the agent has access to (Bash, Read, Write, Grep, Glob)
  - `model`: LLM model to use (sonnet)

- **Content**: System prompt instructions that define the agent's behavior, knowledge, and review priorities

### Review Priorities

The agent uses a tiered approach:

1. **CRITICAL**: Authentication issues, N+1 queries, outdated gems (devise, sidekiq), unsafe parameter handling
2. **HIGH**: Missing Turbo integration, inefficient database queries, lack of caching, improper background jobs
3. **MEDIUM**: Missing rate limiting, incomplete Rails 8 features, outdated testing approaches
4. **LOW**: Refactoring opportunities, performance improvements

### Key Rails 8 Patterns Reviewed

- **No PaaS Architecture**: Solid Queue, Solid Cache, Solid Cable, Kamal 2, Thruster
- **Authentication**: Built-in `has_secure_password`, sessions in database, Current attributes pattern
- **Frontend**: Turbo 8 (streams, frames, morphing), Hotwire integration
- **Jobs**: Solid Queue with retry policies and priority queues
- **Database**: Advanced PostgreSQL types, query logs, strict_loading, composite primary keys
- **Caching**: Russian doll caching, fragment caching, cache invalidation strategies
- **Security**: CSP, credentials management, database encryption, rate limiting, permissions policy

## Common Development Tasks

### Running the Agent

Use the custom agent for Rails code reviews:

```bash
# Use within Claude Code
# This invokes the rails8-review agent
```

### Modifying the Agent

To update the Rails 8 review agent:
1. Edit `rails-way-agent.md` directly
2. Update the system prompt in the content section to change review criteria
3. Modify the tools available if needed (currently: Bash, Read, Write, Grep, Glob)
4. Adjust the model if necessary (currently: sonnet for balance of speed and quality)

### Adding New Review Rules

When adding new patterns to review:
1. Add the pattern detection logic to the appropriate section
2. Include both the anti-pattern (❌) and correct pattern (✅)
3. Provide concrete code examples
4. Classify the priority level
5. Document in the "Команды для проверки кода" (code check commands) section

## Important Notes

- All documentation and code examples in the agent are in Russian
- The agent is designed to be used PROACTIVELY during code review and refactoring
- When modifying the agent, maintain consistency with the existing Russian language format
- The agent references "The Rails 8 Way" by Obie Fernandez as the source material
- Review the agent's inspection commands regularly to ensure they still match the codebase structure

## References

- [Rails 8 Release Notes](https://edgeguides.rubyonrails.org/8_0_release_notes.html)
- [Solid Queue](https://github.com/rails/solid_queue)
- [Turbo Handbook](https://turbo.hotwired.dev/handbook/introduction)
- [Rails Security Guide](https://guides.rubyonrails.org/security.html)
