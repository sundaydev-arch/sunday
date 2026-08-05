import type { MetadataRoute } from "next";
import { site } from "@/lib/site";

export default function manifest(): MetadataRoute.Manifest {
  return {
    name: `${site.name} — ${site.jobTitle}`,
    short_name: site.name,
    description:
      "Personal site for Nathan Zhao, a fullstack engineer building portals, APIs, and product interfaces.",
    start_url: "/en",
    display: "standalone",
    background_color: "#0b0908",
    theme_color: "#d4926a",
    icons: [
      {
        src: "/icon.png",
        sizes: "512x512",
        type: "image/png",
        purpose: "any",
      },
      {
        src: "/apple-icon.png",
        sizes: "180x180",
        type: "image/png",
        purpose: "any",
      },
    ],
  };
}
