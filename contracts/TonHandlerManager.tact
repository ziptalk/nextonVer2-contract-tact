import "@stdlib/deploy";
import "@stdlib/ownable";
import "@stdlib/stoppable";
import "./messages/tonHandlerManager-msg.tact";
import "./imports/stdlib.fc";
import "./AddressManager.tact";

const MIN_CONTRACT_BALANCE: Int = ton("0.2");

contract TonHandlerManager with Deployable, OwnableTransferable, Resumable {
    const MinTonForStorage: Int = ton("0.2");
    owner: Address;
    stopped: Bool = false;
    addressManager: Address;
    tonHandlers: map<Int, Address>;
    handlerCounter: Int = 0;

    init(addressManager: Address) {
        self.owner = sender();
        self.addressManager = addressManager;
    }

    receive() {} // Receive TONCoins

    receive(msg: CreateTonHandler) {
        self.requireNotStopped();
        self.requireOwner();
        nativeReserve(MIN_CONTRACT_BALANCE, 0);

        let handlerAddress = self.createTonHandler();
        self.tonHandlers.set(self.handlerCounter, handlerAddress);
        self.handlerCounter = self.handlerCounter + 1;

        send(SendParameters{
            to: msg.sender,
            value: ton("0.05"),
            mode: SendPayGasSeparately | SendIgnoreErrors,
            body: beginCell().storeUint(0, 32).endCell()
        });
    }

    fun createTonHandler(): Address {
        let stateInit: StateInit = StateInit{
            code: TvmCell(), // The code of the TonHandler contract
            data: beginCell().storeAddress(self.addressManager).endCell()
        };
        return deployContract(stateInit, ton("1"));
    }

    fun requireNotStopped() {
        require(!self.stopped, "Contract is stopped");
    }

    fun requireOwner() {
        require(self.owner == sender(), "Sender is not the owner");
    }
}
