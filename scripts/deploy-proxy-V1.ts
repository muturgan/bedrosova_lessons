import { ethers, upgrades } from 'hardhat';
import { Lesson2UpgradebleV1__factory as V1F } from '../typechain-types';

(async () => {

const Lesson2UpgradebleV1 = await ethers.getContractFactory<V1F>('Lesson2UpgradebleV1');
console.info('Deploying Lesson2UpgradebleV1...');
const lesson2ver1 = await upgrades.deployProxy(Lesson2UpgradebleV1, [100500], {
	initializer: 'initialize',
});
await lesson2ver1.deployed();
console.info('Lesson2UpgradebleV1 deployed to:', lesson2ver1.address);

})();
