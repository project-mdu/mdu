#include "app_paths.hpp"
#include <Windows.h>

namespace AppPaths {
    std::string GetExecutablePath() {
        char result[MAX_PATH];
        GetModuleFileNameA(NULL, result, MAX_PATH);
        return std::string(result);
    }

    std::string GetResourcesPath() {
        std::string exePath = GetExecutablePath();
        return exePath.substr(0, exePath.find_last_of("\\/")) + "\\resources.spa";
    }

    std::string GetStartUrl() {
    #ifdef _DEBUG
        return "http://localhost:1470";
    #else
        return "file:///" + GetResourcesPath();
    #endif
    }
}
