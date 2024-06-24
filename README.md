# Trader-investor-platform
live canister url - https://a4gq6-oaaaa-aaaab-qaa4q-cai.raw.icp0.io/?id=ivulw-siaaa-aaaap-qhnia-cai

# candid ui instructions
1. Add Investor
Function: addInvestor: (text) → (nat)
•	Input: Investor's name (Text) 
•	Output: Investor's ID (Nat)
2. Add Trader
Function: addTrader: (text) → (nat)
•	Input: Trader's name (Text)
•	Output: Trader's ID (Nat)
3. Create Contract
Function: createContract: (nat, nat, nat, nat, nat) → (text)
•	Input: Trader ID (Nat), Investor ID (Nat), Trader's Profit Split(percentage e.g 40) (Nat), Investor's Profit Split(eg 60), Loss Limit also in percentage eg 10
•	Output: Confirmation Message (Text)
Example:
•	Input: 1, 1, 40, 60, 10
•	Output: "Contract created with id: 1"
4. Get Contracts
Function: getContracts()
•	Input: None
•	Output: List of Contracts (Vector of Records)
5. Get Investors
Function: getInvestors: () → (vec record {id:nat; name:text})
•	Input: None
•	Output: List of Investors (Vector of Records)
6. Get Terminated Contracts
Function: getTerminatedContracts: () → (record {loss:vec record {id:nat; status:variant {Terminated; Active}; profitSplitTrader:nat; trader:nat; terminationReason:opt variant {Loss; Profit}; lossLimit:nat; currentLoss:nat; currentProfit:nat; profitSplitInvestor:nat; investor:nat}; profit:vec record {id:nat; status:variant {Terminated; Active}; profitSplitTrader:nat; trader:nat; terminationReason:opt variant {Loss; Profit}; lossLimit:nat; currentLoss:nat; currentProfit:nat; profitSplitInvestor:nat; investor:nat}})
•	Input: None
•	Output: Record containing two lists: Loss Contracts and Profit Contracts (Vector of Records)
7. Get Traders
Function: getTraders: () → (vec record {id:nat; name:text})
•	Input: None
•	Output: List of Traders (Vector of Records)
8. Terminate Contract
Function: terminateContract: (nat) → (text)
•	Input: Contract ID (Nat)
•	Output: Confirmation Message (Text)
Example:
•	Input: 1
•	Output: "Contract terminated and recorded"
9. Update Contract
Function: updateContract: (nat, nat, nat) → (text)
•	Input: Contract ID (Nat), New Profit (Nat), New Loss (Nat)
•	Output: Confirmation Message (Text)

