// mdu/src/components/windowed/statusbar.tsx
import { useState, useEffect } from 'react';
import { invoke } from '@tauri-apps/api/core';
import { useTranslation } from 'react-i18next';

interface SystemStatus {
    cpu_usage: number;
    memory_usage: number;
    os_info: string;
    cpu_info: string;
    app_version: string;
}

function StatusBar() {
    const { t } = useTranslation();
    const [systemInfo, setSystemInfo] = useState<SystemStatus | null>(null);
    const [status, setStatus] = useState(t('status.ready'));

    // Load initial system information
    useEffect(() => {
        const loadSystemInfo = async () => {
            try {
                const info = await invoke<SystemStatus>('get_system_info');
                setSystemInfo(info);
            } catch (error) {
                console.error('Failed to load system info:', error);
                setStatus(t('status.error.loading'));
            }
        };

        loadSystemInfo();
    }, [t]);

    // Update CPU and memory usage periodically
    useEffect(() => {
        const updateInterval = setInterval(async () => {
            try {
                const updates = await invoke<SystemStatus>('get_status_updates');
                setSystemInfo(prev => prev ? {
                    ...prev,
                    cpu_usage: updates.cpu_usage,
                    memory_usage: updates.memory_usage,
                } : null);
            } catch (error) {
                console.error('Failed to update system status:', error);
            }
        }, 1000);

        return () => clearInterval(updateInterval);
    }, []);

    return (
        <div className="h-6 bg-[#1a1a1a] border-t border-[#2e2e2e] px-2 flex items-center justify-between">
            <span className="text-gray-400 text-xs">{status}</span>
            {systemInfo && (
                <div className="flex items-center space-x-4 text-gray-400 text-xs">
                    <span>{t('status.app_version')}: {systemInfo.app_version}</span>
                    <span>{t('status.os')}: {systemInfo.os_info}</span>
                    <span>{t('status.cpu')}: {systemInfo.cpu_usage.toFixed(1)}%</span>
                    <span>{t('status.memory')}: {systemInfo.memory_usage.toFixed(1)}%</span>
                    <span>{systemInfo.cpu_info}</span>
                </div>
            )}
        </div>
    );
}

export default StatusBar;