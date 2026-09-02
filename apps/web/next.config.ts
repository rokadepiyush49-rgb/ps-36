import path from "node:path";
import type { NextConfig } from "next";

const nextConfig: NextConfig = {
  // Pin the workspace root so Turbopack ignores the stray lockfile in $HOME.
  turbopack: { root: path.resolve(".") },
};

export default nextConfig;
