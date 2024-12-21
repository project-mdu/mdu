// main.cpp
#include "include/cef_app.h"
#include "include/cef_browser.h"
#include "include/views/cef_browser_view.h"
#include "include/views/cef_window.h"
#include "include/wrapper/cef_helpers.h"
#include <string>

class SimpleApp : public CefApp, public CefBrowserProcessHandler {
public:
    SimpleApp() {}

    virtual CefRefPtr<CefBrowserProcessHandler> GetBrowserProcessHandler() OVERRIDE {
        return this;
    }

private:
    IMPLEMENT_REFCOUNTING(SimpleApp);
    DISALLOW_COPY_AND_ASSIGN(SimpleApp);
};

class SimpleClient : public CefClient {
public:
    SimpleClient() {}

private:
    IMPLEMENT_REFCOUNTING(SimpleClient);
    DISALLOW_COPY_AND_ASSIGN(SimpleClient);
};

std::string GetStartUrl() {
#ifdef _DEBUG
    return "http://localhost:1470";
#else
    // Get the current executable path
    char result[MAX_PATH];
    GetModuleFileNameA(NULL, result, MAX_PATH);
    std::string exePath(result);
    std::string resourcePath = exePath.substr(0, exePath.find_last_of("\\/")) + "\\resources.spa";
    return "file:///" + resourcePath;
#endif
}

int main(int argc, char* argv[]) {
    CefEnableHighDPISupport();

    CefMainArgs main_args(argc, argv);
    CefRefPtr<SimpleApp> app(new SimpleApp);

    int exit_code = CefExecuteProcess(main_args, app.get(), nullptr);
    if (exit_code >= 0) {
        return exit_code;
    }

    CefSettings settings;
    settings.no_sandbox = true;

#ifndef _DEBUG
    // In release mode, disable dev tools and other debug features
    settings.remote_debugging_port = 0;
    settings.log_severity = LOGSEVERITY_DISABLE;
#endif

    CefInitialize(main_args, settings, app.get(), nullptr);

    CefWindowInfo window_info;
    window_info.SetAsPopup(nullptr, "Media Downloader Utility");

    // Set window size
    RECT rect;
    rect.left = 0;
    rect.top = 0;
    rect.right = 1024;  // width
    rect.bottom = 768;  // height
    window_info.bounds = rect;

    CefBrowserSettings browser_settings;
#ifndef _DEBUG
    // Disable dev tools in release mode
    browser_settings.remote_debugging = STATE_DISABLED;
#endif

    CefRefPtr<SimpleClient> client(new SimpleClient);

    // Get the appropriate URL based on debug/release mode
    std::string url = GetStartUrl();

    CefBrowserHost::CreateBrowser(window_info, client.get(),
        url, browser_settings, nullptr, nullptr);

    CefRunMessageLoop();
    CefShutdown();

    return 0;
}
