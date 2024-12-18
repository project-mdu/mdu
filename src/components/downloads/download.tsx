// src/components/downloads/download.tsx
import { useState, useEffect } from "react";
import { Download, StopCircle, Trash2, Plus, Search } from "lucide-react";
import DownloadsList from "./downloadlists";
import AddDownload from "./adddownload";
import { useTranslation } from "react-i18next";
import { invoke } from "@tauri-apps/api/core";

export interface DownloadItem {
  fileName: string;
  fileSize: string;
  progress: number;
  status: string;
  speed: string;
  eta: string;
  error: string;
  title: string;
  url: string;
  completedAt: string;
  elapsedTime: string;
  videoId: string;
  outputPath: string;
  isAudioOnly: boolean;
}

function Downloads() {
  const [isLoading, setIsLoading] = useState<boolean>(false);
  const [downloadData, setDownloadData] = useState<DownloadItem[]>([]);
  const [activeDownloads, setActiveDownloads] = useState<DownloadItem[]>([]);
  const [showDownloadModal, setShowDownloadModal] = useState<boolean>(false);
  const [searchQuery, setSearchQuery] = useState<string>("");
  const { t } = useTranslation();

  useEffect(() => {
    loadDownloadHistory();
  }, []);

  const loadDownloadHistory = async () => {
    setIsLoading(true);
    try {
      const history = await invoke<DownloadItem[]>("get_download_history");
      const active = history.filter(item => item.status === 'downloading');
      const others = history.filter(item => item.status !== 'downloading');
      
      setActiveDownloads(active);
      setDownloadData(others);
    } catch (error) {
      console.error("Failed to load download history:", error);
    } finally {
      setIsLoading(false);
    }
  };

  const handleAddDownload = async (url: string, formatId: string) => {
    try {
      await invoke("start_download", { url, formatId });
      loadDownloadHistory(); // Refresh the list after adding
    } catch (error) {
      console.error("Failed to start download:", error);
      throw error; // Re-throw to be handled by the modal
    }
  };

  const handleStopDownload = async (videoId: string) => {
    try {
      await invoke("stop_download", { videoId });
      if (videoId === "all") {
        setActiveDownloads([]);
      } else {
        setActiveDownloads(prev => prev.filter(d => d.videoId !== videoId));
      }
      loadDownloadHistory();
    } catch (error) {
      console.error("Failed to stop download:", error);
    }
  };

  const handleClearHistory = async () => {
    try {
      await invoke("clear_download_history");
      setDownloadData([]);
    } catch (error) {
      console.error("Failed to clear history:", error);
    }
  };

  return (
    <div className="h-full flex flex-col bg-[#121212]">
      <div className="h-8 bg-[#1a1a1a] flex items-center justify-between px-2 border-b border-[#2e2e2e]">
        <div className="flex items-center space-x-1">
          <Download className="w-4 h-4 text-blue-400" />
          <span className="text-xs text-gray-200 font-medium">
            {t('downloads.title')}
          </span>
        </div>
        <div className="flex items-center space-x-1">
          <button
            onClick={() => setShowDownloadModal(true)}
            className="text-gray-300 hover:bg-[#2d2d2d] p-1 rounded-md"
            title={t('downloads.actions.addDownload')}
          >
            <Plus className="w-4 h-4" />
          </button>
          <button
            className="text-gray-300 hover:bg-[#2d2d2d] p-1 rounded-md disabled:opacity-50"
            disabled={activeDownloads.length === 0}
            onClick={() => handleStopDownload("all")}
            title={t('downloads.actions.stopAll')}
          >
            <StopCircle className="w-4 h-4" />
          </button>
          <button
            className="text-gray-300 hover:bg-[#2d2d2d] p-1 rounded-md disabled:opacity-50"
            disabled={downloadData.length === 0}
            onClick={handleClearHistory}
            title={t('downloads.actions.clearHistory')}
          >
            <Trash2 className="w-4 h-4" />
          </button>
        </div>
      </div>

      <div className="flex-1 flex">
        <div className="flex-1 p-4">
          {isLoading ? (
            <div className="h-full flex flex-col items-center justify-center">
              <div className="animate-spin rounded-full h-8 w-8 border-t-2 border-b-2 border-blue-500"></div>
              <p className="text-gray-400 mt-4 text-xs">
                {t('downloads.status.loading')}
              </p>
            </div>
          ) : (
            <div className="h-full flex flex-col space-y-3">
              <div className="relative">
                <Search className="absolute left-2.5 top-1/2 transform -translate-y-1/2 w-4 h-4 text-gray-400" />
                <input
                  type="text"
                  placeholder={t('downloads.search.placeholder')}
                  className="w-full h-8 bg-[#1a1a1a] text-gray-200 text-xs pl-9 pr-4 rounded-md
                            focus:outline-none focus:ring-1 focus:ring-blue-500 border border-[#2e2e2e]"
                  value={searchQuery}
                  onChange={(e) => setSearchQuery(e.target.value)}
                />
              </div>

              <div className="flex-1 overflow-auto">
                {activeDownloads.length === 0 && downloadData.length === 0 ? (
                  <div className="h-full flex items-center justify-center text-gray-400 text-xs">
                    {t('downloads.status.noDownloads')}
                  </div>
                ) : (
                  <DownloadsList
                    downloads={[...activeDownloads, ...downloadData]}
                    searchQuery={searchQuery}
                    onStopDownload={handleStopDownload}
                  />
                )}
              </div>
            </div>
          )}
        </div>
      </div>

      <AddDownload
        isOpen={showDownloadModal}
        onClose={() => setShowDownloadModal(false)}
        onAddDownload={handleAddDownload}
      />
    </div>
  );
}

export default Downloads;