"use client";

import { FormEvent, useCallback, useState, useTransition } from "react";
import { usePostHog } from "posthog-js/react";
import { toast } from "sonner";
import {
  AnalyticsEvents,
  captureEvent,
  captureException,
} from "@sunday/analytics";
import {
  contactErrorMessages,
  contactSchema,
  type ContactValidationError,
} from "@/lib/contact";
import { TurnstileField, resetTurnstile } from "@/components/turnstile-field";

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
  validation?: Partial<Record<ContactValidationError, string>>;
};

type FieldKey = "name" | "email" | "message";

function messageFor(
  code: ContactValidationError,
  labels: ContactFormLabels,
): string {
  return labels.validation?.[code] ?? contactErrorMessages[code];
}

export function ContactForm({
  labels,
  turnstileSiteKey,
}: {
  labels: ContactFormLabels;
  turnstileSiteKey?: string;
}) {
  const posthog = usePostHog();
  const [fieldErrors, setFieldErrors] = useState<
    Partial<Record<FieldKey, string>>
  >({});
  const [turnstileToken, setTurnstileToken] = useState<string | null>(null);
  const [pending, startTransition] = useTransition();

  const onToken = useCallback((token: string | null) => {
    setTurnstileToken(token);
  }, []);

  function onSubmit(event: FormEvent<HTMLFormElement>) {
    event.preventDefault();
    const form = event.currentTarget;
    const data = new FormData(form);
    const raw = {
      name: String(data.get("name") ?? ""),
      email: String(data.get("email") ?? ""),
      message: String(data.get("message") ?? ""),
      turnstileToken: turnstileToken ?? undefined,
    };

    if (turnstileSiteKey && !turnstileToken) {
      toast.error(labels.error, {
        description: messageFor("captcha_required", labels),
      });
      return;
    }

    const parsed = contactSchema.safeParse(raw);
    if (!parsed.success) {
      const next: Partial<Record<FieldKey, string>> = {};
      for (const issue of parsed.error.issues) {
        const key = issue.path[0];
        if (key !== "name" && key !== "email" && key !== "message") continue;
        if (next[key]) continue;
        next[key] = messageFor(issue.message as ContactValidationError, labels);
      }
      setFieldErrors(next);
      toast.error(labels.error, {
        description: Object.values(next)[0],
      });
      return;
    }

    setFieldErrors({});

    startTransition(async () => {
      try {
        const res = await fetch("/api/contact", {
          method: "POST",
          headers: { "Content-Type": "application/json" },
          body: JSON.stringify(parsed.data),
        });

        const json = (await res.json()) as { error?: string; ok?: boolean };

        if (!res.ok) {
          toast.error(labels.error, {
            description: json.error ?? labels.error,
          });
          captureEvent(posthog, AnalyticsEvents.ContactSubmitFailed, {
            status: res.status,
          });
          resetTurnstile();
          setTurnstileToken(null);
          return;
        }

        toast.success(labels.success);
        captureEvent(posthog, AnalyticsEvents.ContactSubmitSucceeded);
        form.reset();
        resetTurnstile();
        setTurnstileToken(null);
      } catch (error) {
        captureException(error);
        toast.error(labels.network);
        captureEvent(posthog, AnalyticsEvents.ContactSubmitFailed, {
          status: "network",
        });
        resetTurnstile();
        setTurnstileToken(null);
      }
    });
  }

  const fieldClass =
    "w-full min-w-0 border border-[var(--line)] bg-[var(--field)] px-4 py-3 font-mono text-sm text-[var(--ink)] outline-none transition placeholder:text-[var(--muted)]/60 focus:border-[var(--accent)]";

  return (
    <form
      onSubmit={onSubmit}
      noValidate
      className="flex flex-col gap-5 font-mono"
    >
      {(
        [
          {
            key: "name" as const,
            label: labels.name,
            placeholder: labels.namePlaceholder,
            type: "text",
            autoComplete: "name",
          },
          {
            key: "email" as const,
            label: labels.email,
            placeholder: labels.emailPlaceholder,
            type: "email",
            autoComplete: "email",
          },
        ] as const
      ).map((field) => (
        <label key={field.key} className="flex flex-col gap-2 text-xs">
          <span className="text-[var(--accent)]">{field.label}</span>
          <input
            name={field.key}
            type={field.type}
            autoComplete={field.autoComplete}
            aria-invalid={Boolean(fieldErrors[field.key])}
            className={`${fieldClass} ${fieldErrors[field.key] ? "border-[#ff6b6b]" : ""}`}
            placeholder={field.placeholder}
          />
          {fieldErrors[field.key] ? (
            <span className="text-[#ff6b6b]">{fieldErrors[field.key]}</span>
          ) : null}
        </label>
      ))}

      <label className="flex flex-col gap-2 text-xs">
        <span className="text-[var(--accent)]">{labels.message}</span>
        <textarea
          name="message"
          rows={5}
          aria-invalid={Boolean(fieldErrors.message)}
          className={`${fieldClass} resize-y ${fieldErrors.message ? "border-[#ff6b6b]" : ""}`}
          placeholder={labels.messagePlaceholder}
        />
        {fieldErrors.message ? (
          <span className="text-[#ff6b6b]">{fieldErrors.message}</span>
        ) : null}
      </label>

      {turnstileSiteKey ? (
        <TurnstileField siteKey={turnstileSiteKey} onToken={onToken} />
      ) : null}

      <button
        type="submit"
        disabled={pending}
        className="inline-flex items-center justify-center rounded-full bg-[var(--accent)] px-6 py-3 text-sm font-medium text-[var(--accent-ink)] transition hover:bg-[var(--accent-deep)] hover:text-white disabled:opacity-60"
      >
        {pending ? labels.sending : labels.submit}
      </button>
    </form>
  );
}
