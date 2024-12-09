#include "utils/devicesmanager.hpp"
#include <QDebug>
#include <QSysInfo>

#ifdef Q_OS_WIN
#include <windows.h>
#include <dxgi.h>
#include <d3d11.h>
#elif defined(Q_OS_LINUX)
#include <cuda_runtime.h>
#elif defined(Q_OS_MAC)
#include <Metal/Metal.h>
#endif

DeviceManager::DeviceManager(QObject *parent)
    : QObject(parent), m_currentDevice("CPU")
{
    detectDevices();
}

QStringList DeviceManager::availableDevices() const {
    return m_availableDevices;
}

QString DeviceManager::currentDevice() const {
    return m_currentDevice;
}

void DeviceManager::setCurrentDevice(const QString &device) {
    if (m_availableDevices.contains(device) && m_currentDevice != device) {
        m_currentDevice = device;
        emit currentDeviceChanged();
    }
}

void DeviceManager::detectDevices() {
    m_availableDevices.clear();
    m_availableDevices << "CPU";

    // Detect and add available devices
    if (checkGPUAvailability()) {
        m_availableDevices << "GPU";
    }

    if (checkNPUAvailability()) {
        m_availableDevices << "NPU";
    }

    // Set default to first available device
    if (!m_availableDevices.isEmpty() && !m_availableDevices.contains(m_currentDevice)) {
        m_currentDevice = m_availableDevices.first();
    }

    emit availableDevicesChanged();
    qDebug() << "Available Devices:" << m_availableDevices;
}

DeviceManager::DeviceType DeviceManager::getCurrentDeviceType() const {
    if (m_currentDevice == "GPU") return DeviceType::GPU;
    if (m_currentDevice == "NPU") return DeviceType::NPU;
    return DeviceType::CPU;
}

bool DeviceManager::checkGPUAvailability() {
#ifdef Q_OS_WIN
    // Windows GPU detection using DXGI
    #include <windows.h>
    #include <dxgi.h>
    #include <d3d11.h>
    HMODULE dxgiModule = LoadLibraryA("dxgi.dll");
    if (dxgiModule) {
        typedef HRESULT (WINAPI *CreateDXGIFactory1Func)(REFIID, void**);
        CreateDXGIFactory1Func createDXGIFactory1 =
            reinterpret_cast<CreateDXGIFactory1Func>(GetProcAddress(dxgiModule, "CreateDXGIFactory1"));

        if (createDXGIFactory1) {
            IDXGIFactory1* pFactory = nullptr;
            HRESULT hr = createDXGIFactory1(__uuidof(IDXGIFactory1), (void**)&pFactory);
            if (SUCCEEDED(hr)) {
                IDXGIAdapter1* pAdapter = nullptr;
                if (pFactory->EnumAdapters1(0, &pAdapter) == S_OK) {
                    pFactory->Release();
                    pAdapter->Release();
                    FreeLibrary(dxgiModule);
                    return true;
                }
                pFactory->Release();
            }
        }
        FreeLibrary(dxgiModule);
    }
#endif
    return false;
}

bool DeviceManager::checkNPUAvailability() {
    // NPU detection is platform and vendor-specific
    // This is a placeholder for future implementation
    return false;
}

DeviceManager::DeviceInfo DeviceManager::detectGPUDetails() const {
    DeviceInfo info;
    info.type = DeviceType::GPU;

#ifdef Q_OS_WIN
    HMODULE dxgiModule = LoadLibraryA("dxgi.dll");
    if (dxgiModule) {
        typedef HRESULT (WINAPI *CreateDXGIFactory1Func)(REFIID, void**);
        CreateDXGIFactory1Func createDXGIFactory1 =
            reinterpret_cast<CreateDXGIFactory1Func>(GetProcAddress(dxgiModule, "CreateDXGIFactory1"));

        if (createDXGIFactory1) {
            IDXGIFactory1* pFactory = nullptr;
            HRESULT hr = createDXGIFactory1(__uuidof(IDXGIFactory1), (void**)&pFactory);
            if (SUCCEEDED(hr)) {
                IDXGIAdapter1* pAdapter = nullptr;
                if (pFactory->EnumAdapters1(0, &pAdapter) == S_OK) {
                    DXGI_ADAPTER_DESC1 desc;
                    if (SUCCEEDED(pAdapter->GetDesc1(&desc))) {
                        // Convert wide char to QString
                        info.name = QString::fromWCharArray(desc.Description);
                        info.vendor = QString::number(desc.VendorId, 16);
                        info.memorySize = desc.DedicatedVideoMemory;
                    }
                    pAdapter->Release();
                }
                pFactory->Release();
            }
        }
        FreeLibrary(dxgiModule);
    }
#endif
    return info;
}

DeviceManager::DeviceInfo DeviceManager::detectNPUDetails() const {
    // Placeholder for NPU details
    DeviceInfo info;
    info.type = DeviceType::NPU;
    return info;
}

std::optional<DeviceManager::DeviceInfo> DeviceManager::getDeviceDetails(DeviceType type) const {
    switch (type) {
    case DeviceType::GPU: {
        auto details = detectGPUDetails();
        return details.name.isEmpty() ? std::optional<DeviceInfo>() : details;
    }
    case DeviceType::NPU: {
        auto details = detectNPUDetails();
        return details.name.isEmpty() ? std::optional<DeviceInfo>() : details;
    }
    default:
        return std::optional<DeviceInfo>();
    }
}
