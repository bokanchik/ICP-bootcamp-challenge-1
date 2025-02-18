import Result "mo:base/Result";
import HashMap "mo:base/HashMap";
import Principal "mo:base/Principal";
import Iter "mo:base/Iter";
//import Debug "mo:base/Debug";
import Types "types";

actor {

    type Member = Types.Member;
    type Result<Ok, Err> = Types.Result<Ok, Err>;
    type HashMap<K, V> = Types.HashMap<K, V>;

    let members = HashMap.HashMap<Principal, Member>(0, Principal.equal, Principal.hash);

    public shared ({ caller }) func addMember(member : Member) : async Result<(), Text> {
        switch (members.get(caller)) {
            case (?_) { // if key is present returns the value associated with it
                return #err("You are already a member.");
            };
            case (null) { // caller not found in members
                members.put(caller, member);
                return #ok(());
            };
        }
    };

    public query func getMember(principal : Principal) : async Result<Member, Text> {
        switch (members.get(principal)) {
            case (? member) {
                return #ok(member);
            };
            case (null) { 
                return #err("Member not found.");
            };
        };
    };

    public shared ({ caller }) func updateMember(member : Member) : async Result<(), Text> {
         switch (members.get(caller)) {
            case (?_) { // update member
                members.put(caller, member);
                return #ok(());
            };
            case (null) { 
                return #err("Member not found.");
            };
        };
    };

    public query func getAllMembers() : async [Member] {
        let iter = members.vals();
        return Iter.toArray(iter);
    };

    public query func numberOfMembers() : async Nat {
        return members.size();
    };

    public shared ({ caller }) func removeMember() : async Result<(), Text> {
          switch (members.get(caller)) {
            case (?_) {
                members.delete(caller);
                return #ok(());
            };
            case (null) { 
                return #err("Member not found.");
            };
        };
    };
    // FOR TESTING PURPOSE :
    // dfx identity use anonymous -> to use an existing identity
    // dfx identity get-principal -> to get principal ID
    // dfx identity new <name> -> to create a new identity
    // dfx canister --playground call chapter_2 addMember '(record { name = ""; age = Nat; })'

    public shared ({ caller }) func whoami() : async Principal {
        return caller;
    };

};
