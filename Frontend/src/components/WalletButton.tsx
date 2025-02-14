'use client';

import { Button } from './ui/button';
import { useWeb3Modal } from '@web3modal/wagmi/react';
import Avatar from 'boring-avatars';
import { Suspense } from 'react';
import { useAccount } from 'wagmi';
import { useIsMounted } from '~/hooks/useIsMounted';
export function WalletButton() {
  const mounted=useIsMounted();
  const { address, isConnected } = useAccount();
  const { open } = useWeb3Modal();

  if (isConnected && !!address) {
    return (
      <>
        {mounted ? (
          <button
            onClick={() => open()}
            className="flex items-center gap-2 p-2 rounded-lg hover:bg-gray-100 transition-colors duration-300"
          >
            <Avatar
              size={32}
              name={address}
              variant="beam"
              colors={["#92A1C6", "#146A7C", "#F0AB3D", "#C271B4", "#C20D90"]}
            />
            <span className="text-sm font-medium text-gray-700">
              {`${address.slice(0, 6)}...${address.slice(-4)}`}
            </span>
          </button>
        ) : (
          <Button
            variant="outline"
            onClick={() => open()}
            className="border-blue-600 text-blue-600 hover:bg-blue-600 hover:text-white transition-colors duration-300"
          >
            Connect Wallet
          </Button>
        )}
      </>
    );
  }
  

  return (
    <Button
      variant="outline"
      onClick={() => open()}
      className="border-blue-600 text-blue-600 hover:bg-blue-600 hover:text-white transition-colors duration-300"
    >
      Connect Wallet
    </Button>
  );
}
