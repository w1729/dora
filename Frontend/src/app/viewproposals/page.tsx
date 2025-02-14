'use client';

import { Container } from '~/components/Container';
import {SubmitPro} from   '~/components/SubmitProposal';
import { ViewProposals } from '~/components/ViewProposals';


export default function OperatorPage() {
  return (
    <Container className="space-y-4 p-8 pt-6">
      
      <ViewProposals/>
    </Container>
  );
}