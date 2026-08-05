"use client";

import { FormEvent, useState, useTransition } from "react";
import { usePostHog } from "posthog-js/react";
import {
  AnalyticsEvents,
  captureEvent,
  captureException,
} from "@sunday/analytics";

export type ContactFormLabels = {
  name: string;
  email: string;
  message: string;
  namePlaceholder: string;
  emailPlaceholder: string;
  messagePlaceholder: string;
  submit: string;
  sending: string;
  success: string;
  error: string;
  network: string;
};

type Status = "idle" | "success" | "error";

export function ContactForm({ labels }: { labels: ContactFormLabels }) {
  const posthog = usePostHog();
  const [status, setStatus] = useState<Status>("idle");
  const [message, setMessage] = useState("");
  const [pending, startTransition] = useTransition();

  function onSubmit(event: FormEvent<HTMLFormElement>) {
    event.preventDefault();
    const form = event.currentTarget;
    const data = new FormData(form);

    startTransition(async () => {
      setStatus("idle");
      setMessage("");

      try {
        const res = await fetch("/api/contact", {
          method: "POST",
          headers: { "Content-Type": "application/json" },
          body: JSON.stringify({
            name: data.get("name"),
            email: data.get("email"),
            message: data.get("message"),
          }),
        });

        const json = (await res.json()) as { error?: string; ok?: boolean };

        if (!res.ok) {
          setStatus("error");
          setMessage(json.error ?? labels.error);
          captureEvent(posthog, AnalyticsEvents.ContactSubmitFailed, {
            status: res.status,
          });
          return;
        }

        setStatus("success");
        setMessage(labels.success);
        captureEvent(posthog, AnalyticsEvents.ContactSubmitSucceeded);
        form.reset();
      } catch (error) {
        captureException(error);
        setStatus("error");
        setMessage(labels.network);
        captureEvent(posthog, AnalyticsEvents.ContactSubmitFailed, {
          status: "network",
        });
      }
    });
  }

  const fieldClass =
    "w-full min-w-0 border border-[var(--line)] bg-[var(--field)] px-4 py-3 font-mono text-sm text-[var(--ink)] outline-none transition placeholder:text-[var(--muted)]/60 focus:border-[var(--accent)]";

  return (
    <form onSubmit={onSubmit} className="flex flex-col gap-5 font-mono">
      <label className="flex flex-col gap-2 text-xs">
        <span className="text-[var(--accent)]">{labels.name}</span>
        <input
          name="name"
          required
          autoComplete="name"
          className={fieldClass}
          placeholder={labels.namePlaceholder}
        />
      </label>
      <label className="flex flex-col gap-2 text-xs">
        <span className="text-[var(--accent)]">{labels.email}</span>
        <input
          name="email"
          type="email"
          required
          autoComplete="email"
          className={fieldClass}
          placeholder={labels.emailPlaceholder}
        />
      </label>
      <label className="flex flex-col gap-2 text-xs">
        <span className="text-[var(--accent)]">{labels.message}</span>
        <textarea
          name="message"
          required
          rows={5}
          className={`${fieldClass} resize-y`}
          placeholder={labels.messagePlaceholder}
        />
      </label>
      <button
        type="submit"
        disabled={pending}
        className="inline-flex items-center justify-center rounded-full bg-[var(--accent)] px-6 py-3 text-sm font-medium text-[var(--accent-ink)] transition hover:bg-[var(--accent-deep)] hover:text-white disabled:opacity-60"
      >
        {pending ? labels.sending : labels.submit}
      </button>
      {message ? (
        <p
          role="status"
          className={
            status === "error"
              ? "text-sm text-[#ff6b6b]"
              : "text-sm text-[var(--accent)]"
          }
        >
          {message}
        </p>
      ) : null}
    </form>
  );
}
