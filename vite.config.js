import { resolve } from "path";
import { defineConfig } from "vite";
import tailwindcss from "@tailwindcss/vite";

export default defineConfig({
    root: "src",
    plugins: [tailwindcss()],
    build: {
        outDir: resolve(import.meta.dirname, "dist"),
        emptyOutDir: true,
        rollupOptions: {
            input: {
                index: resolve(import.meta.dirname, "src/index.html"),
                "common-ground/index": resolve(import.meta.dirname, "src/common-ground/index.html"),
                "neighbor-first/index": resolve(import.meta.dirname, "src/neighbor-first/index.html"),
                "bold-campaign/index": resolve(import.meta.dirname, "src/bold-campaign/index.html"),
                "refined/index": resolve(import.meta.dirname, "src/refined/index.html")
            }
        }
    }
});
