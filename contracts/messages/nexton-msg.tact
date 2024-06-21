struct UserDeposit {
    queryId: Int;
    amount: Int;
}

struct BurnNFT {
    queryId: Int;
    nftId: Int;
}

struct UserReturnRequest {
    queryId: Int;
    amount: Int;
}

struct CalculateReward {
    queryId: Int;
    nftId: Int;
}

struct ReturnReward {
    queryId: Int;
    amount: Int;
}

struct DepositOtherAsset {
    queryId: Int;
    assetType: String;
    amount: Int;
}
