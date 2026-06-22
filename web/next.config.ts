import type { NextConfig } from "next";

const nextConfig: NextConfig = {
  async redirects() {
    return [
      {
        source: '/api-docs',
        destination: '/api--document.html',
        permanent: false,
      },
      {
        source: '/docs',
        destination: '/api--document.html',
        permanent: false,
      },
    ];
  },
  images: {
    remotePatterns: [
      {
        protocol: "https",
        hostname: "images.unsplash.com",
      },
      {
        protocol: "https",
        hostname: "lh3.googleusercontent.com",
      },
      {
        protocol: "https",
        hostname: "api.dicebear.com",
      },
      {
        protocol: "https",
        hostname: "ui-avatars.com",
      },
      {
        protocol: "https",
        hostname: "uevent-media-bucket.s3.ap-southeast-1.amazonaws.com",
      },
    ],
  },
};

export default nextConfig;
