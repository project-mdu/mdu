#ifndef DEVICESMANAGER_HPP
#define DEVICESMANAGER_HPP

#include <QObject>
#include <QStringList>
#include <optional>

class DeviceManager : public QObject {
    Q_OBJECT
    Q_PROPERTY(QStringList availableDevices READ availableDevices NOTIFY availableDevicesChanged)
    Q_PROPERTY(QString currentDevice READ currentDevice WRITE setCurrentDevice NOTIFY currentDeviceChanged)

public:
    enum class DeviceType {
        CPU,
        GPU,
        NPU
    };
    Q_ENUM(DeviceType)

    explicit DeviceManager(QObject *parent = nullptr);

    QStringList availableDevices() const;
    QString currentDevice() const;
    void setCurrentDevice(const QString &device);

    Q_INVOKABLE void detectDevices();
    Q_INVOKABLE DeviceType getCurrentDeviceType() const;

    // Optional: Get device details
    struct DeviceInfo {
        QString name;
        QString vendor;
        size_t memorySize;
        DeviceType type;
    };

    std::optional<DeviceInfo> getDeviceDetails(DeviceType type) const;

signals:
    void availableDevicesChanged();
    void currentDeviceChanged();

private:
    QStringList m_availableDevices;
    QString m_currentDevice;

    bool checkGPUAvailability();
    bool checkNPUAvailability();
    DeviceInfo detectGPUDetails() const;  // Add const here
    DeviceInfo detectNPUDetails() const;  // Add const here
};

#endif // DEVICESMANAGER_HPP
