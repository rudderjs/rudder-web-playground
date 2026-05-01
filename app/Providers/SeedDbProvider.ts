import { readFileSync } from 'node:fs'
import { resolve } from 'node:path'
import { ServiceProvider } from '@rudderjs/core'
import { isWebContainer } from '../../src/runtime/webcontainer.js'

// In WebContainer the libSQL adapter swaps to a WASM build whose Emscripten
// FS can't see host files. We default the URL to `:memory:` (see
// config/database.ts) and replay prisma/dev.sql against that fresh in-memory
// DB on boot, so the demo has the same schema as a normal local boot.
//
// The dump is sqlite3 .dump output (PRAGMA + BEGIN + DDL/DML + COMMIT).
// Prisma's $executeRawUnsafe is one statement per call and can't execute
// PRAGMA / transaction markers mid-flight, so we strip those and run the
// rest sequentially through the same PrismaClient instance the rest of the
// app uses (so the in-memory DB is shared).
//
// Regenerate prisma/dev.sql after schema changes:
//   pnpm exec prisma db push    # update prisma/dev.db
//   sqlite3 prisma/dev.db .dump > prisma/dev.sql
//   git add prisma/dev.db prisma/dev.sql
interface PrismaWithRaw {
  $executeRawUnsafe(sql: string, ...args: unknown[]): Promise<number>
}

export class SeedDbProvider extends ServiceProvider {
  register(): void {}

  async boot(): Promise<void> {
    if (!isWebContainer()) return

    const prisma = this.app.make<PrismaWithRaw>('prisma')
    const sqlPath = resolve(process.cwd(), 'prisma/dev.sql')
    const sql = readFileSync(sqlPath, 'utf8')

    const statements = sql
      .split(/;\s*\n/)
      .map((s) => s.trim())
      .filter((s) =>
        s.length > 0 &&
        !/^PRAGMA\b/i.test(s) &&
        !/^BEGIN\b/i.test(s) &&
        !/^COMMIT\b/i.test(s),
      )

    for (const stmt of statements) {
      await prisma.$executeRawUnsafe(stmt)
    }

    console.log(`[SeedDbProvider] applied ${statements.length} statements to in-memory DB`)
  }
}
