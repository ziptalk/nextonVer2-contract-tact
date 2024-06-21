import "@stdlib/deploy";
import "@stdlib/ownable";
import "@stdlib/stoppable";
import "./messages/lrtlending-msg.tact";
import "./imports/stdlib.fc";
import "./AddressManager.tact";

const MIN_CONTRACT_BALANCE: Int = ton("0.2");

contract Lrtlending with Deployable, OwnableTransferable, Resumable {
    const MinTonForStorage: Int = ton("0.2");
    owner: Address;
    stopped: Bool = false;
    addressManager: Address;
    nftManagement: Address;
    nxtToken: Address;
    nftStorage: map<Int, Address>;
    loanAmounts: map<Address, Int>;

    init(addressManager: Address, nftManagement: Address, nxtToken: Address) {
        self.owner = sender();
        self.addressManager = addressManager;
        self.nftManagement = nftManagement;
        self.nxtToken = nxtToken;
    }

    receive() {} // Receive TONCoins

    receive(msg: DepositNFT) {
        self.requireNotStopped();
        nativeReserve(MIN_CONTRACT_BALANCE, 0);

        let nftOwner = sender();
        let loanAmount = self.calculateLoanAmount(msg.nftId);

        self.nftStorage.set(msg.nftId, nftOwner);
        self.loanAmounts.set(nftOwner, loanAmount);

        send(SendParameters{
            to: nftOwner,
            value: loanAmount,
            mode: SendPayGasSeparately | SendIgnoreErrors,
            body: beginCell().storeUint(0, 32).endCell()
        });
    }

        receive(msg: ReturnNXT) {
        self.requireNotStopped();
        nativeReserve(MIN_CONTRACT_BALANCE, 0);

        let nftOwner = sender();
        let loanAmount = self.loanAmounts.get(nftOwner).get();
        require(msg.amount >= loanAmount, "Insufficient amount to return loan");

        self.loanAmounts.remove(nftOwner);
        let nftId = self.getNftIdByOwner(nftOwner);

        send(SendParameters{
            to: nftOwner,
            value: nftId,
            mode: SendPayGasSeparately | SendIgnoreErrors,
            body: beginCell().storeUint(0, 32).endCell()
        });
    }

    fun calculateLoanAmount(nftId: Int): Int {
        let loanAmount: Int;
        let evaluation: EvaluateNFT = EvaluateNFT{
            nftId: nftId
        };
        let response = sendQuery(self.nftManagement, evaluation);
        loanAmount = response.amount;
        return loanAmount;
    }

    fun getNftIdByOwner(owner: Address): Int {
        for ((nftId, nftOwner) in self.nftStorage) {
            if (nftOwner == owner) {
                return nftId;
            }
        }
        nativeThrow(910, "NFT not found for owner");
    }

    fun requireNotStopped() {
        require(!self.stopped, "Contract is stopped");
    }

    fun requireOwner() {
        require(self.owner == sender(), "Sender is not the owner");
    }
}

