'use client';

import { useEffect, useState } from 'react';
import { useContractRead } from 'wagmi';
import axios from 'axios';

interface Proposal {
  projectTitle: string;
  applicantName: string;
  contactEmail: string;
  projectSummary: string;
  objectives: string;
  problemStatement: string;
  targetAudience: string;
  timeline: string;
  budget: string;
  impact: string;
  evaluationPlan: string;
  sustainabilityPlan: string;
  teamDetails: string;
}

export function ViewProposals() {
  const [proposals, setProposals] = useState<Proposal[]>([]);
  const [loading, setLoading] = useState(true);

  // Fetch IPFS hashes from the contract (disabled for now)
  const { data: ipfsHashes } = useContractRead({
    address: '0xYourContractAddress', // Replace with your contract address
    abi: [
      {
        inputs: [],
        name: 'getAllProposals',
        outputs: [{ internalType: 'string[]', name: '', type: 'string[]' }],
        stateMutability: 'view',
        type: 'function',
      },
    ],
    functionName: 'getAllProposals',
    enabled: false, // Disable contract read for now
  });

  // Manually provide IPFS hashes for testing
  const manualIpfsHashes = [
    'QmWUbJ6ttkch53tFNn23DcSZN9akLqTBJN71tfB94WZzP7','QmcbitGCwTdHSiZ2TbgysgmMD37ZMoSqes8Ko4xm7xDEzW',
  
  ];

  useEffect(() => {
    const fetchProposals = async () => {
      const hashesToUse = manualIpfsHashes; // Use manual hashes for now
      // const hashesToUse = ipfsHashes; // Uncomment this to use contract hashes in the future

      if (hashesToUse && Array.isArray(hashesToUse)) {
        const fetchedProposals: Proposal[] = [];
        for (const hash of hashesToUse) {
          try {
            const response = await axios.get(`https://ipfs.io/ipfs/${hash}`);
            fetchedProposals.push(response.data);
          } catch (error) {
            console.error('Error fetching proposal from IPFS:', error);
          }
        }
        setProposals(fetchedProposals);
        setLoading(false);
      }
    };

    fetchProposals();
  }, [ipfsHashes]); // Still watching ipfsHashes, but it's disabled

  if (loading) {
    return <div>Loading proposals...</div>;
  }

  return (
    <div className="max-w-4xl mx-auto p-6 bg-white shadow-lg rounded-lg mt-10">
      <h2 className="text-2xl font-semibold mb-6 text-center">View Grant Proposals</h2>
      {proposals.length === 0 ? (
        <div className="text-center text-gray-500">No proposals found.</div>
      ) : (
        <div className="space-y-6">
          {proposals.map((proposal, index) => (
            <div key={index} className="p-4 border rounded-lg">
              <h3 className="text-xl font-semibold mb-2">{proposal.projectTitle}</h3>
              <p className="text-gray-700 mb-2">
                <strong>Applicant:</strong> {proposal.applicantName}
              </p>
              <p className="text-gray-700 mb-2">
                <strong>Contact Email:</strong> {proposal.contactEmail}
              </p>
              <p className="text-gray-700 mb-2">
                <strong>Summary:</strong> {proposal.projectSummary}
              </p>
              <p className="text-gray-700 mb-2">
                <strong>Objectives:</strong> {proposal.objectives}
              </p>
              <p className="text-gray-700 mb-2">
                <strong>Problem Statement:</strong> {proposal.problemStatement}
              </p>
              <p className="text-gray-700 mb-2">
                <strong>Target Audience:</strong> {proposal.targetAudience}
              </p>
              <p className="text-gray-700 mb-2">
                <strong>Timeline:</strong> {proposal.timeline}
              </p>
              <p className="text-gray-700 mb-2">
                <strong>Budget:</strong> {proposal.budget}
              </p>
              <p className="text-gray-700 mb-2">
                <strong>Impact:</strong> {proposal.impact}
              </p>
              <p className="text-gray-700 mb-2">
                <strong>Evaluation Plan:</strong> {proposal.evaluationPlan}
              </p>
              <p className="text-gray-700 mb-2">
                <strong>Sustainability Plan:</strong> {proposal.sustainabilityPlan}
              </p>
              <p className="text-gray-700 mb-2">
                <strong>Team Details:</strong> {proposal.teamDetails}
              </p>
            </div>
          ))}
        </div>
      )}
    </div>
  );
}