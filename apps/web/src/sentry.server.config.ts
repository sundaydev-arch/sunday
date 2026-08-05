import * as Sentry from "@sentry/nextjs";
import { getSentrySharedOptions } from "@sunday/analytics/sentry-options";

Sentry.init(getSentrySharedOptions());
