import { NextResponse } from "next/server";
import { captureException } from "@sunday/analytics/sentry";
import {
  contactErrorMessages,
  parseContactBody,
  toContactMessage,
} from "@/lib/contact";
import { notifyContactMessage } from "@/lib/notify-contact";
import {
  clientIpFromHeaders,
  hashIp,
  rateLimit,
} from "@/lib/rate-limit";
import { createClient } from "@/lib/supabase/server";
import { verifyTurnstileToken } from "@/lib/turnstile";

export async function POST(request: Request) {
  try {
    const ip = clientIpFromHeaders(request.headers);
    const limited = rateLimit(`contact:${hashIp(ip)}`, {
      limit: 5,
      windowMs: 15 * 60 * 1000,
    });
    if (!limited.ok) {
      return NextResponse.json(
        { error: contactErrorMessages.rate_limited },
        {
          status: 429,
          headers: { "Retry-After": String(limited.retryAfterSec) },
        },
      );
    }

    let body: unknown;
    try {
      body = await request.json();
    } catch {
      return NextResponse.json(
        { error: contactErrorMessages.invalid_body },
        { status: 400 },
      );
    }

    const parsed = parseContactBody(body);
    if (!parsed.ok) {
      return NextResponse.json(
        { error: contactErrorMessages[parsed.error] },
        { status: 400 },
      );
    }

    const captcha = await verifyTurnstileToken(
      parsed.data.turnstileToken,
      ip,
    );
    if (!captcha.ok) {
      return NextResponse.json(
        { error: contactErrorMessages[captcha.error] },
        { status: 400 },
      );
    }

    const message = toContactMessage(parsed.data);

    const supabase = await createClient();
    if (!supabase) {
      return NextResponse.json(
        { error: "Contact form is temporarily unavailable." },
        { status: 503 },
      );
    }

    const { error } = await supabase.from("messages").insert(message);

    if (error) {
      captureException(error, { source: "contact_insert" });
      return NextResponse.json(
        { error: "Could not save your message. Please try again later." },
        { status: 500 },
      );
    }

    try {
      await notifyContactMessage(message);
    } catch (notifyError) {
      captureException(notifyError, { source: "contact_notify" });
    }

    return NextResponse.json({ ok: true });
  } catch (error) {
    captureException(error, { source: "contact_api" });
    return NextResponse.json(
      { error: contactErrorMessages.invalid_body },
      { status: 400 },
    );
  }
}
