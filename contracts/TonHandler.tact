import "@stdlib/deploy";
import "@stdlib/ownable";
import "@stdlib/stoppable";
import "./messages/tonHandler-msg.tact";
import "./imports/stdlib.fc";

const MIN_CONTRACT_BALANCE: Int = ton("0.2");

contract TonHandler with Deployable, OwnableTransferable, Resumable {
    const MinTonForStorage: Int = ton("0.2");
    owner: Address;
    stopped: Bool = false;
    addressManager: Address;

    init(addressManager: Address) {
        self.owner = sender();
        self.addressManager = addressManager;
    }

    receive() {} // Receive TONCoins

    receive(msg: TransferTON) {
        self.requireNotStopped();
        nativeReserve(MIN_CONTRACT_BALANCE, 0);
        let bemoAddress = self.addressManager.getAddress("Bemo");
        send(SendParameters{
            to: bemoAddress,
            value: msg.amount,
            mode: SendPayGasSeparately | SendIgnoreErrors,
            body: beginCell().storeUint(0, 32).endCell()
        });
    }

    receive(msg: ReceiveJetton) {
        self.requireNotStopped();
        nativeReserve(MIN_CONTRACT_BALANCE, 0);
        let evaaAddress = self.addressManager.getAddress("Evaa");
        send(SendParameters{
            to: evaaAddress,
            value: msg.amount,
            mode: SendPayGasSeparately | SendIgnoreErrors,
            body: beginCell().storeUint(0, 32).endCell()
        });
    }

    receive(msg: ReceiveStTON) {
        self.requireNotStopped();
        nativeReserve(MIN_CONTRACT_BALANCE, 0);
        let evaaAddress = self.addressManager.getAddress("Evaa");
        send(SendParameters{
            to: evaaAddress,
            value: msg.amount,
            mode: SendPayGasSeparately | SendIgnoreErrors,
            body: beginCell().storeUint(0, 32).endCell()
        });
    }

    receive(msg: ReturnCollateral) {
        self.requireNotStopped();
        nativeReserve(MIN_CONTRACT_BALANCE, 0);
        let userAddress = msg.userAddress;
        send(SendParameters{
            to: userAddress,
            value: msg.amount,
            mode: SendPayGasSeparately | SendIgnoreErrors,
            body: beginCell().storeUint(0, 32).endCell()
        });
    }

    receive(msg: ReturnAsset) {
        self.requireNotStopped();
        nativeReserve(MIN_CONTRACT_BALANCE, 0);
        let userAddress = msg.userAddress;
        send(SendParameters{
            to: userAddress,
            value: msg.amount,
            mode: SendPayGasSeparately | SendIgnoreErrors,
            body: beginCell().storeUint(0, 32).endCell()
        });
    }

    receive(msg: SendAdditionalRewards) {
        self.requireNotStopped();
        nativeReserve(MIN_CONTRACT_BALANCE, 0);
        let userAddress = msg.userAddress;
        send(SendParameters{
            to: userAddress,
            value: msg.amount,
            mode: SendPayGasSeparately | SendIgnoreErrors,
            body: beginCell().storeUint(0, 32).endCell()
        });
    }

    receive(msg: HandleNewAsset) {
        self.requireNotStopped();
        nativeReserve(MIN_CONTRACT_BALANCE, 0);
        let assetHandlerAddress = self.addressManager.getAddress(msg.assetType);
        send(SendParameters{
            to: assetHandlerAddress,
            value: msg.amount,
            mode: SendPayGasSeparately | SendIgnoreErrors,
            body: beginCell().storeUint(0, 32).endCell()
        });
    }

    // Helper functions
    fun requireNotStopped() {
        require(!self.stopped, "Contract is stopped");
    }

    fun requireOwner() {
        require(self.owner == sender(), "Sender is not the owner");
    }

    receive(msg: SetDelegation) {
        require(sender() == self.owner, "Only owner can call this function.");
        self.user = msg.user;
        self.delegate = msg.delegate;
        self.weight = msg.weight;
        self.reason = msg.reason;
    }

    get fun state(): DelegationState {
        return DelegationState {
            user: self.user,
            delegate: self.delegate,
            weight: self.weight,
            reason: self.reason
        };
    }
}
