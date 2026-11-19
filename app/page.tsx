export default function HomePage() {
  return (
    <main className="flex min-h-screen flex-col items-center justify-center p-8 text-center">
      <h1 className="text-2xl font-bold tracking-tight">TeamVault Starter Ready</h1>
      <p className="mt-2 max-w-md text-sm text-neutral-500">
        Your Next.js 16 and Supabase local environment is configured. Open{' '}
        <code className="font-mono font-semibold text-neutral-800 dark:text-neutral-200">
          PROJECT_SPEC.md
        </code>{' '}
        to start building.
      </p>
    </main>
  );
}
