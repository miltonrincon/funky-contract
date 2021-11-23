const {ethers} = require("hardhat");
const colors = require("colors/safe");

async function main() {
	
	const [deployer] = await ethers.getSigners();
	
	// Grab the Contract factory
	const contractName = "FunkyContract"
	const contractFactory = await ethers.getContractFactory(contractName)
	
	console.log("Account balance:", (await deployer.getBalance()).toString()); // Wei
	
	// Start deployment, returning a promise that resolves a contract object
	const contract = await contractFactory.deploy(); // instance of the contract
	
	console.log("Contract deployed to the address: ")
	console.log(colors.green(contract.address))
	
}

main()
	.then(() => process.exit(0))
	.catch(error => {
		console.error(error);
		process.exit(0);
	})
