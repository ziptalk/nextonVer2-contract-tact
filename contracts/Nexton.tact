import "@stdlib/deploy";
import "@stdlib/ownable";
import "@stdlib/stoppable";
import "./messages/nexton-msg.tact";
import "./imports/stdlib.fc";

const PROTOCOL_FEE: Int = ton("0.1");
const MIN_USER_DEPOSIT: Int = ton("1");
const MIN_CONTRACT_BALANCE: Int = ton("0.2");
const DEFAULT_LOCK_PERIOD: Int = 5184000; // 60 days
const BASE_DEVISOR: Int = 10000;

@name(equal_slices)
native equal_slices(s2: Slice, s1: Slice): Int;

@name(store_dict)
extends native storeDict(self: Builder, c: Cell): Builder;

struct Attribute {
    trait_type: String;
    value: Int;
}

struct DictLoadRes {
    slice: Slice;
    dict: Cell;
}

@name(load_dict)
extends native loadDict(self: Slice): DictLoadRes;

struct DictGetRes {
    cell: Cell;
    success: Int;
}

@name(udict_get_ref?)
extends native udictGetRef(self: Cell, kl: Int, k: Int): DictGetRes;

contract NexTon with Deployable, OwnableTransferable, Resumable {
    const MinTonForStorage: Int = ton("0.2");
    owner: Address;
    stopped: Bool = false;
    nftItemCode: Cell;

    nFTContractAddress: Address;

    usersPrincipal: Int as coins = 0;
    latestStakeBlock: Int as uint256;
    itemCounter: Int as uint64 = 0;
    lockPeriod: Int as uint256 = 0;
    apr: Int = 1000;
    itemContent: map<Int as uint256, Cell>;

    init(nftItemCode: Cell, _nft: Address) {
        self.owner = sender();
        self.nftItemCode = nftItemCode;
        self.nFTContractAddress = _nft;
        self.latestStakeBlock = 0;
        self.lockPeriod = DEFAULT_LOCK_PERIOD;

        self.itemContent.set(sha256("name"), beginCell().storeUint(0, 8).storeSlice("Nexton Staking Derivative".asSlice()).endCell());
        self.itemContent.set(sha256("description"), beginCell().storeUint(0, 8).storeSlice("Holds information about the user's stake in the Nexton platform pool".asSlice()).endCell());
        self.itemContent.set(sha256("image"), beginCell().storeUint(0, 8).storeSlice("https://raw.githubusercontent.com/Nex-TON/Nexton_Contracts/main/NewItem_Image.jpg".asSlice()).endCell());
        self.itemContent.set(sha256("social_links"), beginCell().storeUint(0, 8).storeSlice("['https://twitter.com/NextonNode', 'https://www.nexton.solutions/', 'https://t.me/nextonglobal' ]".asSlice()).endCell());
    }

    receive() {} // Receive TONCoins

        receive(msg: UserDeposit) {
        self.requireNotStopped();
        let ctx: Context = context();
        require(ctx.value >= MIN_USER_DEPOSIT, "Too small deposit amount, min deposit is 1 Ton");

        nativeReserve(MIN_CONTRACT_BALANCE, 0);

        let attributes: Attribute = Attribute{ trait_type: "principal", value: ctx.value - PROTOCOL_FEE };
        self.latestStakeBlock = now();

        self.itemContent.set(sha256("principal"), beginCell().storeUint(0, 8).storeCoins(ctx.value - PROTOCOL_FEE).endCell());
        self.itemContent.set(sha256("lockPeriod"), beginCell().storeUint(0, 8).storeUint(self.lockPeriod, 256).endCell());
        self.itemContent.set(sha256("lockEnd"), beginCell().storeUint(0, 8).storeUint(self.lockPeriod + now(), 256).endCell());

        let itemMessage: Cell =
            beginCell()
            .storeAddress(ctx.sender)
            .storeAddress(myAddress())
            .storeRef(beginCell().storeUint(0,8).storeDict(self.itemContent.asCell()!!).endCell())
            .endCell();
        let messageBody: MintNFT = MintNFT{
            queryId: msg.queryId,
            itemIndex: self.itemCounter,
            amount: 0,
            NFTMessage: itemMessage
        };
        self.mintNFT(messageBody);

        self.usersPrincipal = self.usersPrincipal + ctx.value - PROTOCOL_FEE;
        self.itemContent.set(sha256("principal"), beginCell().storeUint(0, 8).storeCoins(0).endCell());
        self.itemContent.set(sha256("lockEnd"), beginCell().storeUint(0, 8).storeUint(0, 256).endCell());
    }

    bounced(src: bounced<MintNFT>) {
        self.itemCounter = self.itemCounter - 1;
    }

    receive(msg: UserClaim) {
        self.requireNotStopped();
        let itemIndex: Int = msg.payload.itemIndex;
        require(self.itemCounter > itemIndex, "Claiming not existing NFT");
        require(self.NftAddressByIndex(itemIndex) == sender(), "Invalid sender! Sent not from the nft item!");
        nativeReserve(MIN_CONTRACT_BALANCE, 0);

        let owner: Address = msg.payload.owner;

        let contentS: Slice = msg.payload.content.beginParse();
        nativeThrowUnless(905, contentS.loadUint(8) == 0);
        let contDict: DictLoadRes = contentS.loadDict();
        nativeThrowUnless(906, contDict.dict != null);

        let lockEndRes: DictGetRes = contDict.dict.udictGetRef(256, sha256("lockEnd"));
        nativeThrowUnless(907, lockEndRes.success == -1);
        let lockEndS: Slice = lockEndRes.cell.beginParse();
        let prefix: Int = lockEndS.loadUint(8);
        nativeThrowUnless(908, prefix == 0);
        let lockEnd: Int = lockEndS.loadUint(256);
        nativeThrowUnless(909, lockEnd >= now());

        let principalRes: DictGetRes = contDict.dict.udictGetRef(256, sha256("principal"));
        nativeThrowUnless(910, principalRes.success == -1);
        let principalS: Slice = principalRes.cell.beginParse();
        prefix = principalS.loadUint(8);
        nativeThrowUnless(911, prefix == 0);
        let principal: Int = principalS.loadCoins();
        nativeThrowUnless(912, principal > 0);

        let lockPeriodRes: DictGetRes = contDict.dict.udictGetRef(256, sha256("lockPeriod"));
        nativeThrowUnless(913, lockPeriodRes.success == -1);
        let lockPeriodS: Slice = lockPeriodRes.cell.beginParse();
        prefix = lockPeriodS.loadUint(8);
        nativeThrowUnless(914, prefix == 0);
        let lockPeriod: Int = lockPeriodS.loadUint(256);
        nativeThrowUnless(915, lockPeriod > 0);

        let reward: Int = principal * lockPeriod * self.apr / 31536000 / BASE_DEVISOR;

        send(SendParameters{
            to: owner,
            value: reward + principal,
            mode: SendIgnoreErrors | SendRemainingValue,
            body: "Nexton reward".asComment()
        });

        self.usersPrincipal = self.usersPrincipal - principal;
    }

    receive(msg: OwnerWithdraw) {
        self.requireOwner();
        nativeThrowUnless(1000, msg.amount <= myBalance() - MIN_CONTRACT_BALANCE);
        nativeReserve(MIN_CONTRACT_BALANCE, 0);
        send(SendParameters{
            to: sender(),
            value: msg.amount,
            mode: SendIgnoreErrors | SendRemainingValue,
            body: "Assets withdrawn".asComment()
        });
    }

    receive(msg: SetLockPeriod) {
        self.requireOwner();
        self.lockPeriod = msg.lockPeriod;
    }

    receive(msg: SetApr) {
        self.requireOwner();
        self.apr = msg.apr;
    }

    fun mintNFT(body: MintNFT) {
        send(SendParameters{
            to: self.nFTContractAddress,
            value: ton("0.04"),
            mode: SendPayGasSeparately | SendIgnoreErrors,
            body: body.toCell()
        });
        self.itemCounter = self.itemCounter + 1;
    }

    fun getNftItemInit(itemIndex: Int): StateInit {
        let data: Cell = beginCell().storeUint(itemIndex, 64).storeSlice(self.nFTContractAddress.asSlice()).endCell();
        let itemInit: StateInit = StateInit{
            data: data,
            code: self.nftItemCode
        };
        return itemInit;
    }

    get fun NftAddressByIndex(itemIndex: Int): Address {
        return contractAddress(self.getNftItemInit(itemIndex));
    }

    get fun collectionAddress(): Address {
        return self.nFTContractAddress;
    }

    get fun staked(): Int {
        return self.usersPrincipal;
    }

    get fun nftCounter(): Int {
        return self.itemCounter;
    }

    get fun lockPeriod(): Int {
        return self.lockPeriod;
    }

    get fun balance(): Int {
        return myBalance();
    }

    get fun apr(): Int {
        return self.apr;
    }

    fun requireNotStopped() {
        require(!self.stopped, "Contract is stopped");
    }

    fun requireOwner() {
        require(self.owner == sender(), "Sender is not the owner");
    }
}

