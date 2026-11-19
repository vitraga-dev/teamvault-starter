import { NextResponse, type NextRequest } from 'next/server';

/**
 * Next.js 16 Request Proxy (Chapter 3)
 *
 * TODO:
 * 1. Create a Supabase server client using `@supabase/ssr` (`createServerClient`)
 *    wired to `request.cookies` and `response.cookies`.
 * 2. Call `await supabase.auth.getClaims()` to cryptographically verify and
 *    refresh the user's session token on every matched request.
 * 3. Protect `/dashboard/:path*` routes: redirect unauthenticated requests
 *    to `/login` while preserving the refreshed cookie headers.
 * 4. Set `Cache-Control: private, no-store` on authenticated responses to
 *    prevent CDN/proxy cross-user caching.
 */
export async function proxy(request: NextRequest) {
  return NextResponse.next({ request });
}

export const config = {
  matcher: [
    /*
     * Match all request paths except:
     * - _next/static (static files)
     * - _next/image (image optimization files)
     * - favicon.ico & public image assets
     * - /api/webhooks/stripe (verified via Stripe signature, not user cookies)
     */
    '/((?!_next/static|_next/image|favicon.ico|api/webhooks/stripe|.*\\.(?:svg|png|jpg|jpeg|gif|webp)$).*)',
  ],
};
