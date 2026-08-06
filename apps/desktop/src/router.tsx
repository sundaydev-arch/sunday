import {
  Outlet,
  createRootRoute,
  createRoute,
  createRouter,
  useRouterState,
} from "@tanstack/react-router";
import { useEffect } from "react";
import { AppToaster } from "@/components/app-toaster";
import { PillNav } from "@/components/pill-nav";
import { SiteFooter } from "@/components/site-footer";
import { capturePageView } from "@/lib/analytics";
import { AboutPage } from "@/routes/about-page";
import { ContactPage } from "@/routes/contact-page";
import { HomePage } from "@/routes/home-page";
import { ProjectsPage } from "@/routes/projects-page";

function RootLayout() {
  const pathname = useRouterState({ select: (s) => s.location.pathname });

  useEffect(() => {
    capturePageView(pathname);
  }, [pathname]);

  return (
    <div className="flex min-h-screen flex-col bg-(--background)">
      <PillNav />
      <main className="flex-1">
        <Outlet />
      </main>
      <SiteFooter />
      <AppToaster />
    </div>
  );
}

const rootRoute = createRootRoute({
  component: RootLayout,
});

const indexRoute = createRoute({
  getParentRoute: () => rootRoute,
  path: "/",
  component: HomePage,
});

const aboutRoute = createRoute({
  getParentRoute: () => rootRoute,
  path: "/about",
  component: AboutPage,
});

const projectsRoute = createRoute({
  getParentRoute: () => rootRoute,
  path: "/projects",
  component: ProjectsPage,
});

const contactRoute = createRoute({
  getParentRoute: () => rootRoute,
  path: "/contact",
  component: ContactPage,
});

const routeTree = rootRoute.addChildren([
  indexRoute,
  aboutRoute,
  projectsRoute,
  contactRoute,
]);

export const router = createRouter({
  routeTree,
  defaultPreload: "intent",
});

declare module "@tanstack/react-router" {
  interface Register {
    router: typeof router;
  }
}
