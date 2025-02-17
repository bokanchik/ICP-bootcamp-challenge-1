actor MotivationLetter {
    let name : Text = "Alexandra Bokancha";
    var message : Text = "I want to build my first dApp with Motoko";

    public func setMessage(newMessage : Text) : async () {
        message := newMessage;
        return;
    };

    public query func getMessage() : async Text { 
        return message;
    };

    public query func getName() : async Text { 
        return name;
    };

}