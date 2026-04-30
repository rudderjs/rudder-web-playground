/**
 * Local copy of `isWebContainer()` from `@rudderjs/support`.
 *
 * Inlined here so this standalone repo doesn't have to wait for a fresh
 * `@rudderjs/support` npm release. Once the framework publishes a version
 * that exports this helper, this file can be deleted and the four
 * `config/*.ts` callers can switch their imports back to:
 *
 *     import { isWebContainer } from '@rudderjs/support'
 */
export function isWebContainer(): boolean {
  return !!(process.versions as Record<string, string | undefined>).webcontainer
}
