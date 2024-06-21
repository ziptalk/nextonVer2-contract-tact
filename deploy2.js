const TonWeb = require('tonweb');
const { mnemonicToSeed } = require('tonweb-mnemonic');
require('dotenv').config();

const provider = new TonWeb.HttpProvider("https://testnet.toncenter.com/api/v2/jsonRPC");
const tonweb = new TonWeb(provider);

const deployContract = async (wallet, contractCode, contractData) => {
    const seqno = await wallet.methods.seqno().call();
    const toAddress = await wallet.getAddress();

    const transfer = await wallet.createTransfer({
        secretKey: wallet.options.secretKey,
        seqno: seqno,
        sendMode: 3,
        order: contractData,
        to: toAddress,
        value: TonWeb.utils.toNano('0.1')
    });

    await wallet.methods.transfer(transfer).send();
    console.log("Contract deployed at address:", toAddress.toString(true, true, true));
};

(async () => {
    const seed = await mnemonicToSeed(process.env.TONWALLET_MNEMONIC.split(' '));
    const keyPair = TonWeb.utils.nacl.sign.keyPair.fromSeed(seed);

    const walletContractCode = TonWeb.boc.Cell.oneFromBoc('B5EE9C724101010100710000DEFF0020DD2082014C97BA218201339CBAB19F71B0ED44D0D31FD31F31D70BFFE304E0A4F2608308D71820D31FD31FD31FF82313BBF263ED44D0D31FD31FD3FFD15132BAF2A15144BAF2A204F901541055F910F2A3F8009320D74A96D307D402FB00E8D101A4C8CB1FCB1FCBFFC9ED5410BD6DAD');

    const wallet = new tonweb.wallet.all.v3R2({
        publicKey: keyPair.publicKey,
        secretKey: keyPair.secretKey,
        wc: -1,
        code: walletContractCode
    });

    const contractsData = [
        {
            code: "base64_compiled_code_for_address_manager",
            data: {
                address: process.env.TONWALLET_ADDRESS,
                uintValue: 1
            }
        },
        {
            code: "base64_compiled_code_for_arb_bot_integration",
            data: {
                address: process.env.TONWALLET_ADDRESS,
                uintValue: 2
            }
        },
        {
            code: "base64_compiled_code_for_lrt_lending",
            data: {
                address: process.env.TONWALLET_ADDRESS,
                uintValue: 3
            }
        },
        {
            code: "base64_compiled_code_for_nft_management",
            data: {
                address: process.env.TONWALLET_ADDRESS,
                uintValue: 4
            }
        },
        {
            code: "base64_compiled_code_for_ton_handler",
            data: {
                address: process.env.TONWALLET_ADDRESS,
                uintValue: 5
            }
        }
    ];

    for (const contract of contractsData) {
        const cell = new TonWeb.boc.Cell();
        cell.bits.writeAddress(new TonWeb.utils.Address(contract.data.address));
        cell.bits.writeUint(contract.data.uintValue, 32);

        await deployContract(wallet, contract.code, cell);
    }
})();

// const TonWeb = require('tonweb');
// const { mnemonicToSeed } = require('tonweb-mnemonic');
// require('dotenv').config();

// const provider = new TonWeb.HttpProvider("https://testnet.toncenter.com/api/v2/jsonRPC");
// const tonweb = new TonWeb(provider);

// const deployContract = async (wallet, contractCode, contractData) => {
//     const seqno = await wallet.methods.seqno().call();
//     const toAddress = await wallet.getAddress();
    
//     const transfer = await tonweb.wallet.createTransfer({
//         secretKey: wallet.keyPair.secretKey,
//         seqno: seqno,
//         sendMode: 3,
//         order: contractData,
//         to: toAddress,
//         value: TonWeb.utils.toNano('0.1')
//     });

//     await wallet.methods.transfer(transfer).send();
//     console.log("Contract deployed at address:", toAddress.toString(true, true, true));
// };

// (async () => {
//     const seed = await mnemonicToSeed(process.env.TONWALLET_MNEMONIC.split(' '));
//     const keyPair = TonWeb.utils.nacl.sign.keyPair.fromSeed(seed);
//     const wallet = new tonweb.wallet.all.v3R2(provider, {
//         publicKey: keyPair.publicKey,
//         secretKey: keyPair.secretKey,
//         wc: -1,
//     });

//     const contractsData = [
//         {
//             code: "base64_compiled_code_for_address_manager",
//             data: {
//                 address: process.env.TONWALLET_ADDRESS,
//                 uintValue: 1
//             }
//         },
//         {
//             code: "base64_compiled_code_for_arb_bot_integration",
//             data: {
//                 address: process.env.TONWALLET_ADDRESS,
//                 uintValue: 2
//             }
//         },
//         {
//             code: "base64_compiled_code_for_lrt_lending",
//             data: {
//                 address: process.env.TONWALLET_ADDRESS,
//                 uintValue: 3
//             }
//         },
//         {
//             code: "base64_compiled_code_for_nft_management",
//             data: {
//                 address: process.env.TONWALLET_ADDRESS,
//                 uintValue: 4
//             }
//         },
//         {
//             code: "base64_compiled_code_for_ton_handler",
//             data: {
//                 address: process.env.TONWALLET_ADDRESS,
//                 uintValue: 5
//             }
//         }
//     ];

//     for (const contract of contractsData) {
//         const cell = new TonWeb.boc.Cell();
//         cell.bits.writeAddress(new TonWeb.utils.Address(contract.data.address));
//         cell.bits.writeUint(contract.data.uintValue, 32);

//         await deployContract(wallet, contract.code, cell);
//     }
// })();


// // const TonWeb = require('tonweb');
// // const { mnemonicToSeed } = require('tonweb-mnemonic');
// // require('dotenv').config();

// // const provider = new TonWeb.HttpProvider("https://testnet.toncenter.com/api/v2/jsonRPC");
// // const tonweb = new TonWeb(provider);

// // const deployContract = async (wallet, contractCode, contractData) => {
// //     const seqno = await wallet.methods.seqno().call();
// //     const toAddress = await wallet.getAddress();
    
// //     const transfer = await wallet.createTransfer({
// //         secretKey: wallet.keyPair.secretKey,
// //         seqno: seqno,
// //         sendMode: 3,
// //         order: new TonWeb.boc.Cell().withData(contractCode).withData(contractData),
// //         to: toAddress,
// //         value: TonWeb.utils.toNano('0.1')
// //     });

// //     await wallet.methods.transfer(transfer).send();
// //     console.log("Contract deployed at address:", toAddress);
// // };

// // (async () => {
// //     const seed = await mnemonicToSeed([process.env.TONWALLET_MNEMONIC]);  
// //     const keyPair = TonWeb.utils.nacl.sign.keyPair.fromSeed(seed);
// //     const wallet = new TonWeb.Wallets.all.v3R2(provider, {
// //         publicKey: keyPair.publicKey,
// //         secretKey: keyPair.secretKey,
// //         wc: -1,
// //     });

// //     const contractsData = [
// //         {
// //             code: "base64_compiled_code_for_address_manager",
// //             data: {
// //                 address: process.env.TONWALLET_ADDRESS,
// //                 uintValue: 1
// //             }
// //         },
// //         {
// //             code: "base64_compiled_code_for_arb_bot_integration",
// //             data: {
// //                 address: process.env.TONWALLET_ADDRESS,
// //                 uintValue: 2
// //             }
// //         },
// //         {
// //             code: "base64_compiled_code_for_lrt_lending",
// //             data: {
// //                 address: process.env.TONWALLET_ADDRESS,
// //                 uintValue: 3
// //             }
// //         },
// //         {
// //             code: "base64_compiled_code_for_nft_management",
// //             data: {
// //                 address: process.env.TONWALLET_ADDRESS,
// //                 uintValue: 4
// //             }
// //         },
// //         {
// //             code: "base64_compiled_code_for_ton_handler",
// //             data: {
// //                 address: process.env.TONWALLET_ADDRESS,
// //                 uintValue: 5
// //             }
// //         }
// //     ];

// //     for (const contract of contractsData) {
// //         const cell = new TonWeb.boc.Cell(); // 셀 객체를 각 계약마다 새로 생성합니다.
// //         cell.bits.writeAddress(new TonWeb.utils.Address(contract.data.address));
// //         cell.bits.writeUint(contract.data.uintValue, 32);

// //         await deployContract(wallet, contract.code, cell);
// //     }
// // })();

// // //     const cell = new TonWeb.boc.Cell(); // 셀 객체를 생성합니다.
// // // cell.bits.writeAddress(new TonWeb.utils.Address(process.env.TONWALLET_ADDRESS)); // bits 속성을 사용하여 주소를 작성합니다.
// // // cell.bits.writeUint(1, 32); // bits 속성을 사용하여 정수를 작성합니다.


// // //     const contractsData = [
// // //         {
// // //             code: "base64_compiled_code_for_address_manager",
// // //             data: cell
// // //         },
// // //         {
// // //             code: "base64_compiled_code_for_arb_bot_integration",
// // //             data: cell // 여기서 cell을 다시 사용하는 게 맞는지 확인해야 합니다. 다른 데이터를 사용해야 할 수도 있습니다.
// // //         },
// // //         {
// // //             code: "base64_compiled_code_for_lrt_lending",
// // //             data: cell
// // //         },
// // //         {
// // //             code: "base64_compiled_code_for_nft_management",
// // //             data: cell
// // //         },
// // //         {
// // //             code: "base64_compiled_code_for_ton_handler",
// // //             data: cell
// // //         }
// // //     ];
    

// // //     for (const contract of contractsData) {
// // //         await deployContract(wallet, contract.code, contract.data);
// // //     }
// // // })();


// // // const TonWeb = require('tonweb');
// // // const { mnemonicToSeed } = require('tonweb-mnemonic');
// // // require('dotenv').config();

// // // const deployContracts = async () => {
// // //     const provider = new TonWeb.HttpProvider("https://testnet.toncenter.com/api/v2/jsonRPC");
// // //     const tonweb = new TonWeb(provider);

// // //     // First of all, create seed from mnemonic.
// // //     const seed = await mnemonicToSeed([process.env.TONWALLET_MNEMONIC]);  
// // //     // Create key pair from our seed.
// // //     const keyPair = TonWeb.utils.nacl.sign.keyPair.fromSeed(seed);
// // //     // Create wallet.
// // //     const wallet = new TonWeb.Wallets.all.v3R2(provider, {
// // //         publicKey: keyPair.publicKey,
// // //         wc: -1
// // //     });

// // //     const deployContract = async (contractCode, contractData) => {
// // //         const seqno = await wallet.methods.seqno().call();
// // //         const toAddress = await wallet.getAddress();
        
// // //         const transfer = await wallet.createTransfer({
// // //             seqno: seqno,
// // //             sendMode: 3,
// // //             order: new TonWeb.boc.Cell().withData(contractCode).withData(contractData),
// // //             to: toAddress,
// // //             value: TonWeb.utils.toNano('0.1')
// // //         });

// // //         await wallet.methods.transfer(transfer).send();
// // //         console.log("Contract deployed at address:", toAddress);
// // //     };

// // //     const contracts = [
// // //         {
// // //             code: "base64_compiled_code_for_address_manager",
// // //             data: (new TonWeb.boc.Cell())
// // //             .writeAddress(new TonWeb.utils.Address(process.env.TONWALLET_ADDRESS))
// // //             .writeUint(1, 32)
// // //                 },
// // //         {
// // //             code: "base64_compiled_code_for_arb_bot_integration",
// // //             data: (new TonWeb.boc.Cell())
// // //             .writeAddress(new TonWeb.utils.Address(process.env.TONWALLET_ADDRESS))
// // //             .writeUint(2, 32) },
// // //         {
// // //             code: "base64_compiled_code_for_lrt_lending",
// // //             data: (new TonWeb.boc.Cell())
// // //             .writeAddress(new TonWeb.utils.Address(process.env.TONWALLET_ADDRESS))
// // //             .writeUint(3, 32) },
// // //         {
// // //             code: "base64_compiled_code_for_nft_management",
// // //             data: (new TonWeb.boc.Cell())
// // //             .writeAddress(new TonWeb.utils.Address(process.env.TONWALLET_ADDRESS))
// // //             .writeUint(4, 32) },
// // //         {
// // //             code: "base64_compiled_code_for_ton_handler",
// // //             data: (new TonWeb.boc.Cell())
// // //             .writeAddress(new TonWeb.utils.Address(process.env.TONWALLET_ADDRESS))
// // //             .writeUint(5, 32) }
// // //     ];

// // //     for (const contract of contracts) {
// // //         await deployContract(contract.code, contract.data);
// // //     }
// // // };

// // // deployContracts();


// // // // const TonWeb = require('tonweb');
// // // // const {mnemonicToSeed} = require('tonweb-mnemonic');
// // // // // import TonWeb, {HttpProvider} from 'tonweb';
// // // // // import {mnemonicToSeed} from 'tonweb-mnemonic';
// // // // require('dotenv').config();

// // // // const provider = new TonWeb.HttpProvider("https://testnet.toncenter.com/api/v2/jsonRPC");
// // // // const tonweb = new TonWeb(provider);


// // // //     // First of all, create seed from mnemonic. Mnemonic is a
// // // //     // combination of 24 words. For example, you could already
// // // //     // create your wallet in TON Keeper application, where these 24
// // // //     // words were used. You can use them here too, to get access
// // // //     // to your wallet.
// // // //     const seed = await mnemonicToSeed([process.env.TONWALLET_MNEMONIC]);  
// // // //     // Create key pair from our seed.
// // // //     const keyPair = TonWeb.utils.nacl.sign.keyPair.fromSeed(seed);
  
// // // //     // Create wallet.
// // // //     const wallet = new TonWeb.Wallets.all.v3R2(provider, {
// // // //         publicKey: keyPair.publicKey,
// // // //         wc: -1
// // // //     });
  

// // // // // const WalletClass = tonweb.wallet.all.v3R2;
// // // // // const wallet = new WalletClass(tonweb.provider, {
// // // // //     address: process.env.TONWALLET_ADDRESS,
// // // // //     seed: process.env.TONWALLET_SEEDS.split(" ")
// // // // // });

// // // // // // 시드를 사용하여 키 쌍 생성
// // // // // const seedPhrase = process.env.TONWALLET_SEEDS;
// // // // // const keyPair = tonweb.utils.KeyPair.fromSeedPhrase(seedPhrase);

// // // // // // 생성된 키 쌍을 사용하여 톤 월렛 초기화
// // // // // const wallet = new TonWeb.wallet.all.v3R2(tonweb.provider, { keyPair });

// // // // //  // Create key pair from our seed.
// // // // //  const seed = process.env.TONWALLET_SEEDS;
// // // // //  const keyPair = TonWeb.utils.nacl.sign.keyPair.fromSeed(seed);

// // // // //  // Create wallet.
// // // // //  const wallet = new TonWeb.Wallets.all.v3R2(provider, {
// // // // //      publicKey: keyPair.publicKey,
// // // // //      wc: -1
// // // // //  });

// // // // const deployContract = async (contractCode, contractData) => {
// // // //     const seqno = await wallet.methods.seqno().call();
// // // //     const toAddress = await wallet.getAddress();
    
// // // //     const transfer = await wallet.createTransfer({
// // // //         secretKey: wallet.keyPair.secretKey,
// // // //         seqno: seqno,
// // // //         sendMode: 3,
// // // //         order: new TonWeb.boc.Cell().withData(contractCode).withData(contractData),
// // // //         to: toAddress,
// // // //         value: TonWeb.utils.toNano('0.1')
// // // //     });

// // // //     await wallet.methods.transfer(transfer).send();
// // // //     console.log("Contract deployed at address:", toAddress);
// // // // };

// // // // const deployContracts = async () => {
    
// // // //     const addressManagerCode = "base64_compiled_code_for_address_manager";
// // // //     const addressManagerData = new TonWeb.boc.Cell();
// // // //     addressManagerData.bits.writeAddress(new TonWeb.utils.Address(process.env.TONWALLET_ADDRESS));
// // // //     addressManagerData.bits.writeUint(1, 32); // 예제 ID

// // // //     const arbBotIntegrationCode = "base64_compiled_code_for_arb_bot_integration";
// // // //     const arbBotIntegrationData = new TonWeb.boc.Cell();
// // // //     arbBotIntegrationData.bits.writeAddress(new TonWeb.utils.Address(process.env.TONWALLET_ADDRESS));
// // // //     arbBotIntegrationData.bits.writeUint(2, 32); // 예제 ID

// // // //     const lrtLendingCode = "base64_compiled_code_for_lrt_lending";
// // // //     const lrtLendingData = new TonWeb.boc.Cell();
// // // //     lrtLendingData.bits.writeAddress(new TonWeb.utils.Address(process.env.TONWALLET_ADDRESS));
// // // //     lrtLendingData.bits.writeUint(3, 32); // 예제 ID

// // // //     const nftManagementCode = "base64_compiled_code_for_nft_management";
// // // //     const nftManagementData = new TonWeb.boc.Cell();
// // // //     nftManagementData.bits.writeAddress(new TonWeb.utils.Address(process.env.TONWALLET_ADDRESS));
// // // //     nftManagementData.bits.writeUint(4, 32); // 예제 ID

// // // //     const tonHandlerCode = "base64_compiled_code_for_ton_handler";
// // // //     const tonHandlerData = new TonWeb.boc.Cell();
// // // //     tonHandlerData.bits.writeAddress(new TonWeb.utils.Address(process.env.TONWALLET_ADDRESS));
// // // //     tonHandlerData.bits.writeUint(5, 32); // 예제 ID

// // // //     const contracts = [
// // // //         {code: addressManagerCode, data: addressManagerData},
// // // //         {code: arbBotIntegrationCode, data: arbBotIntegrationData},
// // // //         {code: lrtLendingCode, data: lrtLendingData},
// // // //         {code: nftManagementCode, data: nftManagementData},
// // // //         {code: tonHandlerCode, data: tonHandlerData},
// // // //     ];

// // // //     for (const contract of contracts) {
// // // //         await deployContract(contract.code, contract.data);
// // // //     }
// // // // })();
