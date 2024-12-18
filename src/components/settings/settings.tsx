// mdu/src/components/settings/settings.tsx
import React from "react";
import { useTranslation } from "react-i18next";
import { motion, AnimatePresence } from "framer-motion";
import {
  Settings as SettingsIcon,
  Globe2,
  FolderCog,
  Download,
  Waves,
  Film,
  Palette,
  Info,
  X,
  Sliders,
  ShieldCheck,
  Network,
} from "lucide-react";
import {
  GeneralSettings,
  LanguageSettings,
  DirectorySettings,
//   DownloadSettings,
//   AudioSettings,
//   VideoSettings,
  AppearanceSettings,
  AboutSettings,
//   PrivacySettings,
//   NetworkSettings,
//   AdvancedSettings,
} from "./";

interface SettingsProps {
  isOpen: boolean;
  onClose: () => void;
}

function Settings({ isOpen, onClose }: SettingsProps) {
  const { t } = useTranslation();
  const [activeTab, setActiveTab] = React.useState("general");

  // Animation variants
  const backdropVariants = {
    hidden: { opacity: 0 },
    visible: { opacity: 1 },
  };

  const modalVariants = {
    hidden: {
      scale: 0.95,
      opacity: 0,
    },
    visible: {
      scale: 1,
      opacity: 1,
      transition: {
        type: "spring",
        duration: 0.3,
        bounce: 0.2,
      },
    },
    exit: {
      scale: 0.95,
      opacity: 0,
      transition: {
        duration: 0.2,
      },
    },
  };

  const tabContentVariants = {
    hidden: {
      opacity: 0,
      x: -20,
    },
    visible: {
      opacity: 1,
      x: 0,
      transition: {
        duration: 0.2,
      },
    },
    exit: {
      opacity: 0,
      x: 20,
      transition: {
        duration: 0.2,
      },
    },
  };

  const tabs = [
    // General Section
    {
      id: "general",
      icon: SettingsIcon,
      label: t("settings.tabs.general"),
      section: "general",
    },
    {
      id: "language",
      icon: Globe2,
      label: t("settings.tabs.language"),
      section: "general",
    },
    {
      id: "appearance",
      icon: Palette,
      label: t("settings.tabs.appearance"),
      section: "general",
    },
    // Media Section
    {
      id: "directories",
      icon: FolderCog,
      label: t("settings.tabs.directories"),
      section: "media",
    },
    {
      id: "downloads",
      icon: Download,
      label: t("settings.tabs.downloads"),
      section: "media",
    },
    {
      id: "audio",
      icon: Waves,
      label: t("settings.tabs.audio"),
      section: "media",
    },
    {
      id: "video",
      icon: Film,
      label: t("settings.tabs.video"),
      section: "media",
    },
    // Advanced Section
    {
      id: "network",
      icon: Network,
      label: t("settings.tabs.network"),
      section: "advanced",
    },
    {
      id: "privacy",
      icon: ShieldCheck,
      label: t("settings.tabs.privacy"),
      section: "advanced",
    },
    {
      id: "advanced",
      icon: Sliders,
      label: t("settings.tabs.advanced"),
      section: "advanced",
    },
    // About Section
    {
      id: "about",
      icon: Info,
      label: t("settings.tabs.about"),
      section: "about",
    },
  ];

  const sections = [
    { id: "general", label: t("settings.sections.general") },
    { id: "media", label: t("settings.sections.media") },
    { id: "advanced", label: t("settings.sections.advanced") },
    { id: "about", label: t("settings.sections.about") },
  ];

  const renderContent = () => {
    switch (activeTab) {
      case "general":
        return <GeneralSettings />;
      case "language":
        return <LanguageSettings />;
      case "directories":
        return <DirectorySettings />;
    //   case "downloads":
    //     return <DownloadSettings />;
    //   case "audio":
    //     return <AudioSettings />;
    //   case "video":
    //     return <VideoSettings />;
      case "appearance":
        return <AppearanceSettings />;
    //   case "network":
    //     return <NetworkSettings />;
    //   case "privacy":
    //     return <PrivacySettings />;
    //   case "advanced":
    //     return <AdvancedSettings />;
      case "about":
        return <AboutSettings />;
      default:
        return <GeneralSettings />;
    }
  };

  if (!isOpen) return null;

  return (
    <>
      {/* Backdrop */}
      <motion.div
        className="fixed inset-0 bg-black/50 z-40"
        initial="hidden"
        animate="visible"
        exit="hidden"
        variants={backdropVariants}
        onClick={onClose}
      />

      {/* Modal */}
      <motion.div
        className="fixed inset-8 bg-[#121212] rounded-lg shadow-xl z-50 flex flex-col overflow-hidden border border-[#2e2e2e]"
        variants={modalVariants}
        initial="hidden"
        animate="visible"
        exit="exit"
      >
        {/* Header */}
        <div className="h-8 bg-[#1a1a1a] flex items-center justify-between px-2 border-b border-[#2e2e2e]">
          <motion.div
            className="flex items-center space-x-2"
            initial={{ opacity: 0, x: -20 }}
            animate={{ opacity: 1, x: 0 }}
          >
            <SettingsIcon className="w-4 h-4 text-blue-400" />
            <span className="text-sm text-gray-200 font-medium">
              {t("settings.title")}
            </span>
          </motion.div>
          <motion.button
            onClick={onClose}
            className="text-gray-400 hover:text-gray-200 p-1 rounded-md hover:bg-[#2d2d2d]"
            whileHover={{ scale: 1.1 }}
            whileTap={{ scale: 0.95 }}
          >
            <X className="w-4 h-4" />
          </motion.button>
        </div>

        {/* Content */}
        <div className="flex-1 flex overflow-hidden">
          {/* Sidebar */}
          <div className="w-64 bg-[#1a1a1a] border-r border-[#2e2e2e] overflow-y-auto">
            <nav className="p-2">
              {sections.map((section) => (
                <div key={section.id} className="mb-4">
                  <div className="px-3 py-1 text-xs text-gray-500 uppercase font-medium">
                    {section.label}
                  </div>
                  {tabs
                    .filter((tab) => tab.section === section.id)
                    .map((tab, index) => (
                      <motion.button
                        key={tab.id}
                        onClick={() => setActiveTab(tab.id)}
                        className={`w-full flex items-center space-x-2 px-3 py-2 rounded-md text-sm
                          ${
                            activeTab === tab.id
                              ? "bg-[#2d2d2d] text-blue-400"
                              : "text-gray-300 hover:bg-[#2d2d2d]/50"
                          }`}
                        initial={{ opacity: 0, x: -20 }}
                        animate={{
                          opacity: 1,
                          x: 0,
                          transition: { delay: index * 0.05 },
                        }}
                        whileHover={{ x: 4 }}
                        whileTap={{ scale: 0.98 }}
                      >
                        <tab.icon className="w-4 h-4" />
                        <span>{tab.label}</span>
                      </motion.button>
                    ))}
                </div>
              ))}
            </nav>
          </div>

          {/* Main Content */}
          <AnimatePresence mode="wait">
            <motion.div
              key={activeTab}
              className="flex-1 overflow-auto"
              variants={tabContentVariants}
              initial="hidden"
              animate="visible"
              exit="exit"
            >
              {renderContent()}
            </motion.div>
          </AnimatePresence>
        </div>
      </motion.div>
    </>
  );
}

export default Settings;