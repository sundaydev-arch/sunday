/** Lightweight className joiner — no clsx/tailwind-merge deps. */
export function cn(
  ...inputs: Array<string | false | null | undefined>
): string {
  return inputs.filter(Boolean).join(" ");
}
