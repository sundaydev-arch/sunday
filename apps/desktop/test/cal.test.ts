import { describe, expect, it } from "vitest";
import { getCalLink, getCalUrl } from "@/lib/cal";

describe("cal helpers", () => {
  it("parses default cal link from config", () => {
    const link = getCalLink();
    expect(link).toBeTruthy();
    expect(getCalUrl()).toContain("cal.com/");
  });
});
