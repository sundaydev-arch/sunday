import { NextResponse } from "next/server";
import { captureException } from "@sunday/analytics/sentry";
import { contactErrorMessages, parseContactBody } from "@/lib/contact";
import { notifyContactMessage } from "@/lib/notify-contact";
import { createClient } from "@/lib/supabase/server";

export async function POST(request: Request) {
  try {
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

    const supabase = await createClient();
    if (!supabase) {
      return NextResponse.json(
        { error: "Contact form is temporarily unavailable." },
        { status: 503 },
      );
    }

    const { error } = await supabase.from("messages").insert(parsed.data);

    if (error) {
      captureException(error, { source: "contact_insert" });
      return NextResponse.json(
        { error: "Could not save your message. Please try again later." },
        { status: 500 },
      );
    }

    try {
      await notifyContactMessage(parsed.data);
    } catch (notifyError) {
      // Message is already saved — don't fail the request if email fails.
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
