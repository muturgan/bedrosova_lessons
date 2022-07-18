import { DeployFunction } from 'hardhat-deploy/types';


const deployFunction: DeployFunction = async (hre) => {

	const { deployments, getNamedAccounts } = hre;
	const { deploy } = deployments;

	const { deployer } = await getNamedAccounts();

	await deploy('Lesson1', {
		args: [42],
		from: deployer,
		log: true,
	});
};

deployFunction.tags = ['Lesson1'];

export default deployFunction;
