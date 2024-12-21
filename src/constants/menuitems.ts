// mdu/src/constants/menuitems.ts
import { TFunction } from 'i18next';

export const createMenuItems = (t: TFunction) => ({
  [t('menu.file.title')]: [
    { label: t('menu.file.newProject'), shortcut: 'Ctrl+N' },
    { label: t('menu.file.openProject'), shortcut: 'Ctrl+O' },
    { label: t('menu.file.openRecent') },
    { type: 'separator' },
    { label: t('menu.file.save'), shortcut: 'Ctrl+S' },
    { label: t('menu.file.saveAs'), shortcut: 'Ctrl+Shift+S' },
    { label: t('menu.file.export'), shortcut: 'Ctrl+E' },
    { type: 'separator' },
    { label: t('menu.file.projectSettings'), shortcut: 'Ctrl+,' },
    { type: 'separator' },
    { label: t('menu.file.exit'), shortcut: 'Alt+F4' }
  ],
  [t('menu.edit.title')]: [
    { label: t('menu.edit.undo'), shortcut: 'Ctrl+Z' },
    { label: t('menu.edit.redo'), shortcut: 'Ctrl+Y' },
    { type: 'separator' },
    { label: t('menu.edit.cut'), shortcut: 'Ctrl+X' },
    { label: t('menu.edit.copy'), shortcut: 'Ctrl+C' },
    { label: t('menu.edit.paste'), shortcut: 'Ctrl+V' },
    { label: t('menu.edit.delete'), shortcut: 'Delete' },
    { type: 'separator' },
    { label: t('menu.edit.selectAll'), shortcut: 'Ctrl+A' },
    { label: t('menu.edit.deselect'), shortcut: 'Ctrl+D' },
    { type: 'separator' },
    { label: t('menu.edit.preferences'), shortcut: 'Ctrl+P' }
  ],
  [t('menu.view.title')]: [
    { label: t('menu.view.zoomIn'), shortcut: 'Ctrl+Plus' },
    { label: t('menu.view.zoomOut'), shortcut: 'Ctrl+Minus' },
    { label: t('menu.view.resetZoom'), shortcut: 'Ctrl+0' },
    { type: 'separator' },
    { label: t('menu.view.toggleFullscreen'), shortcut: 'F11' },
    { type: 'separator' },
    { label: t('menu.view.showSidebar'), shortcut: 'Ctrl+B' },
    { label: t('menu.view.showConsole'), shortcut: 'Ctrl+`' },
    { label: t('menu.view.showStatusBar') },
    { type: 'separator' },
    {
      label: t('menu.view.theme.title'),
      submenu: [
        { label: t('menu.view.theme.light') },
        { label: t('menu.view.theme.dark') },
        { label: t('menu.view.theme.system') }
      ]
    }
  ],
  [t('menu.tools.title')]: [
    { label: t('menu.tools.downloadManager'), shortcut: 'Ctrl+D' },
    { label: t('menu.tools.batchConverter'), shortcut: 'Ctrl+B' },
    { label: t('menu.tools.audioExtractor'), shortcut: 'Ctrl+A' },
    { label: t('menu.tools.videoRemuxer'), shortcut: 'Ctrl+R' },
    { type: 'separator' },
    { label: t('menu.tools.formatSettings') },
    { label: t('menu.tools.qualityPresets') },
    { type: 'separator' },
    { label: t('menu.tools.developerTools'), shortcut: 'F12' }
  ],
  [t('menu.more.title')]: [
    { label: t('menu.more.checkUpdates') },
    { label: t('menu.more.documentation'), shortcut: 'F1' },
    { label: t('menu.more.keyboardShortcuts'), shortcut: 'Ctrl+K' },
    { type: 'separator' },
    { label: t('menu.more.reportIssue') },
    { label: t('menu.more.supportForum') },
    { type: 'separator' },
    { label: t('menu.more.about') }
  ]
});