# BackendForge

An interview preparation guide for senior backend engineers. Browse questions by topic, practice coding exercises, run mock interviews, and track your progress locally.

Built with Rails, Hotwire, and SQLite.

## Requirements

- Ruby **3.3.2** (see [`.ruby-version`](.ruby-version))
- Bundler
- SQLite 3
- Node is **not** required (importmap + Tailwind via Ruby gems)

## Quick start

Clone the repository, then from the project root:

```bash
bin/setup
bin/rails db:seed
bin/dev
```

Open [http://127.0.0.1:3000](http://127.0.0.1:3000).

`bin/setup` installs gems and prepares the database. `db:seed` loads the interview content into SQLite. `bin/dev` starts the Rails server and Tailwind CSS watcher together.

## Manual setup

If you prefer to run each step yourself:

```bash
# Use the Ruby version from .ruby-version (rbenv, asdf, etc.)
bundle install
bin/rails db:prepare
bin/rails db:seed
bin/dev
```

To run only the web server (without live CSS rebuilds):

```bash
bin/rails server
```

Precompile Tailwind once if you are not using `bin/dev`:

```bash
bin/rails tailwindcss:build
```

## Reseeding content

To wipe and reload all interview content:

```bash
bin/rails content:seed
```

This is the same data load as `db:seed`, but useful when you are iterating on content generators.

## Running tests

```bash
bin/rails db:test:prepare test test:system
```

## Environment notes

- **Database:** SQLite files live under `storage/` and are gitignored.
- **Production secret:** Set `SECRET_KEY_BASE` when deploying (generate with `bin/rails secret`). Development and test use fixed local keys in their environment configs.
- **Docker:** A production-oriented `Dockerfile` is included. Pass `SECRET_KEY_BASE` at runtime when running a container.

## Project layout

| Path | Purpose |
|------|---------|
| `app/` | Controllers, views, Stimulus controllers |
| `lib/content/` | Question banks and content seeders |
| `config/` | Rails configuration |
| `db/` | Migrations and schema |

## License

See repository license (if present) before redistributing content or deploying publicly.
