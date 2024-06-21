



require('dotenv').config();
const fs = require('fs');
const { prepareTactDeployment } = require('@tact-lang/deployer');
const path = require('path');

async function deployContract(contractName) {
    try {
        // 컨트랙트 이름을 첫 글자 대문자로 변환
        const capitalizedContractName = contractName.charAt(0).toUpperCase() + contractName.slice(1);
        const projectDir = 'C:\\Users\\alex1\\my-ton-project\\build';
        const pkgPath = path.join(projectDir, contractName, `${contractName}_${capitalizedContractName}.pkg`);
        const dataPath = path.join(projectDir, contractName, `${contractName}_${capitalizedContractName}.code.boc`);

        const pkg = fs.readFileSync(pkgPath);
        const data = fs.readFileSync(dataPath);

        const deploymentUrl = await prepareTactDeployment({ pkg, data, testnet: true });
        console.log(`Deployment URL for ${contractName}: ${deploymentUrl}`);

        // 실제 배포 URL에서 컨트랙트 주소를 가져오는 로직 필요
        const contractAddress = await getContractAddressFromDeploymentUrl(deploymentUrl);
        return contractAddress;
    } catch (err) {
        console.error(`Failed to deploy contract ${contractName}:`, err);
        return null;
    }
}

// 실제 배포 URL에서 컨트랙트 주소를 가져오는 함수 구현
async function getContractAddressFromDeploymentUrl(url) {
    try {
        // 여기에 배포 URL로부터 컨트랙트 주소를 가져오는 실제 로직을 구현하세요
        // 예시로, HTTP 요청을 보내어 컨트랙트 주소를 가져오는 코드일 수 있습니다
        // 아래는 예시 코드입니다 (실제 서비스에 맞게 수정 필요)

        // const response = await fetch(url);
        // const data = await response.json();
        // return data.contractAddress;

        // 여전히 시뮬레이션으로 더미 주소 반환
        await new Promise(resolve => setTimeout(resolve, 1000));
        return '0:' + 'f'.repeat(64); // 예시 더미 주소
    } catch (err) {
        console.error(`Failed to retrieve contract address from URL ${url}:`, err);
        return null;
    }
}

async function main() {
    const contractNames = [
        'addressManager',
        'arbBotIntegration',
        'lrtLending',
        'nftManagement',
        'tonHandler'
    ];

    const contractAddresses = {};

    for (const name of contractNames) {
        const address = await deployContract(name);
        if (address) {
            contractAddresses[name] = address;
        }
    }

    console.log('Contract Addresses:', contractAddresses);

    // 필요시 주소를 파일에 저장
    fs.writeFileSync('./contractAddresses.json', JSON.stringify(contractAddresses, null, 2));
}

main();


// require('dotenv').config();
// const fs = require('fs');
// const { prepareTactDeployment } = require('@tact-lang/deployer');

// async function deployContract(contractName) {
//     try {
//         const pkg = fs.readFileSync(`./build/${contractName}/${contractName}.pkg`);
//         const data = fs.readFileSync(`./build/${contractName}/${contractName}.boc`);

//         const deploymentUrl = await prepareTactDeployment({ pkg, data, testnet: true });
//         console.log(`Deployment URL for ${contractName}: ${deploymentUrl}`);

//         // Assuming deployment URL returns the contract address after deployment
//         // You would typically visit the URL to confirm the deployment
//         // and get the contract address manually or through a callback service
//         // Here we simulate the contract address retrieval
//         const contractAddress = await getContractAddressFromDeploymentUrl(deploymentUrl);
//         return contractAddress;
//     } catch (err) {
//         console.error(`Failed to deploy contract ${contractName}:`, err);
//         return null;
//     }
// }

// // Mock function to simulate getting contract address from deployment URL
// // Replace this with actual logic to retrieve contract address
// async function getContractAddressFromDeploymentUrl(url) {
//     // Simulate delay and return a dummy address
//     await new Promise(resolve => setTimeout(resolve, 1000));
//     return '0:' + 'f'.repeat(64); // Example dummy address
// }

// async function main() {
//     const contractNames = [
//         'addressManager',
//         'arbBotIntegration',
//         'lrtLending',
//         'nftManagement',
//         'tonHandler'
//     ];

//     const contractAddresses = {};

//     for (const name of contractNames) {
//         const address = await deployContract(name);
//         if (address) {
//             contractAddresses[name] = address;
//         }
//     }

//     console.log('Contract Addresses:', contractAddresses);

//     // Optionally save addresses to a file for future use
//     fs.writeFileSync('./contractAddresses.json', JSON.stringify(contractAddresses, null, 2));
// }

// main();
