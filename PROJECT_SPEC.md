# TeamVault — Engineering Specification

Build **TeamVault**, a multi-tenant B2B Project & Asset Management SaaS using **Next.js 16, React 19, Supabase, and Stripe**. All TypeScript data contracts are pre-defined in `types/database.ts`.

---

## 1. Database Architecture & Multi-Tenant RLS (Chapter 2)

- **Declarative Schemas:** Define all tables, indexes, triggers, and RLS policies as SQL files inside `supabase/schemas/` and sync them via `pg-delta` (`supabase db schema declarative sync`).
- **Required Tables:**
  - `public.workspaces` (includes `tier`, `stripe_customer_id`, `stripe_subscription_id`, `subscription_status`, `storage_used_bytes`)
  - `public.workspace_members` (`workspace_id`, `user_id`, `role`: `owner` | `admin` | `member`)
  - `public.projects` (scoped to `workspace_id`)
  - `public.tasks` (scoped to `workspace_id` and `project_id`, with `status`, `priority`, `position`)
  - `public.project_files` (metadata for uploaded deliverables)
  - `public.stripe_webhook_events` (stores processed Stripe `event_id` values for idempotency)
- **Strict Tenant Isolation:** Enable RLS on every `public.*` table. Users may only read or mutate rows belonging to workspaces where they exist in `workspace_members`.
- **Automated Verification:** `npm run db:test` (`supabase/tests/rls_isolation.test.sql`) must pass 6/6 tests.

---

## 2. Authentication & `proxy.ts` Security (Chapter 3)

- **Dual-Client SSR:** Implement `lib/supabase/client.ts` (`createBrowserClient`) and `lib/supabase/server.ts` (`createServerClient` with awaited `cookies()`) using `NEXT_PUBLIC_SUPABASE_PUBLISHABLE_KEY`.
- **Request Proxy (`proxy.ts`):**
  - Refresh and cryptographically verify sessions via `supabase.auth.getClaims()`.
  - Redirect unauthenticated requests to `/dashboard/:path*` to `/login`.
  - Set `Cache-Control: private, no-store` on authenticated responses.
- **Auth Flows:** Support Email/Password sign-in (works with seeded `alice@teamvault.dev` and `bob@teamvault.dev`) and OAuth PKCE callback handling (`/auth/callback`).

---

## 3. Next.js 16 Frontend & Full CRUD (Chapter 1)

Build a clean, responsive UI with full CRUD across the following routes:
- `/login` — Sign in / Sign up.
- `/dashboard/[workspaceId]` — Workspace switcher, project creation, and a 4-column **Kanban Board** (`todo`, `in_progress`, `in_review`, `done`) for tasks.
- `/dashboard/[workspaceId]/files` — **File Vault** showing storage quota usage, file uploads, signed downloads, and deletion.
- `/dashboard/[workspaceId]/billing` — **Billing & Plan** screen showing current tier and Stripe Checkout upgrade.

**Next.js 16 Requirements:**
- Await `params` and `searchParams` in all dynamic routes.
- Use React Server Components for data fetching and `'use cache'` with `cacheTag()` + `revalidateTag()` in Server Actions for instant read-your-writes updates.
- Validate all Server Action inputs with `zod`.

---

## 4. Realtime, Storage & Edge Functions (Chapter 4)

- **Realtime Collaboration:** Subscribe to a private Realtime Broadcast channel (`workspace:${workspaceId}`) so task status changes sync live across connected browser tabs, and display online team members via **Presence**.
- **Private Storage & TUS Uploads:**
  - Create a private `project-assets` bucket with Storage RLS enforcing path prefix `${workspace_id}/...`.
  - Implement resumable uploads using `tus-js-client`.
  - Serve downloads exclusively via short-lived **signed URLs**.
- **Durable Queue & Edge Function:** When a file is registered, enqueue a job in `pgmq` consumed by a **Deno Edge Function** that audits/logs the upload and updates `workspaces.storage_used_bytes`.

---

## 5. Full-Text Search (Chapter 5)

- Add `tsvector` generated columns and **GIN indexes** on `public.tasks` (`title`, `description`) and `public.project_files` (`file_name`).
- Expose a PostgreSQL SQL RPC (`search_workspace_content(p_workspace_id uuid, p_query text)`) returning ranked `SearchResult` rows scoped strictly to the active workspace.
- *(Optional Bonus)* Add `pgvector` semantic search with Reciprocal Rank Fusion (RRF).

---

## 6. Stripe Billing & Entitlements (Chapter 6)

- **Tier Limits (Enforced Server-Side):**
  - **Free Tier:** Maximum **2 projects** per workspace and **50 MB** total storage.
  - **Pro Tier:** **Unlimited projects** and **5 GB** total storage.
- **Checkout & Webhooks:**
  - Create a Stripe Checkout Session passing `workspace_id` in metadata.
  - Implement `app/api/webhooks/stripe/route.ts` to verify `stripe-signature`, deduplicate events via `stripe_webhook_events`, and sync `tier` and `subscription_status` on `public.workspaces`.

---

## 7. Pre-Submission Self-Audit Checklist

Before submitting your public GitHub repository link:
- [ ] `npm run typecheck` and `npm run build` succeed with zero errors.
- [ ] `npm run db:test` passes all 6 `pgTAP` multi-tenant RLS isolation tests.
- [ ] No `.env.local` or secret keys are committed to Git.
- [ ] Workspace A cannot view, edit, or download Workspace B's tasks or files.
- [ ] Free tier blocks creating a 3rd project or exceeding 50 MB storage.
- [ ] Replaying the same Stripe webhook event twice is safely ignored (idempotent).
