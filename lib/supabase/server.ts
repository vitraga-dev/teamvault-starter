import type { SupabaseClient } from '@supabase/supabase-js';

/**
 * Server Supabase Client (Chapter 3)
 *
 * TODO:
 * 1. Await `cookies()` from `next/headers` (mandatory async Request API in Next.js 16).
 * 2. Return `createServerClient` from `@supabase/ssr` with `getAll()` and `setAll()`
 *    cookie adapters using `NEXT_PUBLIC_SUPABASE_URL` and `NEXT_PUBLIC_SUPABASE_PUBLISHABLE_KEY`.
 * 3. Wrap `setAll()` in a try/catch so calls from Server Components don't throw
 *    when `proxy.ts` handles session refresh.
 */
export async function createClient(): Promise<SupabaseClient> {
  throw new Error(
    'Supabase server client not implemented. Complete lib/supabase/server.ts (Chapter 3).'
  );
}
