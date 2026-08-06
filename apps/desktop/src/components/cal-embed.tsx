import Cal, { getCalApi } from "@calcom/embed-react";
import { useEffect, useState } from "react";
import { Spinner } from "@/components/spinner";

const NAMESPACE = "contact";

type CalEmbedProps = {
  calLink: string;
};

export function CalEmbed({ calLink }: CalEmbedProps) {
  const [ready, setReady] = useState(false);

  useEffect(() => {
    let cancelled = false;
    const fallback = window.setTimeout(() => {
      if (!cancelled) setReady(true);
    }, 12_000);

    void (async () => {
      const cal = await getCalApi({ namespace: NAMESPACE });
      if (cancelled) return;

      cal("ui", {
        theme: "dark",
        hideEventTypeDetails: false,
        layout: "month_view",
        cssVarsPerTheme: {
          light: {
            "cal-brand": "#d4926a",
            "cal-brand-emphasis": "#b8734a",
            "cal-brand-text": "#140c08",
            "cal-bg": "#100e0c",
            "cal-bg-emphasis": "#161310",
            "cal-text": "#f0e4d8",
            "cal-text-emphasis": "#f0e4d8",
            "cal-text-muted": "#9a8a7a",
            "cal-border": "#2a241f",
            "cal-border-booker": "#2a241f",
            "cal-border-booker-width": "1px",
            radius: "0",
          },
          dark: {
            "cal-brand": "#d4926a",
            "cal-brand-emphasis": "#b8734a",
            "cal-brand-text": "#140c08",
            "cal-bg": "#100e0c",
            "cal-bg-emphasis": "#161310",
            "cal-text": "#f0e4d8",
            "cal-text-emphasis": "#f0e4d8",
            "cal-text-muted": "#9a8a7a",
            "cal-border": "#2a241f",
            "cal-border-booker": "#2a241f",
            "cal-border-booker-width": "1px",
            radius: "0",
          },
        },
      });

      cal("on", {
        action: "linkReady",
        callback: () => {
          if (!cancelled) setReady(true);
        },
      });
    })();

    return () => {
      cancelled = true;
      window.clearTimeout(fallback);
    };
  }, []);

  return (
    <div className="cal-embed relative w-full overflow-hidden">
      {!ready ? (
        <div
          className="flex min-h-[220px] flex-col items-center justify-center gap-3 bg-[var(--panel)]"
          aria-busy="true"
        >
          <Spinner className="size-8 text-[var(--accent)]" />
          <p className="font-mono text-xs text-[var(--muted)]">loading…</p>
        </div>
      ) : null}
      <div
        className={
          ready
            ? "opacity-100 transition-opacity duration-300"
            : "pointer-events-none absolute inset-x-0 top-0 opacity-0"
        }
      >
        <Cal
          namespace={NAMESPACE}
          calLink={calLink}
          style={{ width: "100%", overflow: "visible" }}
          config={{
            layout: "month_view",
            theme: "dark",
          }}
        />
      </div>
    </div>
  );
}
