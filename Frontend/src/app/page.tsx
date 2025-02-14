'use client';

import { AlertTriangle, DicesIcon, UserIcon } from 'lucide-react';
import Link from 'next/link';
import { Container } from '~/components/Container';
import { Randomness } from '~/components/Randomness';
import { RequestsTable } from '~/components/RequestsTable';
import { Button } from '~/components/ui/button';
import { Card, CardContent, CardHeader, CardTitle } from '~/components/ui/card';
import { Separator } from '~/components/ui/separator';
import { useRequests } from '~/hooks/useRequests';

export default function DashboardPage() {
  const { data, mutate: refresh } = useRequests();
  
  return (
    <Container className="space-y-4 p-8 pt-6">
    

      <Separator />
      <Randomness
        onSuccess={() => {
          setTimeout(() => {
            refresh();
          }, 2000);
        }}
      />
      <Separator />
    
    </Container>
  );
}
