// mdu/src/components/windowed/layout.tsx
import Header from './header';
import Sidebar from './sidebar';
import StatusBar from './statusbar';

function Layout({ children }: { children: React.ReactNode }) {
    return (
        <div className="h-screen flex flex-col bg-[#121212]">
            <Header />
            <div className="flex flex-1 overflow-hidden">
                <Sidebar />
                <main className="flex-1 overflow-auto">
                    {children}
                </main>
            </div>
            <StatusBar />
        </div>
    );
}

export default Layout;