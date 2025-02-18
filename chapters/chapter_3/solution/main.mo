import Result "mo:base/Result";
import Principal "mo:base/Principal";
import HashMap "mo:base/HashMap";
import Option "mo:base/Option";
import Types "types";

actor {

    type Result<Ok, Err> = Types.Result<Ok, Err>;
    type HashMap<K, V> = Types.HashMap<K, V>;

    let ledger = HashMap.HashMap<Principal, Nat>(0, Principal.equal, Principal.hash);
    let name : Text = "CoinCoin";
    let symbol : Text = "CoC";

    public query func tokenName() : async Text {
        return name;
    };

    public query func tokenSymbol() : async Text {
        return symbol;
    };

    public func mint(owner : Principal, amount : Nat) : async Result<(), Text> {
       let balanceOwner = Option.get(ledger.get(owner), 0);
       ledger.put(owner, balanceOwner + amount);
       return #ok(());
    };

    public func burn(owner : Principal, amount : Nat) : async Result<(), Text> {
        let balanceOwner = Option.get(ledger.get(owner), 0);
        if (amount > balanceOwner) {
            return #err("Insufficient balance");
        };
        ledger.put(owner, balanceOwner - amount);
        return #ok(());
    };

    public shared ({ caller }) func transfer(from : Principal, to : Principal, amount : Nat) : async Result<(), Text> {
        let balanceFrom = Option.get(ledger.get(from), 0);
        let balanceTo = Option.get(ledger.get(to), 0);
        if (amount > balanceFrom) {
            return #err("Insufficient balance");
        };
        ledger.put(from, balanceFrom - amount);
        ledger.put(to, balanceTo + amount);
        return #ok(());
    };

    public query func balanceOf(account : Principal) : async Nat {
        return (Option.get(ledger.get(account), 0));
    };

    public query func totalSupply() : async Nat {
        var total : Nat = 0;
        for (balance in ledger.vals()) {
            total := total + balance;
        };
        return total;
    };

};