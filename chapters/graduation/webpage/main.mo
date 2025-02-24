import Types "types";
import Result "mo:base/Result";
import Text "mo:base/Text";
import Principal "mo:base/Principal";

actor Webpage {

    type Result<A, B> = Result.Result<A, B>;
    type HttpRequest = Types.HttpRequest;
    type HttpResponse = Types.HttpResponse;

    // The manifesto stored in the webpage canister should always be the same as the one stored in the DAO canister
    stable var manifesto : Text = "Let's graduate!";

    let daoCanisterId : Principal = Principal.fromText("mytki-xqaaa-aaaab-qabrq-cai");
    
    // The webpage displays the manifesto
    public query func http_request(request : HttpRequest) : async HttpResponse {
        return ({
            status_code = 200;
            headers = [];
            body = Text.encodeUtf8(manifesto);
            streaming_strategy = null;
        });
    };

    // This function should only be callable by the DAO canister (no one else should be able to change the manifesto)
    public shared ({ caller }) func setManifesto(newManifesto : Text) : async Result<(), Text> {
        if (caller != daoCanisterId){
            return #err("This funciton should only be callable by the DAO canister.");
        };
        manifesto := newManifesto;
        return #ok(());
    };
};
