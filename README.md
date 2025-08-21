🚀 FundMe Smart Contract Project

I built a crowdfunding-style smart contract in Solidity where anyone can send ETH to fund the project, but with some key features:



🔹 Key Features

Minimum Funding Requirement → Contributors must send a minimum amount of ETH, calculated using Chainlink price feeds to keep the value consistent in USD (e.g., $50).

Data Tracking → Every funder’s contribution is stored in a mapping + array, so the contract keeps track of who funded and how much.

Withdrawal Function → Only the owner (deployer) of the contract can withdraw all the funds safely.

Price Conversion Library → A helper PriceConverter library was written to fetch ETH/USD prices and convert ETH values.

Mock Testing Setup → Since real price feeds aren’t available locally, a MockV3Aggregator was deployed for testing.



🔹 Testing & Deployment (using Foundry)

DeployFundMe.s.sol → Script to deploy the contract.

HelperConfig.s.sol → Chooses between real Chainlink price feeds (on live/testnets) and mock contracts (on local testing).

Comprehensive unit tests ensured the funding logic, withdrawal security, and data updates worked as expected.



🔹 Tech Stack

Solidity

Foundry (Forge for testing, Cast for interaction, Anvil for local blockchain)

Chainlink Price Feeds

Mock contracts for simulation.

