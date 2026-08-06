import { isTauri } from "@tauri-apps/api/core";
import { listen } from "@tauri-apps/api/event";
import { relaunch } from "@tauri-apps/plugin-process";
import { check } from "@tauri-apps/plugin-updater";
import { toast } from "sonner";
import { captureException } from "@/lib/analytics";

const CHECK_UPDATES_EVENT = "sunday://check-updates";

let checking = false;

async function installUpdate(
  update: NonNullable<Awaited<ReturnType<typeof check>>>,
) {
  const toastId = toast.loading(`Downloading v${update.version}…`);
  try {
    await update.downloadAndInstall();
    toast.success("Update installed — restarting…", { id: toastId });
    await relaunch();
  } catch (error) {
    captureException(error, { source: "updater-install" });
    toast.error("Update failed", {
      id: toastId,
      description: error instanceof Error ? error.message : "Try again later.",
    });
  }
}

/** Silent check on launch, or interactive when `notifyWhenCurrent` is true. */
export async function checkForAppUpdates(options?: {
  notifyWhenCurrent?: boolean;
}) {
  if (!isTauri()) return;
  if (checking) return;
  checking = true;
  try {
    const update = await check();
    if (!update) {
      if (options?.notifyWhenCurrent) {
        toast.message("You're up to date");
      }
      return;
    }

    toast(`Update ${update.version} available`, {
      description:
        update.body?.trim() || "Install to get the latest Sunday desktop.",
      duration: Infinity,
      action: {
        label: "Install & restart",
        onClick: () => {
          void installUpdate(update);
        },
      },
    });
  } catch (error) {
    // Offline / no published release yet — stay quiet on boot.
    if (options?.notifyWhenCurrent) {
      captureException(error, { source: "updater-check" });
      toast.error("Could not check for updates", {
        description:
          error instanceof Error ? error.message : "Check your connection.",
      });
    } else {
      console.warn("[updater] check skipped:", error);
    }
  } finally {
    checking = false;
  }
}

/** Boot silent check + Help → Check for Updates. */
export function startUpdaterBridge() {
  if (!isTauri()) return;

  void checkForAppUpdates();

  void listen(CHECK_UPDATES_EVENT, () => {
    void checkForAppUpdates({ notifyWhenCurrent: true });
  });
}
