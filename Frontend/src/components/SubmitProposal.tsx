'use client';

import { useState } from 'react';
import { useContractWrite } from 'wagmi';
import axios from 'axios';
import { Button } from '~/components/ui/button';

export function SubmitPro() {
  const [formData, setFormData] = useState({
    projectTitle: '',
    applicantName: '',
    contactEmail: '',
    projectSummary: '',
    objectives: '',
    problemStatement: '',
    targetAudience: '',
    timeline: '',
    budget: '',
    impact: '',
    evaluationPlan: '',
    sustainabilityPlan: '',
    teamDetails: '',
  });
  const [loading, setLoading] = useState(false);

  const { write } = useContractWrite({
    address: '0xYourContractAddress', // Replace with your contract address
    abi: [
      {
        inputs: [{ internalType: 'string', name: 'ipfsHash', type: 'string' }],
        name: 'storeProposal',
        outputs: [],
        stateMutability: 'nonpayable',
        type: 'function',
      },
    ],
    functionName: 'storeProposal',
  });

  const handleChange = (e: React.ChangeEvent<HTMLInputElement | HTMLTextAreaElement>) => {
    const { name, value } = e.target;
    setFormData((prev) => ({ ...prev, [name]: value }));
  };

  const uploadToIPFS = async () => {
    setLoading(true);
    try {
      // Convert form data to JSON
      const proposalJson = JSON.stringify(formData);
      const formDataForIPFS = new FormData();
      formDataForIPFS.append('file', new Blob([proposalJson], { type: 'application/json' }));

      // Upload to IPFS via Pinata
      const response = await axios.post('https://api.pinata.cloud/pinning/pinFileToIPFS', formDataForIPFS, {
        headers: {
          'Content-Type': 'multipart/form-data',
          pinata_api_key: process.env.NEXT_PUBLIC_PINATA_API_KEY, // Replace with your Pinata API key
          pinata_secret_api_key: process.env.NEXT_PUBLIC_PINATA_SECRET_KEY, // Replace with your Pinata secret key
        },
      });

      const ipfsHash = response.data.IpfsHash;
      console.log('IPFS Hash:', ipfsHash);

      // Call the smart contract to store the IPFS hash
      write({ args: [ipfsHash] });
    } catch (error) {
      console.error('Error uploading to IPFS:', error);
    } finally {
      setLoading(false);
    }
  };

  return (
    <div className="max-w-2xl mx-auto p-6 bg-white shadow-lg rounded-lg mt-10">
      <h2 className="text-2xl font-semibold mb-6 text-center">Submit Your Grant Proposal</h2>
      <form className="space-y-4">
        {/* Basic Information */}
        <div>
          <label className="block text-sm font-medium mb-1">Project Title</label>
          <input
            type="text"
            name="projectTitle"
            value={formData.projectTitle}
            onChange={handleChange}
            className="w-full p-2 border rounded-lg focus:outline-none focus:ring-2 focus:ring-blue-500"
            placeholder="Enter project title"
          />
        </div>
        <div>
          <label className="block text-sm font-medium mb-1">Applicant Name/Organization</label>
          <input
            type="text"
            name="applicantName"
            value={formData.applicantName}
            onChange={handleChange}
            className="w-full p-2 border rounded-lg focus:outline-none focus:ring-2 focus:ring-blue-500"
            placeholder="Enter your name or organization"
          />
        </div>
        <div>
          <label className="block text-sm font-medium mb-1">Contact Email</label>
          <input
            type="email"
            name="contactEmail"
            value={formData.contactEmail}
            onChange={handleChange}
            className="w-full p-2 border rounded-lg focus:outline-none focus:ring-2 focus:ring-blue-500"
            placeholder="Enter your email"
          />
        </div>

        {/* Project Overview */}
        <div>
          <label className="block text-sm font-medium mb-1">Project Summary</label>
          <textarea
            name="projectSummary"
            value={formData.projectSummary}
            onChange={handleChange}
            className="w-full p-2 border rounded-lg focus:outline-none focus:ring-2 focus:ring-blue-500"
            placeholder="Provide a brief summary of your project"
            rows={3}
          />
        </div>
        <div>
          <label className="block text-sm font-medium mb-1">Objectives</label>
          <textarea
            name="objectives"
            value={formData.objectives}
            onChange={handleChange}
            className="w-full p-2 border rounded-lg focus:outline-none focus:ring-2 focus:ring-blue-500"
            placeholder="What are the goals of your project?"
            rows={3}
          />
        </div>
        <div>
          <label className="block text-sm font-medium mb-1">Problem Statement</label>
          <textarea
            name="problemStatement"
            value={formData.problemStatement}
            onChange={handleChange}
            className="w-full p-2 border rounded-lg focus:outline-none focus:ring-2 focus:ring-blue-500"
            placeholder="What problem are you trying to solve?"
            rows={3}
          />
        </div>
        <div>
          <label className="block text-sm font-medium mb-1">Target Audience</label>
          <textarea
            name="targetAudience"
            value={formData.targetAudience}
            onChange={handleChange}
            className="w-full p-2 border rounded-lg focus:outline-none focus:ring-2 focus:ring-blue-500"
            placeholder="Who will benefit from your project?"
            rows={3}
          />
        </div>

        {/* Project Plan */}
        <div>
          <label className="block text-sm font-medium mb-1">Timeline</label>
          <textarea
            name="timeline"
            value={formData.timeline}
            onChange={handleChange}
            className="w-full p-2 border rounded-lg focus:outline-none focus:ring-2 focus:ring-blue-500"
            placeholder="Provide a timeline for your project"
            rows={3}
          />
        </div>
        <div>
          <label className="block text-sm font-medium mb-1">Budget</label>
          <textarea
            name="budget"
            value={formData.budget}
            onChange={handleChange}
            className="w-full p-2 border rounded-lg focus:outline-none focus:ring-2 focus:ring-blue-500"
            placeholder="Provide a detailed budget breakdown"
            rows={3}
          />
        </div>

        {/* Impact and Evaluation */}
        <div>
          <label className="block text-sm font-medium mb-1">Expected Impact</label>
          <textarea
            name="impact"
            value={formData.impact}
            onChange={handleChange}
            className="w-full p-2 border rounded-lg focus:outline-none focus:ring-2 focus:ring-blue-500"
            placeholder="What impact do you expect from your project?"
            rows={3}
          />
        </div>
        <div>
          <label className="block text-sm font-medium mb-1">Evaluation Plan</label>
          <textarea
            name="evaluationPlan"
            value={formData.evaluationPlan}
            onChange={handleChange}
            className="w-full p-2 border rounded-lg focus:outline-none focus:ring-2 focus:ring-blue-500"
            placeholder="How will you measure the success of your project?"
            rows={3}
          />
        </div>
        <div>
          <label className="block text-sm font-medium mb-1">Sustainability Plan</label>
          <textarea
            name="sustainabilityPlan"
            value={formData.sustainabilityPlan}
            onChange={handleChange}
            className="w-full p-2 border rounded-lg focus:outline-none focus:ring-2 focus:ring-blue-500"
            placeholder="How will your project be sustained after the grant?"
            rows={3}
          />
        </div>

        {/* Team Details */}
        <div>
          <label className="block text-sm font-medium mb-1">Team Details</label>
          <textarea
            name="teamDetails"
            value={formData.teamDetails}
            onChange={handleChange}
            className="w-full p-2 border rounded-lg focus:outline-none focus:ring-2 focus:ring-blue-500"
            placeholder="Provide details about your team"
            rows={3}
          />
        </div>

        {/* Submit Button */}
        <Button
          className="mt-6 w-full bg-blue-600 text-white font-bold py-2 px-4 rounded-lg hover:bg-blue-700 disabled:opacity-50"
          onClick={uploadToIPFS}
          disabled={loading || !formData.projectTitle.trim()}
        >
          {loading ? 'Uploading...' : 'Submit Proposal'}
        </Button>
      </form>
    </div>
  );
}