# TeamVault — Production Full-Stack Engineering Capstone

Starter repository for the **Production Full-Stack Engineering (Next.js 16 & Supabase)** capstone at **Vitraga Academy**.

Your goal is to build **TeamVault**—a production-grade, multi-tenant B2B Project & Asset Management SaaS—from this clean foundation. All engineering requirements are defined in [`PROJECT_SPEC.md`](./PROJECT_SPEC.md).

---

## Prerequisites

- **Node.js** 22+
- **Docker** (or OrbStack) running locally
- **Supabase CLI v3** (`npm install -g supabase` or Homebrew)
- **Stripe CLI** (for local webhook forwarding in Chapter 6)

---

## Quick Start

### 1. Clone & Install Dependencies
```bash
git clone https://github.com/vitraga-dev/teamvault-starter.git teamvault
cd teamvault
npm install
```

### 2. Start Local Supabase
```bash
npm run db:start
```
This boots PostgreSQL 17, Auth, Storage, Realtime, and Studio locally, and seeds two test accounts:
- `alice@teamvault.dev` / `password123`
- `bob@teamvault.dev` / `password123`

### 3. Configure Environment Variables
Copy the template and fill in the keys printed by `supabase status`:
```bash
cp .env.example .env.local
```

### 4. Verify the Failing Grading Suite
Run the pre-written `pgTAP` RLS isolation tests:
```bash
npm run db:test
```
> **Expected behavior:** These tests **fail out of the box** because you have not created the database schema or Row Level Security policies yet. They must all pass before submission.

### 5. Start Next.js 16
```bash
npm run dev
```
Open [http://localhost:3000](http://localhost:3000) to confirm the starter boots cleanly.

---

## What's Included vs. What You Build

- **Included:** Next.js 16 (`cacheComponents` + `reactCompiler`), Tailwind CSS v4, TypeScript contracts (`types/database.ts`), Supabase CLI v3 config, seed users, failing `pgTAP` RLS tests, and minimal stubs (`proxy.ts`, `lib/supabase/`).
- **You Build:** All declarative SQL schemas (`supabase/schemas/`), RLS policies, RPCs, Edge Functions, Next.js 16 App Router pages/components, Server Actions, Realtime channels, TUS uploads, and Stripe billing.

---

## Submission

1. Push your completed project to a **public GitHub repository** on your profile.
2. *(Optional)* Deploy your app to **Vercel** or **Cloudflare OpenNext** and include the live URL in your repo's README.
3. Submit your **public GitHub repository link** (and optional live URL) in the Vitraga Academy capstone portal for staff engineer review.
