import React from "react";
import ReactDOM from "react-dom/client";
import { App } from "@/App";
import { initAnalytics } from "@/lib/analytics";
import "@/styles/globals.css";

// Block WebView chrome menus; keep native cut/copy/paste on form fields.
document.addEventListener("contextmenu", (event) => {
  const target = event.target;
  if (
    target instanceof HTMLInputElement ||
    target instanceof HTMLTextAreaElement ||
    (target instanceof HTMLElement && target.isContentEditable)
  ) {
    return;
  }
  event.preventDefault();
});

initAnalytics();

ReactDOM.createRoot(document.getElementById("root")!).render(
  <React.StrictMode>
    <App />
  </React.StrictMode>,
);
