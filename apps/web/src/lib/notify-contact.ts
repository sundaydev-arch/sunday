import { Resend } from "resend";
import type { ContactMessage } from "@/lib/contact";
import { site } from "@/lib/site";

function escapeHtml(value: string) {
  return value
    .replaceAll("&", "&amp;")
    .replaceAll("<", "&lt;")
    .replaceAll(">", "&gt;")
    .replaceAll('"', "&quot;");
}

export async function notifyContactMessage(payload: ContactMessage) {
  const apiKey = process.env.RESEND_API_KEY;
  const to = process.env.CONTACT_NOTIFY_TO;
  // Must be an email address (Resend From), not a website URL.
  const from =
    process.env.CONTACT_NOTIFY_FROM ?? "Sunday <onboarding@resend.dev>";

  if (!apiKey || !to) {
    return { sent: false as const, reason: "not_configured" as const };
  }

  const resend = new Resend(apiKey);
  const subject = `[Sunday] New message from ${payload.name}`;
  const text = [
    `Name: ${payload.name}`,
    `Email: ${payload.email}`,
    `Site: ${site.url}/`,
    "",
    payload.message,
  ].join("\n");

  const html = `
    <div style="font-family: ui-monospace, monospace; line-height: 1.5;">
      <p><strong>Name:</strong> ${escapeHtml(payload.name)}</p>
      <p><strong>Email:</strong> ${escapeHtml(payload.email)}</p>
      <p><strong>Site:</strong> <a href="${site.url}/">${site.url}/</a></p>
      <hr />
      <p style="white-space: pre-wrap;">${escapeHtml(payload.message)}</p>
    </div>
  `;

  const { error } = await resend.emails.send({
    from,
    to: [to],
    replyTo: payload.email,
    subject,
    text,
    html,
  });

  if (error) {
    throw new Error(error.message);
  }

  return { sent: true as const };
}
