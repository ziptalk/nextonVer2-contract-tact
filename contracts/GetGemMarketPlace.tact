import "@stdlib/deploy";
import "@stdlib/ownable";
import "@stdlib/stoppable";
import "./messages/getGemMarketPlace-msg.tact";
import "./imports/stdlib.fc";
import "./AddressManager.tact";

const MIN_CONTRACT_BALANCE: Int = ton("0.2");

contract GetGemMarketPlace with Deployable, OwnableTransferable, Resumable {
    const MinTonForStorage: Int = ton("0.2");
    owner: Address;
    stopped: Bool = false;
    addressManager: Address;

    init(addressManager: Address) {
        self.owner = sender();
        self.addressManager = addressManager;
    }

    receive() {} // Receive TONCoins

    receive(msg: ListNFTForSale) {
        self.requireNotStopped();
        nativeReserve(MIN_CONTRACT_BALANCE, 0);

        let nftMarketplaceAddress = AddressManager(self.addressManager).getAddress("nftMarketplace");
        send(SendParameters{
            to: nftMarketplaceAddress,
            value: ton("0.01"),
            mode: SendPayGasSeparately | SendIgnoreErrors,
            body: beginCell().storeUint(0x1, 32).storeUint(msg.nftId, 256).storeCoins(msg.price).endCell()
        });
    }

    receive(msg: BuyNFT) {
        self.requireNotStopped();
        nativeReserve(MIN_CONTRACT_BALANCE, 0);

        let nftMarketplaceAddress = AddressManager(self.addressManager).getAddress("nftMarketplace");
        send(SendParameters{
            to: nftMarketplaceAddress,
            value: ton("0.01"),
            mode: SendPayGasSeparately | SendIgnoreErrors,
            body: beginCell().storeUint(0x2, 32).storeUint(msg.nftId, 256).endCell()
        });
    }

    fun requireNotStopped() {
        require(!self.stopped, "Contract is stopped");
    }

    fun requireOwner() {
        require(self.owner == sender(), "Sender is not the owner");
    }
}
