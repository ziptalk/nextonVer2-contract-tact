import "@stdlib/deploy";
import "@stdlib/ownable";
import "@stdlib/stoppable";
import "./messages/addressManager-msg.tact";
import "./imports/stdlib.fc";

const MIN_CONTRACT_BALANCE: Int = ton("0.2");

contract AddressManager with Deployable, OwnableTransferable, Resumable {
    const MinTonForStorage: Int = ton("0.2");
    owner: Address;
    stopped: Bool = false;
    addresses: map<String, Address>;

    init() {
        self.owner = sender();
    }

    receive() {} // Receive TONCoins

    receive(msg: setAddress) {
        self.requireOwner();
        nativeReserve(MIN_CONTRACT_BALANCE, 0);
        self.addresses.set(msg.addressType, msg.newAddress);
    }

    receive(msg: getAddress) {
        nativeReserve(MIN_CONTRACT_BALANCE, 0);
        let addr = self.addresses.get(msg.addressType).get();
        send(SendParameters{
            to: msg.sender,
            value: ton("0.01"),
            mode: SendPayGasSeparately | SendIgnoreErrors,
            body: beginCell().storeAddress(addr).endCell()
        });
    }

    fun getAddress(addressType: String): Address {
        return self.addresses.get(addressType).get();
    }

    fun requireOwner() {
        require(self.owner == sender(), "Sender is not the owner");
    }
}
