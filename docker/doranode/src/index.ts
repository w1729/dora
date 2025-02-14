import "dotenv/config";
import { ethers } from "ethers";
import HTTPServer from "moleculer-web";
import { ServiceBroker } from "moleculer";
import { zkVerifySession, ZkVerifyEvents, Library, CurveType } from "zkverifyjs";


// const signer = new ethers.Wallet(process.env.LOGIN_SERVICE_PK);
const broker = new ServiceBroker();
const ZKV_RPC_URL=process.env.ZKV_RPC_URL;
const ZKV_SEED_PHARASE=process.env.ZKV_SEED_PHRASE;
const ETH_SECRET_KEY=process.env.ETH_SECRET_KEY;

broker.createService({
  name: "gateway",
  mixins: [HTTPServer],

  settings: {
    port: process.env.DORANODE_PORT ?? 4340,
    routes: [
      {
        aliases: {
          "POST /verify": "verify.test", 
        },
        cors: {
          origin: "*",
        },
        bodyParsers: {
          json: true,
          urlencoded: { extended: true },
        },
      },
    ],
  },
});

enum ProofTypes {
  NONE,
  ULTRA_PLONK,
}

// Define the verification service
broker.createService({
  name: "verify",
  actions: {
    async test(ctx) {
      const { vkey, proof, pubsignal } = ctx.params;

      const session = await zkVerifySession.start()
        .Custom(ZKV_RPC_URL)
        .withAccount(ZKV_SEED_PHARASE);

        const { events, transactionResult } = await session.verify()
        .ultraplonk()
        .waitForPublishedAttestation()
        .execute({
            proofData: {
                vk: vkey,
    proof: proof,
    publicSignals: pubsignal
            }
        });


      return transactionResult;
    },
  },
});

broker.start();
