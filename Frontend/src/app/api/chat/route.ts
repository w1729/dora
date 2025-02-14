import { togetherai } from '@ai-sdk/togetherai';
import { streamText } from "ai";
import { tools } from "../../../ai/tools";
export const maxDuration = 30;

export async function POST(req: Request) {
  const { messages } = await req.json();

  const result = streamText({
    model: togetherai("meta-llama/Llama-3.3-70B-Instruct-Turbo"),
    system: "You are a highly knowledgeable and efficient crypto assistant specializing in ZKVerify Chain and related blockchain technologies. You provide expert guidance on zero-knowledge proofs (ZKPs), ZKVRF, smart contracts, DeFi, decentralized science (DeSci), account abstraction, security best practices, and blockchain integrations.You assist with technical implementations, proof verification, debugging, and optimizing ZK applications while ensuring seamless user experiences. You also help users understand DoraNode, gasless transactions, and proof submission workflows.Your responses are clear, concise, and actionable, making complex blockchain concepts easy to understand and implement.",
    messages,
    tools,
  });

  return result.toDataStreamResponse();
}