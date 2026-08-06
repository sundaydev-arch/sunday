use tauri::{
    menu::{AboutMetadata, Menu, MenuItem, PredefinedMenuItem, Submenu},
    Emitter, Manager,
};
use tauri_plugin_opener::OpenerExt;

const MENU_GITHUB: &str = "help-github";
const MENU_WEBSITE: &str = "help-website";
const MENU_SCHEDULE: &str = "help-schedule";
const MENU_CHECK_UPDATES: &str = "help-check-updates";

const EVENT_CHECK_UPDATES: &str = "sunday://check-updates";

const URL_GITHUB: &str = "https://github.com/sundaydev-arch";
const URL_WEBSITE: &str = "https://sundaydev.vercel.app/";
const URL_SCHEDULE: &str = "https://cal.com/nathan-zhao";

fn about_metadata(app: &tauri::AppHandle) -> AboutMetadata<'static> {
    let pkg = app.package_info();
    AboutMetadata {
        name: Some("Sunday".into()),
        version: Some(pkg.version.to_string()),
        copyright: Some("Nathan Zhao".into()),
        website: Some(URL_WEBSITE.into()),
        website_label: Some("sundaydev.vercel.app".into()),
        ..Default::default()
    }
}

fn build_menu(app: &tauri::AppHandle) -> tauri::Result<Menu<tauri::Wry>> {
    let github = MenuItem::with_id(app, MENU_GITHUB, "GitHub", true, None::<&str>)?;
    let website = MenuItem::with_id(app, MENU_WEBSITE, "Website", true, None::<&str>)?;
    let schedule = MenuItem::with_id(app, MENU_SCHEDULE, "Schedule", true, None::<&str>)?;
    let check_updates = MenuItem::with_id(
        app,
        MENU_CHECK_UPDATES,
        "Check for Updates…",
        true,
        None::<&str>,
    )?;

    let edit_submenu = Submenu::with_items(
        app,
        "Edit",
        true,
        &[
            &PredefinedMenuItem::undo(app, None)?,
            &PredefinedMenuItem::redo(app, None)?,
            &PredefinedMenuItem::separator(app)?,
            &PredefinedMenuItem::cut(app, None)?,
            &PredefinedMenuItem::copy(app, None)?,
            &PredefinedMenuItem::paste(app, None)?,
            &PredefinedMenuItem::select_all(app, None)?,
        ],
    )?;

    let window_submenu = Submenu::with_items(
        app,
        "Window",
        true,
        &[
            &PredefinedMenuItem::minimize(app, None)?,
            &PredefinedMenuItem::maximize(app, None)?,
            &PredefinedMenuItem::separator(app)?,
            &PredefinedMenuItem::close_window(app, None)?,
        ],
    )?;

    #[cfg(target_os = "macos")]
    {
        let app_submenu = Submenu::with_items(
            app,
            "Sunday",
            true,
            &[
                &PredefinedMenuItem::about(app, None, Some(about_metadata(app)))?,
                &PredefinedMenuItem::separator(app)?,
                &PredefinedMenuItem::services(app, None)?,
                &PredefinedMenuItem::separator(app)?,
                &PredefinedMenuItem::hide(app, None)?,
                &PredefinedMenuItem::hide_others(app, None)?,
                &PredefinedMenuItem::show_all(app, None)?,
                &PredefinedMenuItem::separator(app)?,
                &PredefinedMenuItem::quit(app, None)?,
            ],
        )?;

        let help_submenu = Submenu::with_items(
            app,
            "Help",
            true,
            &[
                &check_updates,
                &PredefinedMenuItem::separator(app)?,
                &github,
                &website,
                &schedule,
            ],
        )?;

        Menu::with_items(
            app,
            &[&app_submenu, &edit_submenu, &window_submenu, &help_submenu],
        )
    }

    #[cfg(not(target_os = "macos"))]
    {
        let help_submenu = Submenu::with_items(
            app,
            "Help",
            true,
            &[
                &PredefinedMenuItem::about(app, None, Some(about_metadata(app)))?,
                &PredefinedMenuItem::separator(app)?,
                &check_updates,
                &PredefinedMenuItem::separator(app)?,
                &github,
                &website,
                &schedule,
            ],
        )?;

        Menu::with_items(app, &[&edit_submenu, &window_submenu, &help_submenu])
    }
}

fn open_help_url(app: &tauri::AppHandle, url: &str) {
    if let Err(err) = app.opener().open_url(url, None::<&str>) {
        eprintln!("failed to open {url}: {err}");
    }
}

#[cfg_attr(mobile, tauri::mobile_entry_point)]
pub fn run() {
    let mut builder = tauri::Builder::default();

    #[cfg(desktop)]
    {
        builder = builder.plugin(tauri_plugin_single_instance::init(|app, _args, _cwd| {
            if let Some(window) = app.get_webview_window("main") {
                let _ = window.unminimize();
                let _ = window.set_focus();
            }
        }));
    }

    builder
        .plugin(tauri_plugin_opener::init())
        .plugin(tauri_plugin_process::init())
        .plugin(tauri_plugin_updater::Builder::new().build())
        .setup(|app| {
            let menu = build_menu(app.handle())?;
            app.set_menu(menu)?;

            let handle = app.handle().clone();
            app.on_menu_event(move |app, event| match event.id().as_ref() {
                MENU_GITHUB => open_help_url(&handle, URL_GITHUB),
                MENU_WEBSITE => open_help_url(&handle, URL_WEBSITE),
                MENU_SCHEDULE => open_help_url(&handle, URL_SCHEDULE),
                MENU_CHECK_UPDATES => {
                    let _ = app.emit(EVENT_CHECK_UPDATES, ());
                }
                _ => {}
            });

            Ok(())
        })
        .run(tauri::generate_context!())
        .expect("error while running tauri application");
}
