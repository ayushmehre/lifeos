import type { NextConfig } from "next";
import withPWA from "next-pwa";

// Configure next-pwa and then wrap the Next.js config
const withPWAConfigured = withPWA({
  dest: "public",
  register: true,
  skipWaiting: true,
  disable: process.env.NODE_ENV === "development",
});

const nextConfig: NextConfig = {
  reactStrictMode: true,
};

export default withPWAConfigured(nextConfig);
