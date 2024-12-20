/* eslint no-console: 0 */
import hre from 'hardhat'
import { loadSecret } from '@valora/secrets-loader'
import '@nomicfoundation/hardhat-ethers'
import '@openzeppelin/hardhat-upgrades'
import yargs from 'yargs'

async function getConfig() {
  //
  // Load secrets from Secrets Manager and inject into process.env.
  //
  const secretNames = process.env.SECRET_NAMES?.split(',') ?? []
  for (const secretName of secretNames) {
    Object.assign(process.env, await loadSecret(secretName))
  }

  const argv = await yargs.env('').option('deploy-salt', {
    description: 'Salt to use for CREATE2 deployments',
    type: 'string',
    demandOption: true,
  }).argv

  return {
    deploySalt: argv['deploy-salt'],
  }
}

const CONTRACT_NAME = 'WalletJumpstartHack'

async function main() {
  const Contract = await hre.ethers.getContractFactory(CONTRACT_NAME)


    // eslint-disable-next-line @typescript-eslint/no-explicit-any
    const constructorArgs: any[] = []
    console.log(`Deploying ${CONTRACT_NAME} with local signer`)
    const result = await Contract.deploy(...constructorArgs)
    const address = await result.getAddress()
    console.log(`Deployed ${CONTRACT_NAME} to ${address}`)
  }

// We recommend this pattern to be able to use async/await everywhere
// and properly handle errors.
main().catch((error) => {
  console.error(error)
  process.exitCode = 1
})
