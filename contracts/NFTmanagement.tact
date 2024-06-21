import "@stdlib/deploy";
import "@stdlib/ownable";
import "@stdlib/stoppable";
import "./messages/nftManagement-msg.tact";
import "./imports/stdlib.fc";

const MIN_CONTRACT_BALANCE: Int = ton("0.2");

contract NFTManagement with Deployable, OwnableTransferable, Resumable {
    const MinTonForStorage: Int = ton("0.2");
    owner: Address;
    stopped: Bool = false;

    struct NFTValue {
        nftId: Int;
        valueTon: Int;
        valueJetton: Int;
        valueStTon: Int;
    }

    init() {
        self.owner = sender();
    }

    receive() {} // Receive TONCoins

    receive(msg: EvaluateNFT) {
        self.requireNotStopped();
        nativeReserve(MIN_CONTRACT_BALANCE, 0);

        let nftValue = self.evaluateNFTValue(msg.nftId);

        send(SendParameters{
            to: msg.sender,
            value: ton("0.01"),
            mode: SendPayGasSeparately | SendIgnoreErrors,
            body: nftValue.toCell()
        });
    }

    receive(msg: calculateLendingAmount) {
        self.requireNotStopped();
        nativeReserve(MIN_CONTRACT_BALANCE, 0);

        let nftValue = self.evaluateNFTValue(msg.nftId);
        let lendingAmount = self.calculateLoanAmount(nftValue);

        send(SendParameters{
            to: msg.sender,
            value: lendingAmount,
            mode: SendPayGasSeparately | SendIgnoreErrors,
            body: beginCell().storeUint(0, 32).endCell()
        });
    }

    fun evaluateNFTValue(nftId: Int): NFTValue {
        let valueTon = ton("10");
        let valueJetton = ton("5");
        let valueStTon = ton("8");
        return NFTValue{
            nftId: nftId,
            valueTon: valueTon,
            valueJetton: valueJetton,
            valueStTon: valueStTon
        };
    }

    fun calculateLoanAmount(nftValue: NFTValue): Int {
        let totalValue = nftValue.valueTon + nftValue.valueJetton + nftValue.valueStTon;
        return totalValue / 2;
    }

    fun requireNotStopped() {
        require(!self.stopped, "Contract is stopped");
    }

    fun requireOwner() {
        require(self.owner == sender(), "Sender is not the owner");
    }
}
