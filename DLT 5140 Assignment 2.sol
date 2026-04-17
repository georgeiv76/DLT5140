// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

// This contract allows running ONE crowdfunding campaign at a time
// People can send money, and depending on the result, funds are distributed or refunded

contract SingleCampaignCrowdfunding {

    // This event is emitted when the campaign duration is over
    // It signals that the campaign can now be closed
    event CampaignReadyToClose(uint timestamp); 

    // enum defines all possible states of the campaign
    enum State {
        NoCampaign,                   // no campaign exists yet
        CampaignOpen,                 // campaign is active
        CampaignClosedSuccessful,     // campaign closed and target reached
        CampaignClosedUnsuccessful    // campaign closed and target not reached
    }

    // stores the current state of the campaign
    // public means Solidity creates a function that allows anyone to call and read its value
    State public currentState; 
    

    // Participants

    address payable public platformOwner; 
    // stores the platform owner address
    // public means anyone can call a function to read its value

    address public campaignAdmin; 
    // address of the user who creates the campaign
    // public means anyone can call a function to read its value

    address public campaignCloser; 
    // address of the user who closes the campaign
    // public means anyone can call a function to read its value
 

    mapping(address => uint) public donor; 
    // mapping(address → amount), records how much each address has contributed
    // each address is linked to the total amount it has sent to the campaign
    // public means anyone can call a function to read its value

   // Memory of the contract – Campaign Data (campaign parameters and tracking variables)

    uint public minimumTarget;        
    // minimum amount required for success
    // public means anyone can call a function to read its value

    uint public campaignDuration;     
    // duration of the campaign
    // public means anyone can call a function to read its value

    uint public campaignStartTime;    
    // timestamp when the campaign starts
    // public means anyone can call a function to read its value

    uint public campaignEndTime;      
    // timestamp when the campaign ends
    // public means anyone can call a function to read its value

    uint public totalFundsCollected;  
    // total amount collected, updated every time someone funds the campaign
    // public means anyone can call a function to read its value

    uint public platformOwnerAssignedFunds; 
    // 5% assigned to platform owner
    // Assigned Funds (used only if campaign is successful)
    // public means anyone can call a function to read its value


    uint public campaignAdminAssignedFunds; 
    // 95% assigned to campaign admin
    // Assigned Funds (used only if campaign is successful)
    // public means anyone can call a function to read its value



    // In case of an unsuccessful campaign, no specific assigned funds are stored
    // refunds are determined using mapping(address => uint) public donor

    // Booleans
    bool public campaignClosed;      
    // indicates if the campaign has been closed
    // public means anyone can call a function to read its value


    bool public campaignSuccessful;  
    // indicates if the campaign reached the target
    // public means anyone can call a function to read its value


    // Constructor runs only once when the contract is deployed (created), and is used to initialize key variables
    constructor() {

    platformOwner = payable(msg.sender);
    // sets the platform owner as the address that deploys the contract

    currentState = State.NoCampaign;
    // sets the initial state to indicate that no campaign exists yet

    // other variables are left to default values and initialized later during campaign creation 
}

    // createCampaign(minimumTarget, campaignDuration)
    function createCampaign(uint _minimumTarget, uint _campaignDuration) public {
        // require ensures that no campaign has been created yet
        require(currentState == State.NoCampaign, "Campaign already created"); 
    
        // require ensures that the minimum target is a positive value
        require(_minimumTarget > 0, "Minimum target must be > 0");

        // require ensures that the campaign duration is a positive value
        require(_campaignDuration > 0, "Duration must be > 0");

        // caller becomes campaign admin
        campaignAdmin = msg.sender; 
        
        // stores the minimum amount required for the campaign to succeed
        minimumTarget = _minimumTarget;

        // stores the duration of the campaign
        campaignDuration = _campaignDuration;

       // records the time when the campaign starts
        campaignStartTime = block.timestamp;

        // calculates and stores the time when the campaign will end
        campaignEndTime = block.timestamp + _campaignDuration;

        // initializes the total funds collected to zero
        totalFundsCollected = 0;

        // sets the campaign as not closed
        campaignClosed = false;

        // sets the campaign as not successful
        campaignSuccessful = false;

        // updates the state to indicate that the campaign is now active
        currentState = State.CampaignOpen;
    }

    // fundCampaign()
    function fundCampaign() public payable {
    // public means that any user can call this function from outside the contract

    require(currentState == State.CampaignOpen, "Campaign is not open");
    // require ensures that the campaign is currently active

    require(!campaignClosed, "Campaign already closed");
    // require ensures that the campaign has not been closed

    require(msg.value > 0, "Contribution must be > 0");
    // require ensures that the user sends a positive amount of funds

    // if funding is attempted after the campaign duration has passed,
    // emit an event, refund the sender, and do not record the contribution
    if (block.timestamp >= campaignEndTime) {

        emit CampaignReadyToClose(block.timestamp);
        // emits an event to signal that the campaign duration has passed and the campaign can now be closed

        payable(msg.sender).transfer(msg.value);
        // returns the funds sent with this call to the donor (no message can be attached to the transfer)

        return;
        // stops the function without recording the contribution
    }

    donor[msg.sender] += msg.value;
    // records the contribution of the sender in donor[address]

    totalFundsCollected += msg.value;
    // increases the total funds collected by the amount sent

    // funds remain stored in the contract
}

    // closeCampaign()
    function closeCampaign() public {
    // public means that any user can call this function from outside the contract

        require(currentState == State.CampaignOpen, "Campaign is not active");
        // require ensures that the campaign is currently active

        require(!campaignClosed, "Campaign already closed");
        // require ensures that the campaign has not already been closed

        require(block.timestamp >= campaignEndTime, "Campaign duration not yet passed");
        // require ensures that the campaign duration has passed before allowing closure

        campaignCloser = msg.sender; 
        // record who closes the campaign

        campaignClosed = true;
       // marks the campaign as closed so that no further contributions can be made

        if (totalFundsCollected >= minimumTarget) {
        // checks if the campaign has reached the minimum target and is therefore successful

            campaignSuccessful = true;
            // marks the campaign as successful

            platformOwnerAssignedFunds = (totalFundsCollected * 5) / 100;
            // assign 5% to platform owner

            campaignAdminAssignedFunds = totalFundsCollected - platformOwnerAssignedFunds;
            // assign remaining 95% to admin

            currentState = State.CampaignClosedSuccessful;
           // updates the state to indicate that the campaign has been closed successfully

        } else {

            campaignSuccessful = false;
            // marks the campaign as unsuccessful

            currentState = State.CampaignClosedUnsuccessful;
            // donors will recover funds using donor[address]
        }
    }

    // withdrawAssignedFunds()
    function withdrawAssignedFunds() public {
    // public means that any user can call this function from outside the contract

    uint amount = 0;
    // temporary variable used to store the total amount to be withdrawn and transferred safely at the end of the function

    if (currentState == State.CampaignClosedSuccessful) {
        // checks if the campaign was successful, so assigned funds can be withdrawn by the platform owner or campaign admin
           
        // ensures that only the platform owner or campaign admin can withdraw funds in this state
        require(
         msg.sender == platformOwner || msg.sender == campaignAdmin,
         "Caller has no withdrawable funds"
        ); 


        if (msg.sender == platformOwner) {
            // if the caller is the platform owner, add the assigned 5% to amount

            amount = amount + platformOwnerAssignedFunds;
          // add the platform owner’s assigned funds (5% share) to the total withdrawal amount

            platformOwnerAssignedFunds = 0;
            // reset after adding to amount, to prevent double withdrawal
        }

        if (msg.sender == campaignAdmin) {
            // if the caller is the campaign admin, add the assigned 95% to amount

            amount = amount + campaignAdminAssignedFunds;
            // add the campaign admin’s assigned funds (95% share) to the total withdrawal amount

            campaignAdminAssignedFunds = 0;
            // reset after adding to amount, to prevent double withdrawal
        }

        require(amount > 0, "No funds available");
        // require ensures that the caller had assigned funds to withdraw

    } else if (currentState == State.CampaignClosedUnsuccessful) {
        // checks if the campaign was unsuccessful, so donors may withdraw their recorded contributions

        amount = donor[msg.sender];
        // donor withdraws their contribution

        require(amount > 0, "No funds available");
        // require ensures that there are funds available to withdraw

        donor[msg.sender] = 0;
        // resets the donor's recorded contribution to zero before transfer to prevent double withdrawal

    } else {
        revert("Withdrawal not available in current state");
        // reverts if withdrawal is attempted before the campaign has been closed
    }

    payable(msg.sender).transfer(amount);
    // transfers the withdrawn amount to the caller
}

}