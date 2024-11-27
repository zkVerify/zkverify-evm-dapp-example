const fs = require("fs");
const { zkVerifySession } = require("zkverifyjs");
require('dotenv').config({ path: ['.env', '.env.secrets'] })

async function run() {
    // Load verification key from file
    const vk = JSON.parse(fs.readFileSync("../circuit/setup/verification_key.json"));

    // Establish a session with zkVerify
    const session = await zkVerifySession.start()
        .Custom(process.env.ZKV_RPC_URL)
        .withAccount(process.env.ZKV_SEED_PHRASE);

    // Send verification key to zkVerify for registration
    const { transactionResult } = await session.registerVerificationKey()
        .groth16()
        .execute(vk);
    const { statementHash } = await transactionResult;
    console.log(`vk hash: ${statementHash}`)
}

run()
    .then(() => {
        process.exit(0);
    })
    .catch(err => {
        console.error(err);
        process.exit(1);
    });