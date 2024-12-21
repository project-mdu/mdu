// mdu/src/components/windowed/header.tsx
import { useNavigate, useLocation } from 'react-router-dom';
import { useTranslation } from 'react-i18next';
import { useState } from 'react';
import {
    Download,
    FileOutput,
    Music2,
    Film,
    Settings as SettingsIcon
} from 'lucide-react';
import { Settings } from '../settings';
import { createMenuItems } from '../../constants/menuitems';
function MenuBar() {
    const { t } = useTranslation();
    const [activeMenu, setActiveMenu] = useState<string | null>(null);
    // const [activeSubmenu, setActiveSubmenu] = useState<string | null>(null);

    const menuItems = createMenuItems(t);

    return (
        <div className="relative flex items-center space-x-0">
            {Object.keys(menuItems).map((menuTitle) => (
                <div key={menuTitle} className="relative">
                    <button
                        className={`flex items-center space-x-2 text-xs px-2 py-1 hover:bg-[#2d2d2d] rounded ${
                            activeMenu === menuTitle ? 'bg-[#2d2d2d]' : ''
                        }`}
                        onClick={() => setActiveMenu(activeMenu === menuTitle ? null : menuTitle)}
                        onMouseEnter={() => activeMenu && setActiveMenu(menuTitle)}
                    >
                        {menuTitle}
                    </button>
                    
                    {/* Dropdown Menu */}
                    {activeMenu === menuTitle && (
                        <div className="absolute top-full left-0 mt-1 bg-[#2d2d2d] rounded-md shadow-lg py-1 min-w-[200px] z-50">
                            {menuItems[menuTitle as keyof typeof menuItems].map((item, index) => (
                                item.type === 'separator' ? (
                                    <div key={index} className="h-[1px] bg-gray-700 my-1" />
                                ) : (
                                    <button
                                        key={index}
                                        className="w-full px-4 py-1.5 text-left text-xs hover:bg-[#3d3d3d] flex justify-between items-center"
                                        onClick={() => {
                                            // Handle menu item click
                                            setActiveMenu(null);
                                        }}
                                    >
                                        <span>{item.label}</span>
                                        {item.shortcut && (
                                            <span className="text-gray-400 ml-4">{item.shortcut}</span>
                                        )}
                                    </button>
                                )
                            ))}
                        </div>
                    )}
                </div>
            ))}
        </div>
    );
}
function Header() {
    const navigate = useNavigate();
    const location = useLocation();
    const { t } = useTranslation();
    const [showSettings, setShowSettings] = useState(false);

    const isActive = (path: string) => location.pathname === path;

    const menuItems = [
        {
            path: '/',
            icon: Download,
            label: t('navigation.downloader')
        },
        {
            path: '/converter',
            icon: FileOutput,
            label: t('navigation.converter')
        },
        {
            path: '/stem-extractor',
            icon: Music2,
            label: t('navigation.stemExtractor')
        },
        {
            path: '/remux',
            icon: Film,
            label: t('navigation.remux')
        }
    ];

    return (
        <>
            {/* Header Bar */}
            <div className="text-gray-200 h-8 flex items-center justify-between bg-[#1a1a1a] px-2 border-b border-[#2e2e2e]">
                {/* Menu */}
                <MenuBar />

                {/* Navigation */}
                <div className="flex items-center space-x-4">
                    {/* Menu Items */}
                    {menuItems.map((item) => (
                        <button
                            key={item.path}
                            onClick={() => navigate(item.path)}
                            className={`text-xs flex items-center ${isActive(item.path)
                                ? 'text-blue-400'
                                : 'opacity-70 hover:opacity-100 hover:text-blue-400'
                                } duration-150`}
                        >
                            <item.icon className="w-3.5 h-3.5 mr-1" />
                            <span className="select-none">{item.label}</span>
                        </button>
                    ))}

                    {/* Separator */}
                    <div className="h-3.5 w-[1px] bg-gray-700 mx-1" />

                    {/* Settings Button */}
                    <button
                        onClick={() => setShowSettings(true)}
                        className={`p-1 rounded-md ${showSettings
                            ? 'text-blue-400 bg-[#2d2d2d]'
                            : 'text-gray-400 hover:text-gray-200'
                            } duration-150`}
                        title={t('navigation.settings')}
                    >
                        <SettingsIcon className="w-3.5 h-3.5" />
                    </button>
                </div>
            </div>

            {/* Settings Modal */}
            <Settings
                isOpen={showSettings}
                onClose={() => setShowSettings(false)}
            />
        </>
    );
}

export default Header;