import { ethers, upgrades } from 'hardhat';
import { Lesson2UpgradebleV2__factory as V2F } from '../typechain-types';

const PROXY = '0x368697D33745824db509A3eD91A6a55b71f201D0';

(async () => {

	const Lesson2UpgradebleV2 = await ethers.getContractFactory<V2F>('Lesson2UpgradebleV2');
	console.info('Upgrading Lesson2UpgradebleV2...');
	await upgrades.upgradeProxy(PROXY, Lesson2UpgradebleV2);
	console.info('Lesson2UpgradebleV2 upgraded!');

})();
