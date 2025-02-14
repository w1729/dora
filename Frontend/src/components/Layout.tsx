import { Container } from './Container';
import { ModeToggle } from './ModeToggle';
import { WalletButton } from './WalletButton';
import Link from 'next/link';
import { ReactNode } from 'react';

export function Layout({ children }: { children: ReactNode }) {
  return (
    <div className="flex flex-col min-h-screen">
      {/* Header */}
      <header className="border-b bg-white shadow-sm">
        <Container className="flex min-h-[4rem] items-center">
          {/* Logo */}
          <div className="flex flex-grow items-center gap-8">
            <Link href="/" className="font-serif text-xl font-bold text-blue-600">
              <span className="mr-1">Dora</span>
            </Link>
          </div>

          {/* Navigation Links */}
          <nav className="flex items-center gap-6">
            <Link
              className="text-sm font-medium text-gray-700 hover:text-blue-600 transition-colors duration-300"
              href="/"
            >
              Dashboard
            </Link>
          
            <Link
              className="text-sm font-medium text-gray-700 hover:text-blue-600 transition-colors duration-300"
              href="/proposal"
            >
              Submit Proposal
            </Link>
            <Link
              className="text-sm font-medium text-gray-700 hover:text-blue-600 transition-colors duration-300"
              href="/chat"
            >
              Chat
            </Link>
            <Link
              className="text-sm font-medium text-gray-700 hover:text-blue-600 transition-colors duration-300"
              href="/viewproposals"
            >
              View Proposals
            </Link>
          </nav>

          {/* Wallet and Theme Toggle */}
          <div className="flex items-center gap-4 ml-8">
            <WalletButton />
            {/* <ModeToggle /> */}
          </div>
        </Container>
      </header>

      {/* Main Content */}
      <main className="flex-1 bg-gray-50">{children}</main>
    </div>
  );
}