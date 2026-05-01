import { resolve } from 'node:path'
import { Env } from '@rudderjs/core'
import { PrismaClient } from '../prisma/generated/prisma/client.js'

// Uses Prisma's libSQL driver adapter (via @prisma/adapter-libsql +
// @libsql/client) instead of better-sqlite3. The libSQL adapter is pure JS,
// so it boots in WebContainer where native bindings would fail.
//
// The schema uses Prisma 7's new `prisma-client` generator (output:
// ./prisma/generated/prisma) — a self-contained ESM client with no native
// engine binaries at install time or at runtime. We pass the generated
// PrismaClient class explicitly so @rudderjs/orm-prisma doesn't fall back to
// importing the legacy `@prisma/client` package.
//
// Run `pnpm exec prisma generate` after schema changes to regenerate the
// client at the configured output path.
//
// libSQL's `file:` URL parser doesn't always resolve `./` relative paths
// the same way SQLite does — it failed with SQLITE_CANTOPEN inside
// WebContainer/StackBlitz. Resolve to an absolute path against process.cwd()
// (project root, since dev/build are launched from there) so the form is
// unambiguous on every platform.

const dbPath = resolve(process.cwd(), 'prisma/dev.db')

export default {
  default: Env.get('DB_CONNECTION', 'libsql'),

  PrismaClient,

  connections: {
    libsql: {
      driver: 'libsql' as const,
      url:    Env.get('DATABASE_URL', `file:${dbPath}`),
    },

    sqlite: {
      driver: 'sqlite' as const,
      url:    Env.get('DATABASE_URL', `file:${dbPath}`),
    },

    postgresql: {
      driver: 'postgresql' as const,
      url:    Env.get('DATABASE_URL', ''),
    },

    mysql: {
      driver: 'mysql' as const,
      url:    Env.get('DATABASE_URL', ''),
    },
  },
}
