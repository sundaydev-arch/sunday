import { NextRequest, NextResponse } from "next/server";
import { defaultLocale, locales } from "@/lib/site";

function hasFileExtension(pathname: string) {
  return pathname.split("/").pop()?.includes(".") ?? false;
}

export function proxy(request: NextRequest) {
  const { pathname } = request.nextUrl;

  if (
    pathname.startsWith("/api") ||
    pathname.startsWith("/_next") ||
    pathname.startsWith("/ingest") ||
    pathname.startsWith("/sentry-tunnel") ||
    pathname.startsWith("/.well-known") ||
    hasFileExtension(pathname)
  ) {
    return NextResponse.next();
  }

  const pathnameHasLocale = locales.some(
    (locale) => pathname.startsWith(`/${locale}/`) || pathname === `/${locale}`,
  );

  if (pathnameHasLocale) {
    return NextResponse.next();
  }

  const url = request.nextUrl.clone();
  url.pathname = `/${defaultLocale}${pathname === "/" ? "" : pathname}`;
  return NextResponse.redirect(url);
}

export const config = {
  matcher: [
    "/((?!_next|api|ingest|sentry-tunnel|\\.well-known|.*\\..*).*)",
  ],
};
