// mdu/src/components/windowed/header.tsx
import { useNavigate, useLocation } from 'react-router-dom';
import { useTranslation } from 'react-i18next';
import { useState } from 'react';
import {
    Download,
    FileOutput,
    Music2,
    Film,
    Settings as SettingsIcon,
    MenuIcon
} from 'lucide-react';
import { Settings } from '../settings';

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
                <div className="">
                    <button className='flex items-center space-x-2 text-xs'>
                        <MenuIcon className="w-3.5 h-3.5" />
                        <p>Menu</p>
                    </button>
                </div>

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