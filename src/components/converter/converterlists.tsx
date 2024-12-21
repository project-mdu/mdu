// src/components/converter/converterlists.tsx
import { useState } from 'react';
import { StopCircle, Folder, FileVideo, AlertCircle } from 'lucide-react';
import { useTranslation } from 'react-i18next';
import { ConversionItem } from './types';
// import { formatBytes, formatDuration, formatDate } from '../../utils/format';

interface ConverterListProps {
  conversions: ConversionItem[];
  searchQuery: string;
  onStopConversion: (conversionId: string) => void;
}

function ConverterList({ conversions, searchQuery, onStopConversion }: ConverterListProps) {
  const { t } = useTranslation();
  const [expandedItems, setExpandedItems] = useState<Set<string>>(new Set());

  const toggleExpand = (conversionId: string) => {
    const newExpanded = new Set(expandedItems);
    if (newExpanded.has(conversionId)) {
      newExpanded.delete(conversionId);
    } else {
      newExpanded.add(conversionId);
    }
    setExpandedItems(newExpanded);
  };

  const filteredConversions = conversions.filter(conversion =>
    conversion.fileName.toLowerCase().includes(searchQuery.toLowerCase())
  );

  return (
    <div className="space-y-2">
      {filteredConversions.map((conversion) => (
        <div
          key={conversion.conversionId}
          className="bg-[#1a1a1a] rounded-md p-3 text-xs text-gray-300"
        >
          <div className="flex items-center justify-between">
            <div className="flex items-center space-x-2">
              <FileVideo className="w-4 h-4 text-blue-400" />
              <span className="font-medium">{conversion.fileName}</span>
            </div>
            <div className="flex items-center space-x-2">
              {conversion.status === 'converting' && (
                <button
                  onClick={() => onStopConversion(conversion.conversionId)}
                  className="p-1 hover:bg-[#2d2d2d] rounded"
                  title={t('converter.actions.stop')}
                >
                  <StopCircle className="w-4 h-4 text-red-400" />
                </button>
              )}
              <button
                onClick={() => toggleExpand(conversion.conversionId)}
                className="p-1 hover:bg-[#2d2d2d] rounded"
              >
                <Folder className="w-4 h-4 text-gray-400" />
              </button>
            </div>
          </div>

          {conversion.status === 'converting' && (
            <div className="mt-2">
              <div className="relative w-full h-1 bg-[#2d2d2d] rounded-full overflow-hidden">
                <div
                  className="absolute left-0 top-0 h-full bg-blue-500 transition-all duration-300"
                  style={{ width: `${conversion.progress}%` }}
                />
              </div>
              <div className="flex justify-between mt-1 text-gray-400">
                <span>{conversion.progress}%</span>
                <span>{conversion.speed}</span>
                <span>{conversion.eta}</span>
              </div>
            </div>
          )}

          {expandedItems.has(conversion.conversionId) && (
            <div className="mt-3 space-y-2 text-gray-400">
              <div className="grid grid-cols-2 gap-2">
                <div>Input: {conversion.inputPath}</div>
                <div>Output: {conversion.outputPath}</div>
                <div>Format: {conversion.format}</div>
                <div>Size: {conversion.fileSize}</div>
                {conversion.videoCodec && <div>Video Codec: {conversion.videoCodec}</div>}
                {conversion.audioCodec && <div>Audio Codec: {conversion.audioCodec}</div>}
                {conversion.resolution && <div>Resolution: {conversion.resolution}</div>}
                {conversion.bitrate && <div>Bitrate: {conversion.bitrate}</div>}
                <div>Status: {conversion.status}</div>
                {conversion.completedAt && <div>Completed: {conversion.completedAt}</div>}
                {conversion.error && (
                  <div className="col-span-2 text-red-400 flex items-center gap-1">
                    <AlertCircle className="w-3 h-3" />
                    {conversion.error}
                  </div>
                )}
              </div>
            </div>
          )}
        </div>
      ))}
    </div>
  );
}

export default ConverterList;