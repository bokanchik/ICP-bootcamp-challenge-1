import Result "mo:base/Result";
import Text "mo:base/Text";
import Principal "mo:base/Principal";
import Nat "mo:base/Nat";
import HashMap "mo:base/HashMap";
import Option "mo:base/Option";
import Debug "mo:base/Debug";
import Types "types";
import tokenCanister "canister:graduation_token";

actor {

        type Result<A, B> = Result.Result<A, B>;
        type Member = Types.Member;
        type ProposalContent = Types.ProposalContent;
        type ProposalId = Types.ProposalId;
        type Proposal = Types.Proposal;
        type Vote = Types.Vote;
        type HttpRequest = Types.HttpRequest;
        type HttpResponse = Types.HttpResponse;

        // The principal of the Webpage canister associated with this DAO canister (needs to be updated with the ID of your Webpage canister)
        stable let canisterIdWebpage : Principal = Principal.fromText("avqkn-guaaa-aaaaa-qaaea-cai");
        stable var manifesto = "In a world where data is power, TheMachine stands for transparency, security, and decentralization.";
        stable let name = "TheMachine";
        stable var goals = [];

        // Returns the name of the DAO
        public query func getName() : async Text {
                return name;
        };

        // Returns the manifesto of the DAO
        public query func getManifesto() : async Text {
                return manifesto;
        };

        // Returns the goals of the DAO
        public query func getGoals() : async [Text] {
                return goals;
        };

        let members = HashMap.HashMap<Principal, Member>(0, Principal.equal, Principal.hash);
        stable let mentorName : Text = "motoko_bootcamp";
		stable let mentorPrincipal : Principal = Principal.fromText("nkqop-siaaa-aaaaj-qa3qq-cai");

		// TODO : look at function types.
		// Helpful function to create an initial mentor
		public query func createMentor() : async Result<(), Text> {
			let mentor : Member = { name = mentorName; role = #Mentor };
			members.put(mentorPrincipal, mentor);
			return #ok(());
		};
        // Register a new member in the DAO with the given name and principal of the caller
        // Airdrop 10 MBC tokens to the new member
        // New members are always Student
        // Returns an error if the member already exists
        public shared ({ caller }) func registerMember(member : Member) : async Result<(), Text> {
            switch (members.get(caller)) {
                case (?_) {
					return #err("You're already a member");
				};
				case (null) {
					let newMember : Member = { name = member.name; role = #Student };
					members.put(caller, newMember);
					let mintResult = await tokenCanister.mint(caller, 10);
					return #ok(());
				};
            };
        };

        // Get the member with the given principal
        // Returns an error if the member does not exist
        public query func getMember(p : Principal) : async Result<Member, Text> {
            switch (members.get(p)) {
				case (null) {
					return #err("Member not found");
				};
				case (? member) {
					return #ok(member);
				};
			};
        };

        // Graduate the student with the given principal
        // Returns an error if the student does not exist or is not a student
        // Returns an error if the caller is not a mentor
        public shared ({ caller }) func graduate(student : Principal) : async Result<(), Text> {
                
				// check if caller is a mentor
				switch (members.get(caller)) {
					case (null) {
						return #err("The caller is not a member.");
					};
					case (? mentor){
						if (mentor.role != #Mentor){
							return #err("The caller is not a Mentor.");
						};
					};
				};
				
				// graduate student if it's valid
				switch (members.get(student)){
					case (? validStudent) {
						if (validStudent.role == #Student) {
                			members.put(student, { name = validStudent.name; role = #Graduate });
							return #ok(());
						}
						else {
							return #err("The student is not valid for graduation.");
						};
					};
					case (null) {
						return #err("The student doesn't exists");
					};
				}
        };

        // Create a new proposal and returns its id
        // Returns an error if the caller is not a mentor or doesn't own at least 1 MBC token
        public shared ({ caller }) func createProposal(content : ProposalContent) : async Result<ProposalId, Text> {
                return #err("Not implemented");
        };

        // Get the proposal with the given id
        // Returns an error if the proposal does not exist
        public query func getProposal(id : ProposalId) : async Result<Proposal, Text> {
                return #err("Not implemented");
        };

        // Returns all the proposals
        public query func getAllProposal() : async [Proposal] {
                return [];
        };

        // Vote for the given proposal
        // Returns an error if the proposal does not exist or the member is not allowed to vote
        public shared ({ caller }) func voteProposal(proposalId : ProposalId, yesOrNo : Bool) : async Result<(), Text> {
                return #err("Not implemented");
        };

        // Returns the Principal ID of the Webpage canister associated with this DAO canister
        public query func getIdWebpage() : async Principal {
                return canisterIdWebpage;
        };


};
