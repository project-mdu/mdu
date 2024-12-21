// src/components/converter/converter.tsx
import { useState, useEffect } from "react";
import { FileVideo, StopCircle, Trash2, Plus, Search } from "lucide-react";
import { invoke } from "@tauri-apps/api/core";
import { useTranslation } from "react-i18next";
import ConverterList from "./converterlists";
import AddConversion from "./addconversion";
import { ConversionItem, ConversionOptions } from "./types";

function Converter() {
  const [isLoading, setIsLoading] = useState<boolean>(false);
  const [conversionData, setConversionData] = useState<ConversionItem[]>([]);
  const [activeConversions, setActiveConversions] = useState<ConversionItem[]>(
    [],
  );
  const [showConversionModal, setShowConversionModal] =
    useState<boolean>(false);
  const [searchQuery, setSearchQuery] = useState<string>("");
  const { t } = useTranslation();

  useEffect(() => {
    loadConversionHistory();
    // Set up event listener for conversion updates
    const interval = setInterval(loadConversionHistory, 1000);
    return () => clearInterval(interval);
  }, []);

  const loadConversionHistory = async () => {
    try {
      const history = await invoke<ConversionItem[]>("get_conversion_history");
      const active = history.filter((item) => item.status === "converting");
      const others = history.filter((item) => item.status !== "converting");

      setActiveConversions(active);
      setConversionData(others);
    } catch (error) {
      console.error("Failed to load conversion history:", error);
    }
  };

  const handleAddConversion = async (
    inputPath: string,
    format: string,
    options: ConversionOptions,
  ) => {
    try {
      await invoke("start_conversion", {
        inputPath,
        format,
        options: {
          ...options,
          outputFormat: format,
        },
      });
      loadConversionHistory();
      setShowConversionModal(false);
    } catch (error) {
      console.error("Failed to start conversion:", error);
      throw error;
    }
  };

  const handleStopConversion = async (conversionId: string) => {
    try {
      await invoke("stop_conversion", { conversionId });
      if (conversionId === "all") {
        setActiveConversions([]);
      } else {
        setActiveConversions((prev) =>
          prev.filter((c) => c.conversionId !== conversionId),
        );
      }
      loadConversionHistory();
    } catch (error) {
      console.error("Failed to stop conversion:", error);
    }
  };

  const handleClearHistory = async () => {
    try {
      if (activeConversions.length > 0) {
        const confirm = window.confirm(
          t("converter.confirmations.clearActiveWarning"),
        );
        if (!confirm) return;
      }

      await invoke("clear_conversion_history");
      setConversionData([]);
    } catch (error) {
      console.error("Failed to clear history:", error);
    }
  };

  const handleStopAll = async () => {
    try {
      const confirm = window.confirm(
        t("converter.confirmations.stopAllConversions"),
      );
      if (!confirm) return;

      await invoke("stop_all_conversions");
      await loadConversionHistory();
    } catch (error) {
      console.error("Failed to stop all conversions:", error);
    }
  };

  return (
    <div className="h-full flex flex-col bg-[#121212]">
      {/* Header */}
      <div className="h-8 bg-[#1a1a1a] flex items-center justify-between px-2 border-b border-[#2e2e2e]">
        <div className="flex items-center space-x-1">
          <FileVideo className="w-4 h-4 text-green-400" />
          <span className="text-xs text-gray-200 font-medium">
            {t("converter.title")}
          </span>
          {activeConversions.length > 0 && (
            <span className="text-xs text-gray-400">
              ({activeConversions.length} {t("converter.status.active")})
            </span>
          )}
        </div>
        <div className="flex items-center space-x-1">
          <button
            onClick={() => setShowConversionModal(true)}
            className="text-gray-300 hover:bg-[#2d2d2d] p-1 rounded-md"
            title={t("converter.tooltips.addNew")}
          >
            <Plus className="w-4 h-4" />
          </button>
          <button
            className="text-gray-300 hover:bg-[#2d2d2d] p-1 rounded-md disabled:opacity-50"
            disabled={activeConversions.length === 0}
            onClick={handleStopAll}
            title={t("converter.tooltips.stopAll")}
          >
            <StopCircle className="w-4 h-4" />
          </button>
          <button
            className="text-gray-300 hover:bg-[#2d2d2d] p-1 rounded-md disabled:opacity-50"
            disabled={conversionData.length === 0}
            onClick={handleClearHistory}
            title={t("converter.tooltips.clearHistory")}
          >
            <Trash2 className="w-4 h-4" />
          </button>
        </div>
      </div>

      {/* Main Content */}
      <div className="flex-1 flex">
        <div className="flex-1 p-4">
          <div className="h-full flex flex-col space-y-3">
            {/* Search Bar */}
            <div className="relative">
              <Search className="absolute left-2.5 top-1/2 transform -translate-y-1/2 w-4 h-4 text-gray-400" />
              <input
                type="text"
                placeholder={t("converter.search.placeholder")}
                className="w-full h-8 bg-[#1a1a1a] text-gray-200 text-xs pl-9 pr-4 rounded-md
                          focus:outline-none focus:ring-1 focus:ring-green-500 border border-[#2e2e2e]"
                value={searchQuery}
                onChange={(e) => setSearchQuery(e.target.value)}
              />
            </div>

            {/* Conversion List */}
            <div className="flex-1 overflow-auto">
              {activeConversions.length === 0 && conversionData.length === 0 ? (
                <div className="h-full flex flex-col items-center justify-center text-gray-400 text-sm space-y-2">
                  <FileVideo className="w-8 h-8" />
                  <span className="text-xs">
                    {t("converter.status.noConversions")}
                  </span>
                  <button
                    onClick={() => setShowConversionModal(true)}
                    className="text-green-400 hover:text-green-300 text-xs"
                  >
                    {t("converter.actions.addFirst")}
                  </button>
                </div>
              ) : (
                <ConverterList
                  conversions={[...activeConversions, ...conversionData]}
                  searchQuery={searchQuery}
                  onStopConversion={handleStopConversion}
                />
              )}
            </div>
          </div>
        </div>
      </div>

      {/* Conversion Modal */}
      <AddConversion
        isOpen={showConversionModal}
        onClose={() => setShowConversionModal(false)}
        onAddConversion={handleAddConversion}
      />
    </div>
  );
}

export default Converter;
