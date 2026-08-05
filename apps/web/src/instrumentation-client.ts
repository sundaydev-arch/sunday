import * as Sentry from "@sentry/nextjs";
import { getSentryClientOptions } from "@sunday/analytics/sentry-options";

Sentry.init({
  ...getSentryClientOptions(),
  integrations: [
    Sentry.replayIntegration({
      maskAllText: true,
      maskAllInputs: true,
      blockAllMedia: true,
    }),
  ],
});

export const onRouterTransitionStart = Sentry.captureRouterTransitionStart;
