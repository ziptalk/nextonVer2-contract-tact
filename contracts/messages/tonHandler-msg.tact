struct TransferTON {
    queryId: Int;
    amount: Int;
}

struct ReceiveJetton {
    queryId: Int;
    amount: Int;
}

struct ReceiveStTON {
    queryId: Int;
    amount: Int;
}

struct ReturnCollateral {
    queryId: Int;
    userAddress: Address;
    amount: Int;
}

struct ReturnAsset {
    queryId: Int;
    userAddress: Address;
    amount: Int;
}

struct SendAdditionalRewards {
    queryId: Int;
    userAddress: Address;
    amount: Int;
}

struct HandleNewAsset {
    queryId: Int;
    assetType: String;
    amount: Int;
}

struct SetDelegation {
    queryId: Int;
    user: Address;
    delegate: Address;
    weight: Int;
    reason: String;
}
