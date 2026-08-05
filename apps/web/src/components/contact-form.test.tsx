import { render, screen } from "@testing-library/react";
import userEvent from "@testing-library/user-event";
import { beforeEach, describe, expect, it, vi } from "vitest";
import { ContactForm } from "@/components/contact-form";

vi.mock("posthog-js/react", () => ({
  usePostHog: () => null,
}));

vi.mock("sonner", () => ({
  toast: {
    success: vi.fn(),
    error: vi.fn(),
  },
}));

vi.mock("@sunday/analytics", () => ({
  AnalyticsEvents: {
    ContactSubmitSucceeded: "contact_submit_succeeded",
    ContactSubmitFailed: "contact_submit_failed",
  },
  captureEvent: vi.fn(),
  captureException: vi.fn(),
}));

const labels = {
  name: "--name",
  email: "--email",
  message: "--message",
  namePlaceholder: "alias",
  emailPlaceholder: "you@domain.dev",
  messagePlaceholder: "payload...",
  submit: "submit --force",
  sending: "sending...",
  success: "Message sent — thanks, I'll get back to you.",
  error: "Couldn't send. Please try again.",
  network: "Network error. Please try again.",
};

describe("ContactForm", () => {
  beforeEach(() => {
    vi.restoreAllMocks();
  });

  it("shows field errors when empty", async () => {
    const user = userEvent.setup();
    render(<ContactForm labels={labels} />);
    await user.click(screen.getByRole("button", { name: /submit/i }));
    expect(await screen.findAllByText(/required|fill/i)).not.toHaveLength(0);
  });

  it("posts a valid payload", async () => {
    const user = userEvent.setup();
    const fetchMock = vi
      .spyOn(globalThis, "fetch")
      .mockResolvedValue(
        new Response(JSON.stringify({ ok: true }), { status: 200 }),
      );

    render(<ContactForm labels={labels} />);
    await user.type(screen.getByPlaceholderText("alias"), "Ada");
    await user.type(
      screen.getByPlaceholderText("you@domain.dev"),
      "ada@example.com",
    );
    await user.type(screen.getByPlaceholderText("payload..."), "Hello there");
    await user.click(screen.getByRole("button", { name: /submit/i }));

    expect(fetchMock).toHaveBeenCalledWith(
      "/api/contact",
      expect.objectContaining({ method: "POST" }),
    );
  });
});
