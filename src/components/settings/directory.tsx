// mdu/src/components/settings/directory.tsx
import { useState, useEffect } from 'react';
import { useTranslation } from 'react-i18next';
import { Plus, X, FolderOpen } from 'lucide-react';
import { invoke } from '@tauri-apps/api/core';

interface Directory {
  id: string;
  path: string;
  directory_type: 'download';
}

interface OrganizationSettings {
  createSubfolders: boolean;
  useArtistName: boolean;
}

function DirectorySettings() {
  const { t } = useTranslation();
  const [directories, setDirectories] = useState<Directory[]>([]);
  const [isLoading, setIsLoading] = useState(true);
  const [defaultDownloadPath, setDefaultDownloadPath] = useState<string>('');
  const [useDefaultDownloads, setUseDefaultDownloads] = useState(true);
  const [organizationSettings, setOrganizationSettings] = useState<OrganizationSettings>({
    createSubfolders: true,
    useArtistName: false,
  });

  useEffect(() => {
    loadInitialData();
  }, []);

  const loadInitialData = async () => {
    try {
      setIsLoading(true);
      const [dirs, defaultDir] = await Promise.all([
        invoke<Directory[]>('get_directories'),
        invoke<string>('get_default_directory'),
      ]);

      setDirectories(dirs);
      setDefaultDownloadPath(defaultDir);

      // If there are custom download directories, set useDefaultDownloads to false
      const hasCustomDownloadDir = dirs.some(dir => dir.directory_type === 'download');
      setUseDefaultDownloads(!hasCustomDownloadDir);
    } catch (error) {
      console.error('Failed to load initial data:', error);
    } finally {
      setIsLoading(false);
    }
  };

  const handleAddDirectory = async () => {
    try {
      const selectedPath = await invoke<string>('select_directory');
      
      if (selectedPath) {
        const newDir = await invoke<Directory>('add_directory', {
          path: selectedPath,
          directoryType: 'download'
        });
        
        setDirectories(prev => [...prev, newDir]);
        setUseDefaultDownloads(false);
      }
    } catch (error) {
      console.error('Failed to add directory:', error);
    }
  };

  const handleRemoveDirectory = async (id: string) => {
    try {
      await invoke('remove_directory', { id });
      setDirectories(prev => prev.filter(dir => dir.id !== id));
      
      // If no custom directories left, switch back to default
      const remainingDirs = directories.filter(dir => dir.id !== id);
      if (!remainingDirs.some(dir => dir.directory_type === 'download')) {
        setUseDefaultDownloads(true);
      }
    } catch (error) {
      console.error('Failed to remove directory:', error);
    }
  };

  const handleUseDefaultChange = async (useDefault: boolean) => {
    try {
      if (useDefault) {
        // Remove all custom download directories
        const downloadDirs = directories.filter(dir => dir.directory_type === 'download');
        for (const dir of downloadDirs) {
          await invoke('remove_directory', { id: dir.id });
        }
        setDirectories(prev => prev.filter(dir => dir.directory_type !== 'download'));
      }
      setUseDefaultDownloads(useDefault);
    } catch (error) {
      console.error('Failed to update download directory settings:', error);
    }
  };

  if (isLoading) {
    return (
      <div className="p-6">
        <div className="animate-pulse space-y-4">
          <div className="h-4 bg-gray-700 rounded w-1/4"></div>
          <div className="h-8 bg-gray-700 rounded"></div>
          <div className="h-8 bg-gray-700 rounded"></div>
        </div>
      </div>
    );
  }

  return (
    <div className="p-6 space-y-8">
      <div>
        <h2 className="text-lg font-semibold text-gray-200 mb-6">
          {t('settings.directories.title')}
        </h2>
      </div>

      {/* Downloads Location Section */}
      <div className="space-y-4 text-sm">
        <h3 className="text-md font-medium text-gray-300">
          {t('settings.directories.downloads.title')}
        </h3>
        
        <div className="space-y-2">
          {/* Default Downloads Option */}
          <label className="flex items-center space-x-2 text-gray-300">
            <input
              type="radio"
              checked={useDefaultDownloads}
              onChange={() => handleUseDefaultChange(true)}
              className="form-radio text-blue-500"
            />
            <div className="flex flex-col">
              <span>{t('settings.directories.downloads.default')}</span>
              <span className="text-xs text-gray-500">{defaultDownloadPath}</span>
            </div>
          </label>

          {/* Custom Location Option */}
          <label className="flex items-center space-x-2 text-gray-300">
            <input
              type="radio"
              checked={!useDefaultDownloads}
              onChange={() => handleUseDefaultChange(false)}
              className="form-radio text-blue-500"
            />
            <span>{t('settings.directories.downloads.custom')}</span>
          </label>

          {/* Custom Directory Selection */}
          {!useDefaultDownloads && (
            <div className="pl-6 space-y-2">
              {directories
                .filter(dir => dir.directory_type === 'download')
                .map(dir => (
                  <div
                    key={dir.id}
                    className="flex items-center justify-between p-3 rounded-md bg-[#2d2d2d]"
                  >
                    <div className="flex items-center space-x-3">
                      <FolderOpen className="w-4 h-4 text-gray-400" />
                      <span className="text-sm text-gray-300">{dir.path}</span>
                    </div>
                    <button
                      onClick={() => handleRemoveDirectory(dir.id)}
                      className="p-1 hover:bg-[#4d4d4d] rounded-md transition-colors"
                    >
                      <X className="w-4 h-4 text-gray-400" />
                    </button>
                  </div>
                ))}
              
              <button
                onClick={handleAddDirectory}
                className="flex items-center space-x-2 px-3 py-1.5 rounded-md 
                         bg-[#2d2d2d] hover:bg-[#3d3d3d] text-gray-300
                         transition-colors"
              >
                <Plus className="w-4 h-4" />
                <span className="text-sm">{t('settings.directories.downloads.select')}</span>
              </button>
            </div>
          )}
        </div>
      </div>

      {/* File Organization Section */}
      <div className="space-y-4 text-sm">
        <h3 className="text-md font-medium text-gray-300">
          {t('settings.directories.organization.title')}
        </h3>

        <div className="space-y-3">
          <label className="flex items-center space-x-2 text-gray-300">
            <input
              type="checkbox"
              checked={organizationSettings.createSubfolders}
              onChange={(e) => setOrganizationSettings(prev => ({
                ...prev,
                createSubfolders: e.target.checked
              }))}
              className="form-checkbox text-blue-500"
            />
            <span>{t('settings.directories.organization.createSubfolders')}</span>
          </label>

          <label className="flex items-center space-x-2 text-gray-300">
            <input
              type="checkbox"
              checked={organizationSettings.useArtistName}
              onChange={(e) => setOrganizationSettings(prev => ({
                ...prev,
                useArtistName: e.target.checked
              }))}
              className="form-checkbox text-blue-500"
            />
            <span>{t('settings.directories.organization.useArtistName')}</span>
          </label>
        </div>
      </div>
    </div>
  );
}

export default DirectorySettings;
