import "@stdlib/deploy";
import "@stdlib/ownable";
import "@stdlib/stoppable";
import "./messages/arbBotIntegration-msg.tact";
import "./imports/stdlib.fc";
import "./AddressManager.tact";

const MIN_CONTRACT_BALANCE: Int = ton("0.2");

contract ArbBotIntegration with Deployable, OwnableTransferable, Resumable {
    const MinTonForStorage: Int = ton("0.2");
    owner: Address;
    stopped: Bool = false;
    addressManager: Address;
    externalWallet: Address;

    init(addressManager: Address, externalWallet: Address) {
        self.owner = sender();
        self.addressManager = addressManager;
        self.externalWallet = externalWallet;
    }

    receive() {} // Receive TONCoins
    
    receive(msg: TransferUSDT) {
        self.requireNotStopped();
        nativeReserve(MIN_CONTRACT_BALANCE, 0);
        send(SendParameters{
            to: self.externalWallet,
            value: msg.amount,
            mode: SendPayGasSeparately | SendIgnoreErrors,
            body: beginCell().storeUint(0, 32).endCell()
        });
    }
    
    receive(msg: SignalExternalWallet) {
        self.requireNotStopped();
        nativeReserve(MIN_CONTRACT_BALANCE, 0);
        send(SendParameters{
            to: self.externalWallet,
            value: ton("0.01"),
            mode: SendPayGasSeparately | SendIgnoreErrors,
            body: msg.toCell()
        });
    }
    
    receive(msg: UpdateYieldRate) {
        self.requireOwner();
        nativeReserve(MIN_CONTRACT_BALANCE, 0);
        // Logic to update yield rate
        send(SendParameters{
            to: msg.sender,
            value: ton("0.01"),
            mode: SendPayGasSeparately | SendIgnoreErrors,
            body: beginCell().storeUint(0, 32).endCell()
        });
    }

    fun requireNotStopped() {
        require(!self.stopped, "Contract is stopped");
    }

    fun requireOwner() {
        require(self.owner == sender(), "Sender is not the owner");
    }
}
