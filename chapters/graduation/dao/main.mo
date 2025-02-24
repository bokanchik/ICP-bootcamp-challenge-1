import Result "mo:base/Result";
import Text "mo:base/Text";
import Principal "mo:base/Principal";
import Nat "mo:base/Nat";
import HashMap "mo:base/HashMap";
import Option "mo:base/Option";
import Debug "mo:base/Debug";
import Nat64 "mo:base/Nat64";
import Time "mo:base/Time";
import Iter "mo:base/Iter";
import Array "mo:base/Array";
import Buffer "mo:base/Buffer";
import Hash "mo:base/Hash";
import Nat32 "mo:base/Nat32";
import Types "types";

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
        stable let canisterIdWebpage : Principal = Principal.fromText("c2lt4-zmaaa-aaaaa-qaaiq-cai");
		stable let mentorPrincipal = Principal.fromText("nkqop-siaaa-aaaaj-qa3qq-cai");
        stable var manifesto = "Your manifesto";
        stable let name = "Your DAO";
        stable var goals : [Text] = [];

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

		// create a mentor

		public shared func addInitialMentor() : async Result<(), Text> {
			switch (members.get(mentorPrincipal)) {
				case (null) {
					let initialMentor = {
						name = "motoko_bootcamp";
						role = #Mentor;
					};
					members.put(mentorPrincipal, initialMentor);
					let mintResult = await faucet.mint(mentorPrincipal, 10);
					return #ok(());
				};
				case (?_) {
					return #err("Initial mentor already exists");
				};
			}
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
					let mintResult = await faucet.mint(caller, 10);
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
						if (validStudent.role != #Student) {
							return #err("The student is not valid for graduation.");
						};
                		members.put(student, { name = validStudent.name; role = #Graduate });
						return #ok(());
					};
					case (null) {
						return #err("The student doesn't exist");
					};
				}
        };

		func customHashNat(x: Nat): Hash.Hash {
			var hash: Nat32 = 0;
			var value = x;
			while (value != 0) {
				let byte = Nat32.fromNat(value % 256);
				hash := hash + byte;
				hash := hash + (hash << 10);
				hash := hash ^ (hash >> 6);
				value := value / 256;
			};
			hash := hash + (hash << 3);
			hash := hash ^ (hash >> 11);
			hash := hash + (hash << 15);
			return hash;
    	};

		stable var nextProposalId : ProposalId = 0;
		let proposals = HashMap.HashMap<ProposalId, Proposal>(0, Nat.equal, customHashNat);
		
		let faucet = actor("jaamb-mqaaa-aaaaj-qa3ka-cai") : actor {
			mint: shared (to: Principal, amount: Nat) -> async Result<(), Text>;
			burn: shared (from: Principal, amount: Nat) -> async Result<(), Text>;
			balanceOf: shared (account: Principal) -> async Nat;
			balanceOfArray: shared (accounts: [Principal]) -> async [Nat];
			tokenName: shared () -> async Text;
			tokenSymbol: shared () -> async Text;
			totalSupply: shared () -> async Nat;
			transfer: shared (from: Principal, to: Principal, amount: Nat) -> async Result<(), Text>;
    	};
        // Create a new proposal and returns its id
        // Returns an error if the caller is not a mentor or doesn't own at least 1 MBC token
        public shared ({ caller }) func createProposal(content : ProposalContent) : async Result<ProposalId, Text> {
            switch (members.get(caller)) {
				case (null) { 
					return #err ("The caller is not a member - cannot create a proposal."); 
				};
				case (? mentor) {
					// check if mentor
					if (mentor.role != #Mentor){
						return #err("The caller is not a Mentor - cannot create a proposal.");
					};
					// check if mentor has at least 1 MBC token
					let mentorBalance = await faucet.balanceOf(caller);
					if (mentorBalance < 1){
						return #err("Insufficient balance - cannot create a proposal.");
					};
					// create the proposal and burn 1 MBC token
					let proposal : Proposal = {
						id = nextProposalId;
						content = content;
						creator = caller;
						created = Time.now();
						executed = null;
						votes = [];
						voteScore = 0;
						status = #Open;
					};
					proposals.put(nextProposalId, proposal);
					nextProposalId += 1;
					let burnResult = await faucet.burn(caller, 1);
					return #ok(nextProposalId - 1);
				};
			};
        };

        // Get the proposal with the given id
        // Returns an error if the proposal does not exist
        public query func getProposal(id : ProposalId) : async Result<Proposal, Text> {
            switch (proposals.get(id)) {
				case (null) {
					return #err("Proposal does not exist");
				};
				case (? proposal){
					return #ok(proposal);
				};
			};
        };

        // Returns all the proposals
        public query func getAllProposal() : async [Proposal] {
                return Iter.toArray(proposals.vals());
        };

        // Vote for the given proposal
        // Returns an error if the proposal does not exist or the member is not allowed to vote
        public shared ({ caller }) func voteProposal(proposalId : ProposalId, yesOrNo : Bool) : async Result<(), Text> {
			switch (members.get(caller)) {
				case (null) {
					return #err("The caller is not a member - cannot vote on proposal.");
				};
				case (? member) {
                	// check if proposal exist
					switch (proposals.get(proposalId)) {
						case (null) {
							return #err("The proposal does not exist");
						};
						case (? proposal){
							// check if the member is Graduate or Mentor
							if (member.role == #Student){
								return #err("The caller has to be Graduate or Mentor to vote on proposal.");
							};
							// Check if the proposal is open for voting
							if (proposal.status != #Open) {
								return #err("The proposal is not open for voting");
							};
							// Check if the caller has already voted
							if (_hasVoted(proposal, caller)) {
								return #err("The caller has already voted on this proposal");
							};
							var balance = await faucet.balanceOf(caller);
							if (balance < 1) {
								return #err("Insufficient balance - cannot vote on a proposal.")
							};
							// voting power == MBC token x 5
							if (member.role == #Mentor) {
								balance := balance * 5;
							};
							let multiplierVote = switch (yesOrNo) {
								case (true) { 1 };
								case (false) { -1 };
							};
							let newVoteScore = proposal.voteScore + balance * multiplierVote;
							let newVote: Vote = {
								member = caller;
								votingPower = balance;
								yesOrNo = yesOrNo;
							};
							
							var newExecuted : ?Time.Time = null;
							let newVotes = Buffer.fromArray<Vote>(proposal.votes);
							newVotes.add(newVote);
							let newStatus = if (newVoteScore >= 100){
								#Accepted;
							} else if (newVoteScore <= -100) {
								#Rejected;
							} else {
								#Open;
							};
							switch (newStatus) {
								case (#Accepted) {
									_executeProposal(proposal.content);
									newExecuted := ?Time.now();
								};
								case (_) {};
							};
							// update proposal
							let updateProposal : Proposal = {
								id = proposal.id;
								content = proposal.content;
								creator = proposal.creator;
								created = proposal.created;
								executed = newExecuted;
								votes = Buffer.toArray(newVotes);
								voteScore = newVoteScore;
								status = newStatus;
							};
							proposals.put(proposal.id, updateProposal);
							return #ok(());
						};
					};
				};
			};
        };

		func _hasVoted(proposal : Proposal, member : Principal) : Bool {
			return Array.find<Vote>(
				proposal.votes,
				func(vote : Vote) {
					return vote.member == member;
				},
			) != null;
		};

		func _executeProposal(content : ProposalContent) : () {
        	switch (content) {
            	case (#ChangeManifesto(newManifesto)) {
                	manifesto := newManifesto;
            	};
            	case (#AddGoal(newGoal)) {
					let buffer = Buffer.Buffer<Text>(goals.size() + 1);
                	for (goal in goals.vals()) {
						buffer.add(goal);
					};
					buffer.add(newGoal);
					goals := Buffer.toArray(buffer);
            	};
				case (#AddMentor(studentPrincipal)) {
					switch (members.get(studentPrincipal)) {
						case (null) {};
						case (? student){
							if (student.role == #Graduate) {
								// update to Mentor
								let updateMember : Member = { name = student.name; role = #Mentor };
								members.put(studentPrincipal, updateMember); 
							};
						};
					};
				};
        	};
        	return;
    	};

        // Returns the Principal ID of the Webpage canister associated with this DAO canister
        public query func getIdWebpage() : async Principal {
                return canisterIdWebpage;
        };


};
