## Requirements

1. Membership and Token Allocation
    - New members receive 10 Motoko Bootcamp Tokens (MBT) upon joining.
    - MBTs are used for participating in DAO activities.

2. Role System
The DAO comprises three roles: *Students*, *Graduates*, and *Mentors*.
    - Students: All members start as students. They are members who haven't completed the Motoko Bootcamp.
    - Graduates: These are members who have completed the Motoko Bootcamp. They gain the right to vote on proposals. Any member can become a Graduate through a graduate function, which only a Mentor executes. There's no need to implement a verification process for this.
    - Mentors: Graduates who are selected by the DAO become Mentors. They can both vote on and create proposals. An existing Mentor can assign the Mentor role to any Graduate member by creating a proposal. This proposal has to be approved by the DAO.

3. Proposal Creation
    Only Mentors are authorized to create proposals.
    To create a proposal, a Mentor must burn 1 MBT, which decreases their token balance.

4. Voting System
    Only Graduates and Mentors are allowed to vote.

    The voting power of a member is determined as follows:

    If the member is a Student - the voting power is set to 0 (Student don't have voting power).

    If the member is a Graduate - his voting power is directly equal to the number of MBC token they hold at the moment of voting.

    If the member is a Mentor - his voting power is equal to 5x the number of MBC tokens they hold at the moment of voting.

    The yesOrNo field of the Vote object is a Bool representing whether a vote is meant to approve or refuse a proposal. true represents a vote in favor of a proposal and false represents a vote against a proposal.

    When a member votes on a proposal, his voting power is added or subtracted to the voteScore variable of the Proposal object.

    A proposal is automatically accepted if the voteScore reaches 100 or more. A proposal is automatically rejected if the voteScore reaches -100 or less. A vote stays open as long as it's not approved or rejected.

    Approved proposals are automatically executed.

    For example, if a mentor possessing 15 Motoko Bootcamp Tokens (MBT) casts a vote in favor of a proposal (true), their vote contributes 75 to the voteScore due to the 5x multiplier for mentors' votes. If the voteScore before this vote was 30, it would increase to 105 after the vote is counted. Consequently, the proposal reaches the acceptance threshold and is successfully implemented.

5. Proposal Types 
There are 2 types of proposals:
    - *ChangeManifesto*: those proposals contain a Text that if approved will be the new manifesto of the DAO. If the proposal is approved the changes should be reflected on the DAO canister and the Webpage canister.
    - *AddMentor*: those proposals contain a Principal that if approved will become a mentor of the DAO. Whenever such a proposal is created, we need to verify that the specified principal is a Graduate of the DAO, as only Graduate can become Mentors. If the proposal is approved the changes should be reflected on the DAO canister.

6. Initial Setup 
    The initial setup of the DAO should include an initial mentor to ensure that your DAO is operational:
    Mentor:
    Name: motoko_bootcamp
    Associated Principal: nkqop-siaaa-aaaaj-qa3qq-cai
    You can decide to hardcode the initial setup or create an external one that will be executed upon canister deployment.

7.Token Faucet 
    You are required to use the Motoko Bootcamp Token, a free, educational token faucet. It allows unlimited minting but holds no real economic value; it's solely for educational use.
    Find the token faucet source code in the token folder. Deploy it locally for building and testing. For your live project on the Internet Computer, you are required to use the existing token faucet on the Internet Computer with the canister ID jaamb-mqaaa-aaaaj-qa3ka-cai.

    Access the interface of the deployed token faucet canister here.

    You'll need to use the Faucet canister to:

    Mint tokens when a new member joins your DAO.
    Burn tokens when a new proposal is created.