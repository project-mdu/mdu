// src/components/downloads/adddownload.tsx
import React, { useState } from "react";
import { X, Video, Music, Download } from "lucide-react";
import { useTranslation } from "react-i18next";
import { invoke } from "@tauri-apps/api/core";
import { motion, AnimatePresence } from "framer-motion";

interface Format {
  format_id: string;
  ext: string;
  quality: string;
  format_note?: string;
  filesize?: number;
  acodec?: string;
  vcodec?: string;
}

interface VideoInfo {
  id: string;
  title: string;
  formats: Format[];
  thumbnail?: string;
  duration?: number;
  uploader?: string;
}

interface EncodingOptions {
  audioQuality: string;
  videoQuality: string;
  format: string;
}

interface AddDownloadProps {
  isOpen: boolean;
  onClose: () => void;
  onAddDownload: (
    url: string,
    format: string,
    encodingOptions: EncodingOptions
  ) => Promise<void>;
}

// Animation variants
const modalVariants = {
  hidden: { opacity: 0 },
  visible: { opacity: 1 },
  exit: { opacity: 0 },
};

const contentVariants = {
  hidden: { scale: 0.95, opacity: 0 },
  visible: { scale: 1, opacity: 1 },
  exit: { scale: 0.95, opacity: 0 },
};

const formatItemVariants = {
  hidden: { opacity: 0, y: 20 },
  visible: (i: number) => ({
    opacity: 1,
    y: 0,
    transition: { delay: i * 0.05 },
  }),
};

const AddDownload: React.FC<AddDownloadProps> = ({
  isOpen,
  onClose,
  onAddDownload,
}) => {
  const { t } = useTranslation();
  const [url, setUrl] = useState("");
  const [isLoading, setIsLoading] = useState(false);
  const [error, setError] = useState<string | null>(null);
  const [videoInfo, setVideoInfo] = useState<VideoInfo | null>(null);
  const [selectedFormat, setSelectedFormat] = useState<string>("");
  const [encodingOptions, setEncodingOptions] = useState<EncodingOptions>({
    audioQuality: "192",
    videoQuality: "1080",
    format: "mp4",
  });

  const audioQualityOptions = ["64", "128", "192", "256", "320"];
  const videoQualityOptions = ["480", "720", "1080", "1440", "2160"];
  const formatOptions = ["mp4", "mkv", "webm"];

  const resetState = () => {
    setUrl("");
    setError(null);
    setVideoInfo(null);
    setSelectedFormat("");
    setIsLoading(false);
    setEncodingOptions({
      audioQuality: "192",
      videoQuality: "1080",
      format: "mp4",
    });
  };

  const handleClose = () => {
    resetState();
    onClose();
  };

  const handleUrlChange = (e: React.ChangeEvent<HTMLInputElement>) => {
    setUrl(e.target.value);
    setError(null);
    setVideoInfo(null);
  };

  const fetchVideoInfo = async () => {
    if (!url.trim()) {
      setError(t("downloads.errors.emptyUrl"));
      return;
    }

    setIsLoading(true);
    setError(null);
    setVideoInfo(null);

    try {
      const infoString = await invoke<string>("extract_video_info", {
        url: url.trim(),
      });
      const info = JSON.parse(infoString) as VideoInfo;

      if (!info || !info.formats || info.formats.length === 0) {
        throw new Error(t("downloads.errors.noFormatsFound"));
      }

      setVideoInfo(info);
      setSelectedFormat(info.formats[0].format_id);
    } catch (err) {
      console.error("Video info extraction error:", err);
      setError(err instanceof Error ? err.message : String(err));
    } finally {
      setIsLoading(false);
    }
  };

  const handleSubmit = async () => {
    if (!videoInfo || !selectedFormat) {
      return;
    }

    try {
      await onAddDownload(url, selectedFormat, encodingOptions);
      handleClose();
    } catch (err) {
      console.error("Download error:", err);
      setError(err instanceof Error ? err.message : String(err));
    }
  };

  const formatFileSize = (bytes?: number) => {
    if (!bytes) return "Unknown size";
    const sizes = ["B", "KB", "MB", "GB"];
    const i = Math.floor(Math.log(bytes) / Math.log(1024));
    return `${(bytes / Math.pow(1024, i)).toFixed(2)} ${sizes[i]}`;
  };

  const renderEncodingOptions = () => (
    <div className="space-y-3">
      <h3 className="text-gray-300 text-sm font-medium">
        {t("downloads.addModal.encodingOptions")}
      </h3>
      <div className="grid grid-cols-3 gap-4">
        {/* Audio Quality */}
        <div className="space-y-1">
          <label className="text-gray-400 text-xs">
            {t("downloads.addModal.audioQuality")} (kbps)
          </label>
          <select
            value={encodingOptions.audioQuality}
            onChange={(e) =>
              setEncodingOptions((prev) => ({
                ...prev,
                audioQuality: e.target.value,
              }))
            }
            className="w-full bg-[#2a2a2a] text-gray-200 text-sm rounded-md px-2 py-1
                      border border-[#3e3e3e] focus:outline-none focus:border-blue-500"
          >
            {audioQualityOptions.map((quality) => (
              <option key={quality} value={quality}>
                {quality}
              </option>
            ))}
          </select>
        </div>

        {/* Video Quality */}
        <div className="space-y-1">
          <label className="text-gray-400 text-xs">
            {t("downloads.addModal.videoQuality")} (p)
          </label>
          <select
            value={encodingOptions.videoQuality}
            onChange={(e) =>
              setEncodingOptions((prev) => ({
                ...prev,
                videoQuality: e.target.value,
              }))
            }
            className="w-full bg-[#2a2a2a] text-gray-200 text-sm rounded-md px-2 py-1
                      border border-[#3e3e3e] focus:outline-none focus:border-blue-500"
          >
            {videoQualityOptions.map((quality) => (
              <option key={quality} value={quality}>
                {quality}
              </option>
            ))}
          </select>
        </div>

        {/* Output Format */}
        <div className="space-y-1">
          <label className="text-gray-400 text-xs">
            {t("downloads.addModal.outputFormat")}
          </label>
          <select
            value={encodingOptions.format}
            onChange={(e) =>
              setEncodingOptions((prev) => ({
                ...prev,
                format: e.target.value,
              }))
            }
            className="w-full bg-[#2a2a2a] text-gray-200 text-sm rounded-md px-2 py-1
                      border border-[#3e3e3e] focus:outline-none focus:border-blue-500"
          >
            {formatOptions.map((format) => (
              <option key={format} value={format}>
                {format.toUpperCase()}
              </option>
            ))}
          </select>
        </div>
      </div>
    </div>
  );

  if (!isOpen) return null;

  return (
    <AnimatePresence>
      <motion.div
        initial="hidden"
        animate="visible"
        exit="exit"
        variants={modalVariants}
        className="fixed inset-0 bg-black/50 flex items-center justify-center z-50"
        onClick={handleClose}
      >
        <motion.div
          variants={contentVariants}
          transition={{ duration: 0.2 }}
          className="bg-[#1a1a1a] rounded-lg w-full max-w-2xl mx-4 border border-[#2e2e2e]"
          onClick={(e) => e.stopPropagation()}
        >
          {/* Header */}
          <div className="px-4 py-3 border-b border-[#2e2e2e] flex items-center justify-between">
            <h2 className="text-gray-200 text-sm font-medium">
              {t("downloads.addModal.title")}
            </h2>
            <motion.button
              whileHover={{ scale: 1.1 }}
              whileTap={{ scale: 0.9 }}
              onClick={handleClose}
              className="text-gray-400 hover:text-gray-200 transition-colors"
            >
              <X className="w-4 h-4" />
            </motion.button>
          </div>

          {/* Content */}
          <div className="p-4 space-y-4">
            {/* URL Input */}
            <div className="space-y-2">
              <div className="flex gap-2">
                <input
                  type="text"
                  value={url}
                  onChange={handleUrlChange}
                  placeholder={t("downloads.addModal.urlPlaceholder")}
                  className="flex-1 bg-[#2a2a2a] text-gray-200 text-sm rounded-md px-3 py-1
                            border border-[#3e3e3e] focus:outline-none focus:border-blue-500
                            transition-colors"
                />
                <motion.button
                  whileHover={{ scale: 1.02 }}
                  whileTap={{ scale: 0.98 }}
                  onClick={fetchVideoInfo}
                  disabled={isLoading || !url.trim()}
                  className="px-4 py-1 border text-white text-sm rounded-md
                           hover:bg-white hover:text-black disabled:opacity-50 
                           disabled:cursor-not-allowed transition-colors"
                >
                  {isLoading ? t("common.loading") : t("downloads.addModal.fetch")}
                </motion.button>
              </div>

              <AnimatePresence mode="wait">
                {error && (
                  <motion.p
                    initial={{ height: 0, opacity: 0 }}
                    animate={{ height: "auto", opacity: 1 }}
                    exit={{ height: 0, opacity: 0 }}
                    className="text-red-400 text-xs"
                  >
                    {error}
                  </motion.p>
                )}
              </AnimatePresence>
            </div>

            {/* Video Info */}
            <AnimatePresence mode="wait">
              {isLoading ? (
                <motion.div
                  key="loader"
                  initial={{ opacity: 0 }}
                  animate={{ opacity: 1 }}
                  exit={{ opacity: 0 }}
                  className="flex items-center justify-center py-8"
                >
                  <div className="animate-spin rounded-full h-8 w-8 border-t-2 border-b-2 border-blue-500" />
                </motion.div>
              ) : videoInfo &&
                videoInfo.formats &&
                videoInfo.formats.length > 0 ? (
                <motion.div
                  key="content"
                  initial={{ opacity: 0 }}
                  animate={{ opacity: 1 }}
                  exit={{ opacity: 0 }}
                  className="space-y-4"
                >
                  {/* Video Details */}
                  <div className="flex gap-4">
                    {videoInfo.thumbnail && (
                      <motion.img
                        initial={{ opacity: 0 }}
                        animate={{ opacity: 1 }}
                        src={videoInfo.thumbnail}
                        alt={videoInfo.title}
                        className="w-40 h-24 object-cover rounded"
                      />
                    )}
                    <div className="flex-1">
                      <h3 className="text-gray-200 text-sm font-medium line-clamp-2">
                        {videoInfo.title}
                      </h3>
                      {videoInfo.uploader && (
                        <p className="text-gray-400 text-xs mt-1">
                          {videoInfo.uploader}
                        </p>
                      )}
                      {videoInfo.duration && (
                        <p className="text-gray-400 text-xs mt-1">
                          {Math.floor(videoInfo.duration / 60)}:
                          {(videoInfo.duration % 60)
                            .toString()
                            .padStart(2, "0")}
                        </p>
                      )}
                    </div>
                  </div>

                  {/* Encoding Options */}
                  {renderEncodingOptions()}

                  {/* Format Selection */}
                  <div className="space-y-2">
                    <label className="text-gray-300 text-xs">
                      {t("downloads.addModal.selectFormat")}
                    </label>
                    <motion.div layout className="grid grid-cols-1 gap-2 max-h-48 overflow-y-auto">
                      {videoInfo.formats.map((format, index) => (
                        <motion.label
                          key={format.format_id}
                          custom={index}
                          variants={formatItemVariants}
                          initial="hidden"
                          animate="visible"
                          whileHover={{ scale: 1 }}
                          className={`flex items-center p-2 rounded cursor-pointer
                            ${
                              selectedFormat === format.format_id
                                ? "bg-blue-500 bg-opacity-20 border-blue-500"
                                : "bg-[#2a2a2a] border-transparent"
                            } border hover:border-blue-500 transition-all`}
                        >
                          <input
                            type="radio"
                            name="format"
                            value={format.format_id}
                            checked={selectedFormat === format.format_id}
                            onChange={(e) => setSelectedFormat(e.target.value)}
                            className="hidden"
                          />
                          <div className="flex-1 flex items-center gap-3">
                            {format.vcodec && format.acodec ? (
                              <Video className="w-4 h-4 text-gray-400" />
                            ) : (
                              <Music className="w-4 h-4 text-gray-400" />
                            )}
                            <div className="flex-1">
                              <div className="flex items-center justify-between">
                                <span className="text-gray-200 text-xs">
                                  {format.quality}
                                </span>
                                <span className="text-gray-400 text-xs">
                                  {formatFileSize(format.filesize)}
                                </span>
                              </div>
                              <span className="text-gray-400 text-xs">
                                {format.ext.toUpperCase()}
                                {format.format_note &&
                                  ` - ${format.format_note}`}
                              </span>
                            </div>
                          </div>
                        </motion.label>
                      ))}
                    </motion.div>
                  </div>
                </motion.div>
              ) : null}
            </AnimatePresence>
          </div>

          {/* Footer */}
          <div className="px-4 py-3 border-t border-[#2e2e2e] flex justify-end gap-2">
            <motion.button
              whileHover={{ scale: 1.02 }}
              whileTap={{ scale: 0.98 }}
              onClick={handleClose}
              className="px-4 py-1 text-gray-300 text-sm hover:bg-[#2a2a2a] 
                      rounded-md transition-colors"
            >
              {t("common.cancel")}
            </motion.button>
            <motion.button
              whileHover={{ scale: 1.02 }}
              whileTap={{ scale: 0.98 }}
              onClick={handleSubmit}
              disabled={!videoInfo || !selectedFormat || isLoading}
              className="px-4 py-1 border text-white text-sm rounded-md
                       hover:bg-white hover:text-black disabled:opacity-50 
                       disabled:cursor-not-allowed transition-colors
                       flex items-center gap-2"
            >
              <Download className="w-4 h-4" />
              {t("downloads.addModal.download")}
            </motion.button>
          </div>
        </motion.div>
      </motion.div>
    </AnimatePresence>
  );
};

export default AddDownload;