import Array "mo:base/Array";
import Nat "mo:base/Nat";
import Iter "mo:base/Iter";

actor TraderInvestorPlatform {

    type Trader = {
        id: Nat;
        name: Text;
    };

    type Investor = {
        id: Nat;
        name: Text;
    };

    type ContractStatus = {
        #Active;
        #Terminated;
    };

    type TerminationReason = {
        #Profit;
        #Loss;
    };

    type Contract = {
        id: Nat;
        trader: Nat;
        investor: Nat;
        var status: ContractStatus;
        var currentProfit: Nat;
        var currentLoss: Nat;
        profitSplitTrader: Nat;
        profitSplitInvestor: Nat;
        lossLimit: Nat;
        var terminationReason: ?TerminationReason;
    };

    type SerializableContract = {
        id: Nat;
        trader: Nat;
        investor: Nat;
        status: ContractStatus;
        currentProfit: Nat;
        currentLoss: Nat;
        profitSplitTrader: Nat;
        profitSplitInvestor: Nat;
        lossLimit: Nat;
        terminationReason: ?TerminationReason;
    };

    var contracts: [Contract] = [];
    var traders: [Trader] = [];
    var investors: [Investor] = [];
    var nextContractId: Nat = 1;
    var nextTraderId: Nat = 1;
    var nextInvestorId: Nat = 1;
    var terminatedContractsProfit: [Contract] = [];
    var terminatedContractsLoss: [Contract] = [];

    // Function to create a new contract
    public func createContract(traderId: Nat, investorId: Nat, profitSplitTrader: Nat, profitSplitInvestor: Nat, lossLimit: Nat): async Text {
        if (not traderExists(traderId)) {
            return "Trader not found";
        };
        if (not investorExists(investorId)) {
            return "Investor not found";
        };
        if (activeContractExists(traderId, investorId)) {
            return "An active contract already exists between this trader and investor";
        };

        let contractId = nextContractId;
        nextContractId += 1;

        let newContract: Contract = {
            id = contractId;
            trader = traderId;
            investor = investorId;
            var status = #Active;
            var currentProfit = 0;
            var currentLoss = 0;
            profitSplitTrader = profitSplitTrader;
            profitSplitInvestor = profitSplitInvestor;
            lossLimit = lossLimit;
            var terminationReason = null;
        };

        // Use Array.append to add new contract to contracts array
        contracts := Array.append<Contract>(contracts, [newContract]);

        return "Contract created with id: " # Nat.toText(contractId);
    };

    // Helper function to check if a trader exists
    private func traderExists(traderId: Nat): Bool {
        Array.find<Trader>(traders, func (trader: Trader): Bool {
            trader.id == traderId
        }) != null
    };

    // Helper function to check if an investor exists
    private func investorExists(investorId: Nat): Bool {
        Array.find<Investor>(investors, func (investor: Investor): Bool {
            investor.id == investorId
        }) != null
    };

    // Helper function to check if an active contract exists between a trader and an investor
    private func activeContractExists(traderId: Nat, investorId: Nat): Bool {
        switch (Array.find<Contract>(contracts, func (contract: Contract): Bool {
            contract.trader == traderId and contract.investor == investorId and contract.status == #Active
        })) {
            case (null) { false };
            case (_) { true };
        }
    };

    // Function to convert internal Contract to SerializableContract
    private func toSerializableContract(contract: Contract): SerializableContract {
        return {
            id = contract.id;
            trader = contract.trader;
            investor = contract.investor;
            status = contract.status;
            currentProfit = contract.currentProfit;
            currentLoss = contract.currentLoss;
            profitSplitTrader = contract.profitSplitTrader;
            profitSplitInvestor = contract.profitSplitInvestor;
            lossLimit = contract.lossLimit;
            terminationReason = contract.terminationReason;
        };
    };

    // Function to retrieve all contracts
    public func getContracts(): async [SerializableContract] {
        return Array.map<Contract, SerializableContract>(contracts, toSerializableContract);
    };

    // Function to add a new trader
    public func addTrader(name: Text): async Nat {
        let traderId = nextTraderId;
        nextTraderId += 1;

        let newTrader: Trader = {
            id = traderId;
            name = name;
        };

        // Use Array.append to add new trader to traders array
        traders := Array.append<Trader>(traders, [newTrader]);

        return traderId;
    };

    // Function to add a new investor
    public func addInvestor(name: Text): async Nat {
        let investorId = nextInvestorId;
        nextInvestorId += 1;

        let newInvestor: Investor = {
            id = investorId;
            name = name;
        };

        // Use Array.append to add new investor to investors array
        investors := Array.append<Investor>(investors, [newInvestor]);

        return investorId;
    };

    // Function to retrieve all traders
    public func getTraders(): async [Trader] {
        return traders;
    };

    // Function to retrieve all investors
    public func getInvestors(): async [Investor] {
        return investors;
    };

    // Function to update the contract with profit or loss
    public func updateContract(contractId: Nat, profit: Nat, loss: Nat): async Text {
        let contractOpt = Array.find<Contract>(contracts, func (contract: Contract): Bool {
            contract.id == contractId
        });

        switch (contractOpt) {
            case (null) {
                return "Contract not found";
            };
            case (?contract) {
                if (contract.status == #Terminated) {
                    return "Contract is already terminated";
                };

                // Clear previous values
                contract.currentProfit := 0;
                contract.currentLoss := 0;

                // Update with new values
                contract.currentProfit += profit;
                contract.currentLoss += loss;

                if (contract.currentLoss >= contract.lossLimit) {
                    contract.status := #Terminated;
                    contract.terminationReason := ?#Loss;
                    terminatedContractsLoss := Array.append<Contract>(terminatedContractsLoss, [contract]);
                    return "Contract terminated due to loss limit and recorded";
                };

                return "Contract updated";
            };
        }
    };

    // Function to terminate a contract by its ID
    public func terminateContract(contractId: Nat): async Text {
        let contractOpt = Array.find<Contract>(contracts, func (contract: Contract): Bool {
            contract.id == contractId
        });

        switch (contractOpt) {
            case (null) {
                return "Contract not found";
            };
            case (?contract) {
                if (contract.status == #Terminated) {
                    return "Contract is already terminated";
                };

                contract.status := #Terminated;
                if (contract.currentProfit > contract.currentLoss) {
                    contract.terminationReason := ?#Profit;
                    terminatedContractsProfit := Array.append<Contract>(terminatedContractsProfit, [contract]);
                } else {
                    contract.terminationReason := ?#Loss;
                    terminatedContractsLoss := Array.append<Contract>(terminatedContractsLoss, [contract]);
                };

                return "Contract terminated and recorded";
            };
        }
    };

    // Function to get terminated contracts
    public func getTerminatedContracts(): async {
        profit: [SerializableContract];
        loss: [SerializableContract];
    } {
        let profitContracts = Array.map<Contract, SerializableContract>(terminatedContractsProfit, toSerializableContract);
        let lossContracts = Array.map<Contract, SerializableContract>(terminatedContractsLoss, toSerializableContract);
        return {
            profit = profitContracts;
            loss = lossContracts;
        };
    };
};
