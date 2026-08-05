import { ImageResponse } from "next/og";
import { site } from "@/lib/site";

export const alt = `${site.name} — ${site.jobTitle}`;
export const size = { width: 1200, height: 630 };
export const contentType = "image/png";

export default function OpenGraphImage() {
  return new ImageResponse(
    <div
      style={{
        width: "100%",
        height: "100%",
        display: "flex",
        flexDirection: "column",
        justifyContent: "space-between",
        padding: "64px",
        background: "linear-gradient(180deg, #0e0b09 0%, #0b0908 55%)",
        color: "#f0e4d8",
        fontFamily: "ui-monospace, monospace",
      }}
    >
      <div
        style={{
          display: "flex",
          fontSize: 28,
          color: "#8a7464",
          letterSpacing: "0.08em",
        }}
      >
        guest@{site.handle}:~$ whoami
      </div>
      <div style={{ display: "flex", flexDirection: "column", gap: 18 }}>
        <div
          style={{
            display: "flex",
            fontSize: 96,
            fontWeight: 700,
            color: "#f0e4d8",
            letterSpacing: "-0.04em",
          }}
        >
          {site.name}
        </div>
        <div
          style={{
            display: "flex",
            fontSize: 32,
            color: "#d4926a",
          }}
        >
          {"// "}
          {site.jobTitle}
        </div>
        <div
          style={{
            display: "flex",
            fontSize: 24,
            color: "#8a7464",
            maxWidth: 900,
          }}
        >
          Multi-tenant portals · BFF · data APIs · TypeScript
        </div>
      </div>
      <div style={{ display: "flex", fontSize: 22, color: "#8a7464" }}>
        {site.url.replace("https://", "")}
      </div>
    </div>,
    { ...size },
  );
}
