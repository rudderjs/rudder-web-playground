import type { Application, ServiceProvider } from '@rudderjs/core'
import { defaultProviders, eventsProvider } from '@rudderjs/core'
import { AppServiceProvider } from '../app/Providers/AppServiceProvider.js'
import { SeedDbProvider } from '../app/Providers/SeedDbProvider.js'
import { UserRegistered } from '../app/Events/UserRegistered.js'
import { SendWelcomeEmailListener } from '../app/Listeners/SendWelcomeEmailListener.js'

export default [
  ...(await defaultProviders()),
  // Must boot AFTER DatabaseProvider (in defaultProviders) so the 'prisma'
  // DI binding exists, and BEFORE AppServiceProvider so app code that queries
  // the DB at boot finds the schema in place.
  SeedDbProvider,
  eventsProvider({ [UserRegistered.name]: [SendWelcomeEmailListener] }),
  AppServiceProvider,
] satisfies (new (app: Application) => ServiceProvider)[]
