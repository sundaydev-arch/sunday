import { Component, type ErrorInfo, type ReactNode } from "react";
import { captureException } from "@/lib/analytics";

type Props = {
  children: ReactNode;
};

type State = {
  hasError: boolean;
};

/** Catch render crashes so the WebView is not a blank page. */
export class AppErrorBoundary extends Component<Props, State> {
  state: State = { hasError: false };

  static getDerivedStateFromError(): State {
    return { hasError: true };
  }

  componentDidCatch(error: Error, info: ErrorInfo) {
    captureException(error, {
      componentStack: info.componentStack ?? undefined,
    });
  }

  render() {
    if (this.state.hasError) {
      return (
        <div className="flex min-h-screen flex-col items-center justify-center gap-4 bg-(--background) px-6 text-center font-mono text-(--ink)">
          <p className="text-sm text-(--accent)">something went wrong</p>
          <p className="max-w-md text-xs text-(--muted)">
            The window hit an unexpected error. Reload to continue.
          </p>
          <button
            type="button"
            className="rounded-full bg-(--accent) px-5 py-2 text-sm font-medium text-(--accent-ink) transition hover:bg-(--accent-deep) hover:text-white focus-visible:outline-2 focus-visible:outline-offset-2 focus-visible:outline-(--accent)"
            onClick={() => window.location.reload()}
          >
            Reload
          </button>
        </div>
      );
    }

    return this.props.children;
  }
}
