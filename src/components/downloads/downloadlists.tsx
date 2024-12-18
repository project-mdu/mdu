import { DownloadItem } from './download';

interface DownloadsListProps {
  downloads: DownloadItem[];
  searchQuery: string;
  onStopDownload: (videoId: string) => void;
}

function DownloadsList({ downloads, searchQuery, onStopDownload }: DownloadsListProps) {
  const filteredDownloads = downloads.filter(download =>
    download.title.toLowerCase().includes(searchQuery.toLowerCase())
  );

  return (
    <div className="space-y-2">
      {filteredDownloads.map((download) => (
        <div
          key={download.videoId}
          className="bg-[#1a1a1a] rounded-md p-3 text-xs text-gray-300"
        >
          <div className="flex justify-between items-center">
            <span className="font-medium">{download.title}</span>
            <span className="text-gray-400">{download.fileSize}</span>
          </div>
          <div className="mt-2">
            <div className="w-full bg-[#2e2e2e] rounded-full h-1.5">
              <div
                className="bg-blue-500 h-1.5 rounded-full"
                style={{ width: `${download.progress}%` }}
              />
            </div>
          </div>
          <div className="mt-2 flex justify-between items-center">
            <span className="text-gray-400">
              {download.speed} - {download.eta}
            </span>
            {download.status === 'downloading' && (
              <button
                onClick={() => onStopDownload(download.videoId)}
                className="text-red-400 hover:text-red-300"
              >
                Stop
              </button>
            )}
          </div>
        </div>
      ))}
    </div>
  );
}

export default DownloadsList;