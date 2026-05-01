import 'reflect-metadata'
import 'dotenv/config'
import { Application } from '@rudderjs/core'
import { hono } from '@rudderjs/server-hono'
import { AuthMiddleware } from '@rudderjs/auth'
import { SessionMiddleware } from '@rudderjs/session'
import { RateLimit, CsrfMiddleware } from '@rudderjs/middleware'
import { requestIdMiddleware } from '../app/Http/Middleware/RequestIdMiddleware.ts'
import { AppError } from '../app/Exceptions/AppError.ts'
import configs from '../config/index.ts'
import providers from './providers.ts'

export default Application.configure({
  server:    hono(configs.server),
  config:    configs,
  providers,
})
  .withRouting({
    web:      () => import('../routes/web.ts'),
    api:      () => import('../routes/api.ts'),
    commands: () => import('../routes/console.ts'),
  })
  .withMiddleware((m) => {
    // Global middleware — runs on every request, regardless of route group
    m.use(requestIdMiddleware)

    // Per-group middleware. Session + Auth are normally auto-installed on
    // the web group by their providers via appendToGroup(). In WebContainer
    // that path stops firing — auth() throws "No auth context" because the
    // chain ends up RateLimit → CsrfMiddleware → handler with no session/auth
    // wiring. Wire them explicitly here so it works on every platform.
    // (Order: session before auth — SessionGuard reads from session context.)
    m.web(SessionMiddleware())
    m.web(RateLimit.perMinute(120))
    m.web(AuthMiddleware())
    // Paddle webhooks live in the web group (registered in routes/web.ts)
    // but arrive without a CSRF token — Paddle is the sender, not a browser form.
    m.web(CsrfMiddleware({ exclude: ['/paddle/webhook'] }))
    m.api(RateLimit.perMinute(60))
  })
  .withExceptions((e) => {
    // AppError → JSON response using its statusCode and code fields.
    // ValidationError is handled automatically (422) — no entry needed here.
    e.render(AppError, (err) =>
      new Response(JSON.stringify(err.toJSON()), {
        status:  err.statusCode,
        headers: { 'Content-Type': 'application/json' },
      })
    )
  })
  .create()
