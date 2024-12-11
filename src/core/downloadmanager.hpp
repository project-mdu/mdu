// downloadmanager.hpp
#ifndef DOWNLOADMANAGER_HPP
#define DOWNLOADMANAGER_HPP

#include <QObject>
#include <QJsonArray>
#include <QJsonObject>
#include <QJsonDocument>
#include <QFile>
#include <QStandardPaths>
#include <QDir>
#include <QFuture>
#include <QFutureWatcher>
#include <QtConcurrent>

class DownloadManager : public QObject
{
    Q_OBJECT
public:
    explicit DownloadManager(QObject *parent = nullptr);

    Q_INVOKABLE void loadDownloadHistoryAsync();
    Q_INVOKABLE QString getAppDataPath() const;
    Q_INVOKABLE QString getDefaultDownloadsPath() const;  // Add this method
    Q_INVOKABLE bool ensureDirectoryExists(const QString& path) const;  // Add this utility method

signals:
    void downloadHistoryLoaded(const QJsonArray &data);
    void loadingError(const QString &error);

private:
    QString m_historyFilePath;
    QFutureWatcher<QJsonArray> *m_futureWatcher;

    QJsonArray loadDownloadHistoryInternal();
};

#endif // DOWNLOADMANAGER_HPP
