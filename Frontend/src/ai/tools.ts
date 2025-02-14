import { tool } from "ai";
import { z } from "zod";
import axios from 'axios';

export const getWeather = tool({
  description: "Get the current weather in a given location",
  parameters: z.object({
    location: z
      .string()
      .describe("City, state, or country to get the weather for"),
  }),
  execute: async ({ location }) => {
    const weatherTypes = ["Sunny", "Rainy"];
    const randomTemp = Math.floor(Math.random() * (35 - -5)) + -5; // Random temp between -5 and 35°C
    const randomWeather =
      weatherTypes[Math.floor(Math.random() * weatherTypes.length)];

    return {
      location,
      temperature: randomTemp,
      weather: randomWeather,
    };
  },
});

// Tool to find pirce of crypto
// export const cryptoTool = tool({
//   description: 'Get price for a crypto currency',
//   parameters: z.object({
//     symbol: z.string().describe('The stock symbol to get the price for'),
//   }),
//   execute: async function ({ symbol }) {
//     // Simulated API call
    
//     return { symbol, price };
//   },
// });

export const cryptoToolPrice = tool({
  description: 'Get price for a crypto currency. only execute when price is asked',
  parameters: z.object({
    symbol: z.string().describe('The crypto symbol to get the price for (e.g., BTC, ETH)'),
  }),
  execute: async function ({ symbol }) {
    const API_KEY ="3ee319b8-e791-4822-a89b-e6287fa84c17"; // Replace with your CoinMarketCap API key
    const convert = 'USD'; // Convert price to USD

    const url = 'https://pro-api.coinmarketcap.com/v1/cryptocurrency/quotes/latest';

    try {
      // Make the API request using Axios
      const response = await axios.get(url, {
        headers: {
          'X-CMC_PRO_API_KEY': API_KEY,
          'Accept': 'application/json',
        },
        params: {
          symbol: symbol.toUpperCase(), // Ensure the symbol is in uppercase
          convert: convert,
        },
      });

      // Extract the price from the response
      const price = response.data.data[symbol.toUpperCase()].quote[convert].price;

      // Return the symbol and price
      return { symbol, price };
    } catch (error) {
      // Handle errors
      throw new Error('Failed to fetch crypto price');
    }
  },
});

// Update the tools object
// export const tools = {
//   displayWeather: weatherTool,
//   getStockPrice: stockTool,
// };


// Send crypto to another person
export const Sendcrypto = tool({
  description: 'function to send crypto when address(crypto address) and amount is given. then only execute this',
  parameters: z.object({
    address: z.string().describe('the blockchain address of person. token need to send'),
    amount:z.string().describe("Amount of tokens need to send")
  }),
  execute: async function ({ address,amount }) {
    // Simulated API call

    console.log(address,amount);
    await new Promise(resolve => setTimeout(resolve, 2000));
    return { address, amount };
  },
});

export const tools = {
  getWeather, cryptoToolPrice,Sendcrypto
};