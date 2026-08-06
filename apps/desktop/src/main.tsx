import React from "react";
import ReactDOM from "react-dom/client";
import { App } from "@/App";
import { initAnalytics } from "@/lib/analytics";
import "@/styles/globals.css";

// Native WebView menu (Back / Reload / Inspect Element) feels browser-y.
document.addEventListener("contextmenu", (event) => {
  event.preventDefault();
});

initAnalytics();

ReactDOM.createRoot(document.getElementById("root")!).render(
  <React.StrictMode>
    <App />
  </React.StrictMode>,
);
