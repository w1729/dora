'use client';

import { Container } from '~/components/Container';
import {SubmitPro} from   '~/components/SubmitProposal';
import Chat from "~/components/Chat";


export default function OperatorPage() {
  return (
    <Container className="space-y-4 p-8 pt-6">
      
      <Chat/>
    </Container>
  );
}