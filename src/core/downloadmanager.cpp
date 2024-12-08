// downloadmanager.cpp
#include "downloadmanager.hpp"

DownloadManager::DownloadManager(QObject *parent)
    : QObject(parent)
{
    QString appDataPath = QStandardPaths::writableLocation(QStandardPaths::AppLocalDataLocation);
    m_historyFilePath = appDataPath + "/history.json";

    m_futureWatcher = new QFutureWatcher<QJsonArray>(this);
    connect(m_futureWatcher, &QFutureWatcher<QJsonArray>::finished, this, [this]() {
        emit downloadHistoryLoaded(m_futureWatcher->result());
    });
}

void DownloadManager::loadDownloadHistoryAsync()
{
    QFuture<QJsonArray> future = QtConcurrent::run([this]() {
        return loadDownloadHistoryInternal();
    });
    m_futureWatcher->setFuture(future);
}

QJsonArray DownloadManager::loadDownloadHistoryInternal()
{
    QFile file(m_historyFilePath);
    if (!file.open(QIODevice::ReadOnly)) {
        emit loadingError("Could not open download history file: " + m_historyFilePath);
        return QJsonArray();
    }

    QByteArray data = file.readAll();
    file.close();

    QJsonParseError error;
    QJsonDocument doc = QJsonDocument::fromJson(data, &error);

    if (error.error != QJsonParseError::NoError) {
        emit loadingError("JSON parsing error: " + error.errorString());
        return QJsonArray();
    }

    if (doc.isArray()) {
        return doc.array();
    }

    return QJsonArray();
}

QString DownloadManager::getAppDataPath() const
{
    return QStandardPaths::writableLocation(QStandardPaths::AppLocalDataLocation);
}
