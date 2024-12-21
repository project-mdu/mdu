// mdu/src/App.tsx
import { BrowserRouter as Router, Routes, Route } from "react-router-dom";
import Layout from "./components/windowed/layouts";
import Downloads from "./components/downloads/download";
import Converter from "./components/converter/converter";
import "./i18n";

// Placeholder components for other routes
const StemExtractor = () => (
  <div className="p-4 text-gray-200">
    Stem Extractor Component (Coming Soon)
  </div>
);
const Remux = () => (
  <div className="p-4 text-gray-200">Remux Component (Coming Soon)</div>
);

function App() {
  return (
    <Router>
      <Layout>
        <Routes>
          <Route path="/" element={<Downloads />} />
          <Route path="/converter" element={<Converter />} />
          <Route path="/stem-extractor" element={<StemExtractor />} />
          <Route path="/remux" element={<Remux />} />
          <Route
            path="*"
            element={
              <div className="p-4 text-center text-gray-400">
                Page not found
              </div>
            }
          />
        </Routes>
      </Layout>
    </Router>
  );
}

export default App;
