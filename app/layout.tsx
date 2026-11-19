import type { Metadata } from 'next';
import './globals.css';

export const metadata: Metadata = {
  title: 'TeamVault',
  description: 'Multi-Tenant Project & Asset Management SaaS',
};

export default function RootLayout({
  children,
}: Readonly<{
  children: React.ReactNode;
}>) {
  return (
    <html lang="en">
      <body className="min-h-screen antialiased">{children}</body>
    </html>
  );
}
