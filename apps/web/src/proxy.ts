import createMiddleware from "next-intl/middleware";
import { NextRequest, NextResponse } from "next/server";
import { routing } from "@/i18n/routing";

const handleI18n = createMiddleware(routing);

export function proxy(request: NextRequest) {
  const { pathname } = request.nextUrl;

  if (
    pathname.startsWith("/api") ||
    pathname.startsWith("/_next") ||
    pathname.startsWith("/ingest") ||
    pathname.startsWith("/sentry-tunnel") ||
    pathname.startsWith("/.well-known")
  ) {
    return NextResponse.next();
  }

  return handleI18n(request);
}

export const config = {
  matcher: ["/((?!_next|api|ingest|sentry-tunnel|.*\\..*).*)"],
};
