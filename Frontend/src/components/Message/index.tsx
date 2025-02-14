"use client";

import type { Message } from "ai";
import { Weather } from "../Weather";
import { Crypto } from '../Cryptoprice';
import { Cryptosend } from '../Sendcrypto';

export default function Message({ message }: { message: Message }) {
  return (
    <div
      className={`relative isolation-auto flex gap-4 p-4 rounded-lg shadow-sm ${
        message.role === "assistant"
          ? "bg-blue-50 text-gray-800" // Assistant message style
          : "bg-white text-gray-800 border border-gray-200" // User message style
      }`}
    >
      {/* Role Indicator */}
      <div
        className={`flex items-center justify-center w-8 h-8 rounded-full text-sm font-medium ${
          message.role === "user"
            ? "bg-blue-600 text-white" // User role indicator
            : "bg-blue-100 text-blue-600" // Assistant role indicator
        }`}
      >
        {message.role === "user" ? "U" : "A"}
      </div>

      {/* Message Content */}
      <div className="flex-1">
        <div className="text-sm">{message.content}</div>

        {/* Tool Invocations */}
        {message.toolInvocations?.map((tool) => {
          const { toolName, toolCallId, state } = tool;

          if (state === "result") {
            if (toolName === "getWeather") {
              return (
                <Weather
                  key={toolCallId}
                  toolCallId={toolCallId}
                  {...tool.result}
                />
              );
            } else if (toolName === 'cryptoToolPrice') {
              return <Crypto key={toolCallId} {...tool.result} />;
            } else if (toolName === 'Sendcrypto') {
              return <Cryptosend key={toolCallId} {...tool.result} />;
            }
          } else {
            if (toolName === "getWeather") {
              return (
                <div key={toolCallId} className="text-sm text-gray-500">
                  Loading weather data...
                </div>
              );
            } else if (toolName === 'Sendcrypto') {
              return (
                <div className="text-sm text-gray-500">
                  Transaction processing...
                </div>
              );
            } else {
              return (
                <div className="text-sm text-gray-500">
                  Loading coin price...
                </div>
              );
            }
          }
          return null;
        })}
      </div>
    </div>
  );
}