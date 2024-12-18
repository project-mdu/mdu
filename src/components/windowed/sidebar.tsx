// mdu/src/components/windowed/sidebar.tsx
import { useState, useEffect } from 'react';
import { 
    Download, 
    ListOrdered, 
    CheckCircle, 
    HardDrive, 
    Network, 
    RefreshCw,
    AlertCircle
} from 'lucide-react';
import { invoke } from '@tauri-apps/api/core';
import { useTranslation } from 'react-i18next';

interface DriveInfo {
    name: string;
    mount_point: string;
    total_space: number;
    free_space: number;
    available_space: number;
    drive_type: string;
}


function formatBytes(bytes: number, decimals = 1): string {
    if (bytes === 0) return '0 Bytes';

    const k = 1024;
    const dm = decimals < 0 ? 0 : decimals;
    const sizes = ['Bytes', 'KB', 'MB', 'GB', 'TB'];

    const i = Math.floor(Math.log(bytes) / Math.log(k));

    return `${parseFloat((bytes / Math.pow(k, i)).toFixed(dm))} ${sizes[i]}`;
}

function calculateUsagePercentage(total: number, available: number): number {
    return Math.round(((total - available) / total) * 100);
}


function Sidebar() {
    const { t } = useTranslation();
    const [drives, setDrives] = useState<DriveInfo[]>([]);
    const [isLoading, setIsLoading] = useState(true);
    const [error, setError] = useState<string | null>(null);
    const [networkSpeed] = useState({ download: 2.1, upload: 0.4 });
    const [counts] = useState({ downloads: 12, queue: 3, completed: 45 });

    const loadDrives = async () => {
        try {
            setError(null);
            setIsLoading(true);
            const drivesInfo = await invoke<DriveInfo[]>('get_drives');
            setDrives(drivesInfo);
        } catch (error) {
            console.error('Failed to load drives:', error);
            setError(t('sidebar.drives.error.loading'));
        } finally {
            setIsLoading(false);
        }
    };

    useEffect(() => {
        loadDrives();
    }, []);

    return (
        <div className="w-64 h-full bg-[#1e1e1e] border-r border-[#2e2e2e] text-gray-300 text-sm">
            <div className="p-2 space-y-4">
                {/* Categories Section */}
                <div>
                    <div className="flex items-center px-2 py-1 text-gray-400 text-xs uppercase">
                        {t('sidebar.categories.title')}
                    </div>
                    <div className="space-y-0.5 mt-1">
                        <button className="w-full flex items-center px-2 py-1.5 hover:bg-[#2d2d2d] rounded">
                            <Download className="w-4 h-4 mr-2" />
                            <p className=' text-xs'>{t('sidebar.categories.downloads')}</p>
                            <span className="ml-auto text-xs text-gray-500">{counts.downloads}</span>
                        </button>
                        <button className="w-full flex items-center px-2 py-1.5 hover:bg-[#2d2d2d] rounded">
                            <ListOrdered className="w-4 h-4 mr-2" />
                            <p className=' text-xs'>{t('sidebar.categories.queue')}</p>
                            <span className="ml-auto text-xs text-gray-500">{counts.queue}</span>
                        </button>
                        <button className="w-full flex items-center px-2 py-1.5 hover:bg-[#2d2d2d] rounded">
                            <CheckCircle className="w-4 h-4 mr-2" />
                            <p className=' text-xs'>{t('sidebar.categories.completed')}</p>
                            <span className="ml-auto text-xs text-gray-500">{counts.completed}</span>
                        </button>
                    </div>
                </div>

                {/* Drive Status Section */}
                <div>
                    <div className="flex items-center justify-between px-2 py-1">
                        <div className="text-gray-400 text-xs uppercase flex items-center">
                            {t('sidebar.drives.title')}
                        </div>
                        <button 
                            onClick={loadDrives} 
                            className="p-1 hover:bg-[#2d2d2d] rounded transition-colors"
                            disabled={isLoading}
                            title={t('sidebar.drives.refresh')}
                        >
                            <RefreshCw className={`w-3.5 h-3.5 text-gray-400 
                                ${isLoading ? 'animate-spin' : 'hover:text-gray-200'}`} 
                            />
                        </button>
                    </div>
                    <div className=" mt-1">
                        {error && (
                            <div className="px-2 py-1 text-xs text-red-400 flex items-center">
                                <AlertCircle className="w-3.5 h-3.5 mr-1" />
                                {error}
                            </div>
                        )}
                        
                        {isLoading ? (
                            <div className="px-2 py-1 text-xs text-gray-500">
                                {t('sidebar.drives.loading')}
                            </div>
                        ) : (
                            drives.map((drive, index) => (
                                <div key={index} className="px-2 py-1">
                                    <div className="flex items-center justify-between mb-1">
                                        <span className="text-xs flex items-center">
                                            <HardDrive className="w-3.5 h-3.5 mr-1" />
                                            {drive.name}
                                        </span>
                                        <span className="text-xs text-gray-500">
                                            {calculateUsagePercentage(drive.total_space, drive.available_space)}%
                                        </span>
                                    </div>
                                    <div className="w-full h-1 bg-[#2d2d2d] rounded-full overflow-hidden">
                                        <div 
                                            className="h-1 bg-blue-500 rounded-full transition-all duration-300" 
                                            style={{ 
                                                width: `${calculateUsagePercentage(drive.total_space, drive.available_space)}%` 
                                            }}
                                        ></div>
                                    </div>
                                    <div className="flex items-center justify-between mt-1">
                                        <span className="text-xs text-gray-500">
                                            {formatBytes(drive.available_space)} {t('sidebar.drives.free')}
                                        </span>
                                        <span className="text-xs text-gray-500">
                                            {formatBytes(drive.total_space)} {t('sidebar.drives.total')}
                                        </span>
                                    </div>
                                </div>
                            ))
                        )}
                    </div>
                </div>

                {/* Network Status Section */}
                <div>
                    <div className="flex items-center px-2 py-1 text-gray-400 text-xs uppercase">
                        {t('sidebar.network.title')}
                    </div>
                    <div className="px-2 py-1 mt-1">
                        <div className="flex items-center justify-between mb-1">
                            <span className="text-xs flex items-center">
                                <Network className="w-3.5 h-3.5 mr-1" />
                                {t('sidebar.network.speed')}
                            </span>
                            <span className="text-xs text-gray-500">
                                {networkSpeed.download + networkSpeed.upload} MB/s
                            </span>
                        </div>
                        <div className="flex items-center text-xs text-gray-500">
                            <span className="mr-2">↓ {networkSpeed.download} MB/s</span>
                            <span>↑ {networkSpeed.upload} MB/s</span>
                        </div>
                    </div>
                </div>
            </div>
        </div>
    );
}

export default Sidebar;