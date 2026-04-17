[DLT5140](https://www.um.edu.mt/vle/course/view.php?id=99264) \- Giorgio Bonuccelli \- 

## **Assignment 1 — Design (not program) an Exam Marking Smart Contract**

## **1\) Actors** {#1)-actors}

Student

* Owner of the assessable element  
* may request a revision within 30 days and pay 100 Finney

Main Examiner 1, 2, 3

* Primary assessors  
* Each submits one mark independently


Additional Examiner 1, 2

* Secondary assessors  
* Submit marks only if the difference between the highest and lowest main mark is \> 10 

Arbiter

* Reviews the assessable element in case of revision  
* Assigns the updated mark

University

*  Receives part of the revision payment depending on the outcome

## 

## **2\) Memory of the Contract** {#2)-memory-of-the-contract}

### **Participants** {#participants}

student, address of the student associated with the assessable element

mainExaminer1, address of main examiner 1  
mainExaminer2, address of main examiner 2  
mainExaminer3, address of main examiner 3

additionalExaminer1, address of additional examiner 1  
additionalExaminer2, address of additional examiner 2

arbiter, address of the arbiter responsible for revision  
university, address of the university receiving payments

### **Marks** {#marks}

* mainMark1, records the mark submitted by main examiner 1  
* mainMark2, records the mark submitted by main examiner 2  
* mainMark3, records the mark submitted by main examiner 3  
* additionalMark1, records the mark submitted by additional examiner 1  
* additionalMark2, records the mark submitted by additional examiner 2  
* originalMark, stores the mark calculated in Case 2 (after additional examiners)  
* updatedMark, stores the mark assigned by the arbiter during revision  
* finalMark, stores the final mark after the process is completed


### **Booleans** {#booleans}

* main1Submitted, indicates whether main examiner 1 has submitted their mark  
* main2Submitted, indicates whether main examiner 2 has submitted their mark  
* main3Submitted, indicates whether main examiner 3 has submitted their mark  
* add1Submitted, indicates whether additional examiner 1 has submitted their mark  
* add2Submitted, indicates whether additional examiner 2 has submitted their mark  
* usedAdditionalExaminers, indicates whether additional examiners are required (Case 2\)  
* revisionRequested, indicates whether the student has requested a revision  
* arbiterSubmitted, indicates whether the arbiter has submitted the updated mark


### **Time** {#time}

publicationTime, records the time when the original mark is published

### **State** {#state}

* WaitingMainMarks, waiting for the three main examiners  
* WaitingAdditionalMarks, waiting for the two additional examiners  
* ResultComputed, original mark has been calculated  
* WaitingRevisionDecision, revision requested, and waiting for arbiter

## Finished, final mark has been determined {#finished,-final-mark-has-been-determined}

## **3\) Design** {#3)-design}

We design a smart contract for one assessable element (an exam, an assignment, etc.) to manage the evaluation process. The actors are:

* One student  
* Three main examiners  
* Two additional examiners  
* One revision arbiter

Process Description

* The assessable element (an exam, an assignment, etc.) is already present and pending review.  
* The smart contract handles only the marking and revision process  
* The three main examiners submit their marks independently  
* If the difference between the highest and lowest main mark is greater than 10, the two additional examiners submit their marks independently

Overview of cases:

Case 1 → Direct final mark  
Case 2 → Additional examiners → original mark  
Case 3 → Revision phase  
↳ Case 3a → Revision NOT possible  
↳ Case 3b → Revision requested → Arbiter decision  
↳ Case 3b(i) → Small difference (≤5)  
↳ Case 3b(ii) → Large difference (\>5)

The marking process follows these steps:

1\. The three main examiners submit their marks independently.

### **Case 1 — Marks within 10 points** {#case-1-—-marks-within-10-points}

**Required:**

All three main examiners have submitted their marks  
The difference between the highest and lowest mark is ≤ 10  

**Process:**

The final mark is calculated as the average of the three main marks  
The process is completed  
No revision is possible

**Memory used**

*Marks*

mainMark1  
mainMark2  
mainMark3  
finalMark

*Booleans*

main1Submitted (boolean)  
main2Submitted (boolean)  
main3Submitted (boolean)

*State*

WaitingMainMarks → Finished

**Output: Final mark**

### **Case 2 — Marks differ by more than 10** {#case-2-—-marks-differ-by-more-than-10}

### 

**Required:**

All three main examiners have submitted their marks  
The difference between the highest and lowest mark is \> 10

**Process:**  
The two additional examiners submit their marks  
All five marks are considered  
The highest and lowest marks are discarded  
The original mark is calculated as the average of the three remaining marks after discarding the highest and lowest marks.

**Memory used**

*Marks*

* mainMark1  
* mainMark2  
* mainMark3  
* additionalMark1  
* additionalMark2  
* originalMark


*Booleans*

* main1Submitted (boolean)  
* main2Submitted (boolean)  
* main3Submitted (boolean)  
* add1Submitted (boolean)  
* add2Submitted (boolean)  
* usedAdditionalExaminers (boolean)

*State*

* WaitingMainMarks → WaitingAdditionalMarks → ResultComputed

**Output: Original mark** 

### **Case 3 — Revision**  {#case-3-—-revision}

#### ***Case 3a — Revision not requested or not possible*** {#case-3a-—-revision-not-requested-or-not-possible}

**Required**:

usedAdditionalExaminers \= true (Case 2\)  
EITHER: The student does not request revision OR more than 30 days have passed since publication

**Process:**

No revision is performed  
The final mark is set equal to the original mark  
The process is completed  
No further actions are possible

**Memory used**

*Marks:*

originalMark  
finalMark

*Booleans:*

usedAdditionalExaminers (boolean)  
revisionRequested (boolean)

*Time:*

publicationTime

*State:*

ResultComputed → Finished

**Output: Final mark**

#### ***Case 3b — Revision requested*** {#case-3b-—-revision-requested}

**Required:**

usedAdditionalExaminers \= true (Case 2\)   
The request is made within 30 days of publication of the original mark  
The student pays 100 Finney

*Error messages:*

"Revision not allowed without additional examiners."  
"Revision period expired."  
"Incorrect payment amount."

**Process:**

The student submits a revision request and pays 100 Finney  
The contract records the revision request  
The arbiter reviews the assessable element  
updatedMark is assigned by the arbiter  
The arbiter receives 20 Finney from the payment  
The contract calculates: difference \= |updatedMark \- originalMark|

**Memory used**

*Marks:*

originalMark  
updatedMark

*Booleans:*

arbiterSubmitted (boolean)  
usedAdditionalExaminers (boolean)  
revisionRequested (boolean)

*Time:*

publicationTime

*State:*

ResultComputed → WaitingRevisionDecision

**Output: No final output**  
Process continues to Case 3b(i) or Case 3b(ii)

#### ***Case 3b(i) — Small difference (≤ 5\)*** {#case-3b(i)-—-small-difference-(≤-5)}

**Required:** 

\-The arbiter has submitted the updated mark  
 The absolute difference between updatedMark and originalMark is ≤ 5

**Process:**

The university receives 80 Finney  
The arbiter keeps 20 Finney  
The student receives no refund  
The final mark is set equal to the updated mark  
The process is completed  
No further actions are possible

**Memory used**

*Marks:*

originalMark  
updatedMark  
finalMark

*Booleans:*

arbiterSubmitted (boolean)

*State:*

WaitingRevisionDecision → Finished

**Output: Final mark**

#### ***Case 3b(ii) — Large difference (\> 5\)*** {#case-3b(ii)-—-large-difference-(>-5)}

Required:  
The arbiter has submitted the updated mark  
The absolute difference between updatedMark and originalMark is \> 5

Process:

The university receives 20 Finney  
The arbiter keeps 20 Finney  
The student is refunded 60 Finney  
The final mark is set equal to the updated mark  
The process is completed  
No further actions are possible  
Memory used

Marks:

originalMark  
updatedMark  
finalMark

Booleans:

arbiterSubmitted (boolean)

State:

WaitingRevisionDecision → Finished

**Output: Final mark**

### **1.2 Workflow**  {#1.2-workflow}

START

→ Assessable element is present and pending review

→ Has Main Examiner 1 submitted?  
      No  → wait  
      Yes ↓

→ Has Main Examiner 2 submitted?  
      No  → wait  
      Yes ↓

→ Has Main Examiner 3 submitted?  
      No  → wait  
      Yes ↓

All 3 main marks are in.

Compute: differenceMain \= highest mark \- lowest mark.

Is differenceMain \<= 10?

  YES → CASE 1  
    finalMark \= (mainMark1 \+ mainMark2 \+ mainMark3) / 3  
        Output final mark. Done.

  NO  → CASE 2

        Has Additional Examiner 1 submitted?  
              No  → wait  
              Yes ↓

        Has Additional Examiner 2 submitted?  
              No  → wait  
              Yes ↓

        All 5 marks are in.  
        Drop the highest and the lowest.  
        originalMark \= average of the remaining 3  
        Output originalMark  
        Process continues.

        → CASE 3  
          Did the student request a revision within 30 days of the original mark's publication AND pay 100 Finney?

          NO  → CASE 3a  
                finalMark \= originalMark  
                Output final mark. Done.

          YES → CASE 3b  
                Arbiter submits an updated mark.  
                updatedMark \= mark assigned by arbiter  
                Arbiter keeps 20 Finney.

                Compute: difference \= |updatedMark \- originalMark|

                Is difference \<= 5?

                YES → CASE 3b(i)  
                      University gets 80 Finney.  
                      Student gets no refund.  
                      finalMark \= updatedMark  
                      Output final mark. Done.

                NO  → CASE 3b(ii)  
                      University gets 20 Finney.  
                      Student refunded 60 Finney.  
                      finalMark \= updatedMark  
                      Output final mark. Done.

* 

# **4\) Contract Interface**  {#4)-contract-interface}

The smart contract exposes a set of functions that allow the actors to interact with the system and execute the marking and revision process.

submitMainMark(mark)  
 // allows a main examiner to submit their mark for the assessable element  
 // can only be called by one of the three main examiners  
 // can only be called once per examiner

submitAdditionalMark(mark)  
 // allows an additional examiner to submit their mark when Case 2 is triggered  
 // can only be called by one of the two additional examiners

computeOriginalMark()  
// can be called once all required marks are submitted  
// computes:  
// \- Case 1: final mark as the average of the three main marks  
// \- Case 2: original mark after removing the highest and lowest marks

requestRevision()  
 // allows the student to request revision within 30 days  
 // requires payment of 100 Finney  
// ensures only the student can call this function

submitArbiterMark(mark)  
 // allows the arbiter to assign the updated mark during revision  
 // can only be called by the arbiter  
 // triggers payment distribution logic

finalizeMark()  
// stores the final mark depending on the case:  
// \- Case 1: average of main marks  
// \- Case 3a: original mark  
// \- Case 3b(i) and 3b(ii): updated mark  
// completes the process

The interface ensures that only authorized actors can perform specific actions and that the correct sequence of operations is enforced throughout the process.

## **Assignment 1: Design and program a smart contract for a single crowdfunding campaign.**

## **Table of content**

## **Ambiguity clarification**

### **Contract closure after campaign completion**

The statement “once a campaign is closed and funds assigned, the smart contract is closed” is ambiguous, as it does not specify whether funds are transferred immediately or remain stored in the contract.

Given that “assigned” is defined as funds being held in the smart contract but recorded internally for each beneficiary, this implies that funds are not transferred automatically upon closure. Instead, they remain available for withdrawal by the respective users.

The contract is therefore considered closed in terms of campaign functionality, meaning that no new campaigns can be created and no further funding can occur. However, it remains operational to allow users to withdraw their assigned funds.

**Assumption:** After campaign closure, the contract is no longer usable for campaign-related actions but continues to function for withdrawal of internally assigned funds.

### **Assignment and withdrawal are separate steps**

The assignment does not explicitly state whether funds are transferred immediately or later withdrawn.

I interpret this as involving two separate stages. First, once the campaign is closed, the contract allocates the funds internally among the relevant parties. Second, the entitled user may later call a withdrawal function to claim the assigned funds. This applies to both the successful and the unsuccessful campaign cases.

**Assumption:** Funds are not transferred immediately upon campaign closure, but are first assigned and later withdrawn by the entitled users.

### **Any user may close the campaign**

The statement that “anyone may declare the campaign closed” is ambiguous regarding access control.

I interpret this as meaning that any address may call the closing function once the campaign duration has expired. The outcome is determined automatically by the contract based on whether the funding target has been reached. The caller's identity is recorded by the contract.

**Assumption:** The closing function is publicly callable, but only executable when the campaign duration has expired, and the contract stores the identity of the user who closes the campaign.

### **The platform owner is defined at initialization.**

The assignment states that the platform owner is identified when the contract is initialized, but does not clarify whether this can change.

I interpret this as meaning that the platform owner’s address is fixed at contract creation and remains constant throughout the contract’s lifecycle.

**Assumption:** The contract deployer becomes the platform owner, and this address remains fixed throughout the contract lifecycle.

### **Single campaign per contract**

The assignment does not explicitly state whether multiple campaigns can be handled. However, based on the statement “once a campaign is closed and funds assigned, the smart contract is closed,” I interpret the assignment as supporting only a single campaign within the contract. Once a campaign is created, no other campaign can ever be created in that same contract, even after the current campaign has been completed and closed.

**Assumption:** The contract supports exactly one campaign for its entire lifetime and does not manage multiple campaigns, either concurrently or sequentially.

## **1\) Actors**

### **Platform Owner**

Owner of the crowdfunding platform  
Is assigned 5% of the collected funds if the campaign is successful

### **Campaign Admin**

The user who creates the campaign  
Sets the minimum amount to be collected and the campaign duration  
Is assigned 95% of the collected funds if the campaign is successful

### **Donor**

Any user who deposits funds into the campaign  
The amount contributed is recorded in the contract memory  
If the campaign is unsuccessful, they may withdraw the funds assigned back to them

### **Caller Closing the Campaign**

Any user  
May declare the campaign closed after the campaign duration has passed

**Note:** As the assignment does not specify any limitations on user roles, the same address may act in multiple roles. For example, the platform owner may also act as the campaign admin or as a donor.

## **2\) Memory of the Contract**

### **Participants**

platformOwner, address of the platform owner, set to the address that deploys the contract

campaignAdmin, address of the user who created the campaign

donor\[address\], mapping (address → amount), represents the amount contributed by each address // Uses msg.sender as the donor identifier and msg.value as the contributed amount

campaignCloser, address of the user who declares the campaign closed

### **Campaign Data**

minimumTarget, the minimum amount that must be collected for the campaign to succeed

campaignDuration, the length of time during which the campaign runs (e.g., hours or days)

campaignStartTime, records the time when the campaign is created

campaignEndTime, records the time when the campaign is due to end

totalFundsCollected, records the total amount deposited into the campaign

### **Assigned Funds**

platformOwnerAssignedFunds, funds internally assigned to the platform owner after a successful campaign

campaignAdminAssignedFunds, funds internally assigned to the campaign admin after a successful campaign

//to return the donor funds in case of unsuccessful campaign, the smart contract uses the info collected by the storage mapping  donor\[address\], mapping (address → amount)

### **Booleans**

campaignClosed, indicates whether the campaign has been declared closed

campaignSuccessful, indicates whether the campaign was successful after closure

### **Time**

campaignEndTime, records the time when the campaign is due to end

### **State**

NoCampaign, no crowdfunding campaign is currently active

CampaignOpen, a campaign has been created and is accepting funds

CampaignClosedSuccessful, the campaign has been closed, and enough funds were collected

CampaignClosedUnsuccessful, the campaign has been closed, and the minimum target was not reached

**3\) Events**

An event may be emitted if a user attempts to fund the campaign after the campaign duration has expired. In that case, the event signals that the campaign is now ready to be closed.  It provides transparency by allowing external observers to track when the campaign becomes eligible for closure.

event CampaignReadyToClose(uint timestamp);

## **4\) Design**

We design a smart contract for a crowdfunding platform that supports a single crowdfunding campaign. The platform is owned by a platform owner identified upon contract initialization.

### **Process Description**

If no crowdfunding campaign has been run yet, any user may create a campaign by setting the minimum amount to be collected and the campaign duration. The caller becomes the campaign admin.

Once a campaign is open, any user may deposit funds into it.

The deposited funds remain in the smart contract and are assigned internally to the campaign.

After the duration of the campaign has passed, any user may declare the campaign closed.

If enough funds were collected, the platform owner gets 5% assigned to him or her, and the campaign admin gets the remaining 95% assigned to him or her.

If not enough funds were collected, each donor gets his or her contribution assigned back and may later withdraw it.

Once the campaign is closed and the funds are assigned, the contract is closed for campaign operations.

“At any point in time, any user may withdraw funds assigned to him or her.” In this design, funds become available for withdrawal only after they have been internally assigned by the contract following campaign closure.

### **Overview of cases**

Case 1 → Campaign creation  
Case 2 → Campaign funding  
Case 3 → Campaign closed successfully  
Case 4 → Campaign closed unsuccessfully  
Case 5 → Withdrawal of assigned funds

### **Case 1 — Campaign creation**

**Required:**  
No crowdfunding campaign has yet been run  
A user provides the minimum target  
A user provides the campaign duration

**Process:**  
A new campaign is created  
The caller becomes the campaign admin  
The minimum target is stored  
The campaign duration is stored  
The campaign start time is recorded  
The campaign end time is calculated  
The total funds collected is initialised to zero  
The campaign becomes active

**Memory used**

*Participants*  
platformOwner    
campaignAdmin

*Campaign Data*  
minimumTarget  
campaignDuration  
campaignStartTime  
campaignEndTime  
totalFundsCollected

*Booleans*  
campaignClosed (boolean)  
campaignSuccessful (boolean)

*State*  
NoCampaign → CampaignOpen

Output:  
Campaign created

### **Case 2 — Funding the campaign**

**Required:**  
A campaign is currently active  
The campaign has not been closed  
A user deposits funds into the campaign

**Process:**

If the current time is before the campaign end time:

The deposited funds are accepted by the contract  
The contract records the sender (msg.sender) and the amount contributed (msg.value)  
The total funds collected are updated  
The funds remain stored in the contract

If the current time is equal to or after the campaign end time:

A notification (event) is emitted to signal that the campaign duration has passed and the campaign is ready to be closed  
The deposited funds are immediately refunded to the sender  
The contribution is not recorded

**Memory used**

*Campaign Data*  
totalFundsCollected  
*campaignEndTime*

*Participants*  
donor\[address\]

*State*  
CampaignOpen → CampaignOpen

*Output:*  
Contribution recorded (if before campaign end time)  
Contribution rejected and refunded (if after campaign end time)

### **Case 3 — Campaign closed successfully**

**Required:**  
A campaign is currently active  
The campaign duration has passed  
The campaign has not yet been closed  
totalFundsCollected \>= minimumTarget

**Process:**

Any user may declare the campaign closed  
The campaign is marked as closed  
The campaign is marked as successful  
The caller is recorded as campaignCloser  
5% of the collected funds is assigned to the platform owner  
95% of the collected funds is assigned to the campaign admin  
No refunds are assigned to donors  
No further funding is possible

**Memory used**

*Participants*  
platformOwner  
campaignAdmin  
campaignCloser

*Campaign Data*  
minimumTarget  
totalFundsCollected  
campaignEndTime

*Assigned Funds*  
platformOwnerAssignedFunds  
campaignAdminAssignedFunds

*Booleans*  
campaignClosed (boolean)  
campaignSuccessful (boolean)

*State*  
CampaignOpen → CampaignClosedSuccessful

*Output:*  
Funds assigned to the platform owner and the campaign admin

### **Case 4 — Campaign closed unsuccessfully**

**Required:**  
A campaign is currently active  
The campaign duration has passed  
The campaign has not yet been closed  
totalFundsCollected \< minimumTarget

**Process:**

Any user may declare the campaign closed  
The campaign is marked as closed  
The campaign is marked as unsuccessful  
The caller is recorded as campaignCloser  
The amount recorded in donor\[address\] remains available for later withdrawal by each donor  
The platform owner receives no assigned cut  
The campaign admin receives no assigned proceeds  
No further funding is possible

**Memory used**

*Participants*  
campaignCloser  
donor\[address\]

*Campaign Data*  
minimumTarget  
totalFundsCollected  
campaignEndTime

*Booleans*  
campaignClosed (boolean)  
campaignSuccessful (boolean)

*State*  
CampaignOpen → CampaignClosedUnsuccessful

*Output:*  
The amounts recorded in donor\[address\] remain available for later withdrawal by donors

### **Case 5 — Withdrawal of assigned funds**

**Required:**  
The caller has funds available for withdrawal following Case 3 or Case 4  
The amount available for withdrawal is greater than zero

**Process:**  
The caller invokes the withdrawal function  
The contract checks the amount available for withdrawal  
The recorded amount is reset to zero  
The amount is transferred to the caller  
The withdrawal may be performed by:  
The platform owner after a successful campaign  
The campaign admin after a successful campaign  
a donor after an unsuccessful campaign

**Memory used**

*Participants*  
platformOwner  
campaignAdmin  
donor\[address\]

*Assigned Funds*  
platformOwnerAssignedFunds  
campaignAdminAssignedFunds  
// In case of an unsuccessful campaign, donor refunds are determined using donor\[address\]

*State*  
CampaignClosedSuccessful → CampaignClosedSuccessful  
CampaignClosedUnsuccessful → CampaignClosedUnsuccessful

*Output:*  
Assigned funds withdrawn

## **4\) Contract Interface**

The smart contract exposes a set of functions that allow the actors to interact with the system and execute the crowdfunding process.

//The platform owner is automatically set when the contract is deployed. The constructor assigns the platform owner to the address that deploys the contract.

createCampaign(minimumTarget, campaignDuration)  
// require no crowdfunding campaign has yet been run

// allows any user to create a campaign  
// stores the campaign admin, the minimum target, and the campaign duration  
// records the campaign start time and calculates the campaign end time

fundCampaign()  
// require a campaign to be active and not closed  
// allows any user to deposit funds into the campaign  
// checks whether the current time is before the campaign end time

// if the current time is before the campaign end time:  
// records the sender (msg.sender) and the amount contributed (msg.value) by updating the mapping donor\[address\], which stores the total amount contributed by each address  
// updates totalFundsCollected by adding the amount contributed (msg.value)  
// funds remain stored in the smart contract

// if the current time is equal to or after the campaign end time:  
// emits the event CampaignReadyToClose to signal that the campaign duration has passed and the campaign is ready to be closed  
// immediately refunds the deposited funds to the sender  
// does not record the contribution

closeCampaign()  
// require a campaign to be active  
// require the campaign duration has passed  
// require the campaign has not already been closed

// allows any user to declare the campaign closed  
// records the caller as campaignCloser  
// marks the campaign as closed  
// if totalFundsCollected ≥ minimumTarget:  
// assigns 5% to the platform owner and 95% to the campaign admin  
// marks the campaign as successful  
// if totalFundsCollected \< minimumTarget:  
// marks the campaign as unsuccessful  
// donor refunds are determined using donor\[address\]

withdrawAssignedFunds()  
// require the caller has funds available for withdrawal  
// require the amount available for withdrawal is greater than zero

// resets the recorded amount to zero  
// allows the caller to withdraw funds  
// transfers the amount to the caller  
// can be called by the platform owner, campaign admin, or donors, depending on the outcome

The interface ensures that only valid actions are allowed at each stage of the campaign and that the correct sequence of operations is enforced throughout the process.

## **5\) Solidity Variable Declarations**

// Participants

address public platformOwner;

address public campaignAdmin;

address public campaignCloser;

mapping(address \=\> uint) public donor;

// Campaign Data

uint public minimumTarget;

uint public campaignDuration;

uint public campaignStartTime;

uint public campaignEndTime;

uint public totalFundsCollected;

// Assigned Funds

uint public platformOwnerAssignedFunds;

uint public campaignAdminAssignedFunds;

// Booleans

bool public campaignClosed;

bool public campaignSuccessful;

// State (enum)

enum State {

    NoCampaign,

    CampaignOpen,

    CampaignClosedSuccessful,

    CampaignClosedUnsuccessful

}

State public currentState;

// condition (pre-condition)

This statement enforces that the function can only execute if no campaign has already been created.

If the condition is not satisfied, the transaction is reverted, and no changes are made to the contract.

### **Interpretation**

This function allows any user to create a new campaign by providing a minimum target and a duration. However, the function will execute only if no campaign is currently active, ensuring that the contract manages only one campaign throughout its lifetime.

This section bridges the conceptual design of the contract with its actual implementation in Solidity.

## **6\) Solidity code** 

`// SPDX-License-Identifier: MIT`  
`pragma solidity ^0.8.20;`

`// This contract allows running ONE crowdfunding campaign at a time`  
`// People can send money, and depending on the result, funds are distributed or refunded`

`contract SingleCampaignCrowdfunding {`

   `// This event is emitted when a funding attempt is made after the campaign     duration`  
   `// It signals that the campaign can now be closed`  
   `event CampaignReadyToClose(uint timestamp);`

   `// enum defines all possible states of the campaign`  
   `enum State {`  
       `NoCampaign,                   // no campaign exists yet`  
       `CampaignOpen,                 // campaign is active`  
       `CampaignClosedSuccessful,     // campaign closed and target reached`  
       `CampaignClosedUnsuccessful    // campaign closed and target not reached`  
   `}`

   `// stores the current state of the campaign`  
   `// public means Solidity creates a function that allows anyone to call and read its value`  
   `State public currentState;`  
  

   `// Participants`

   `address payable public platformOwner;`  
   `// stores the platform owner address`  
   `// public means anyone can call a function to read its value`

   `address public campaignAdmin;`  
   `// address of the user who creates the campaign`  
   `// public means anyone can call a function to read its value`

   `address public campaignCloser;`  
   `// address of the user who closes the campaign`  
   `// public means anyone can call a function to read its value`

   `mapping(address => uint) public donor;`  
   `// mapping(address → amount), records how much each address has contributed`  
   `// each address is linked to the total amount it has sent to the campaign`  
   `// public means anyone can call a function to read its value`

  `// Memory of the contract – Campaign Data (campaign parameters and tracking variables)`

   `uint public minimumTarget;`         
   `// minimum amount required for success`  
   `// public means anyone can call a function to read its value`

   `uint public campaignDuration;`      
   `// duration of the campaign`  
   `// public means anyone can call a function to read its value`

   `uint public campaignStartTime;`     
   `// timestamp when the campaign starts`  
   `// public means anyone can call a function to read its value`

   `uint public campaignEndTime;`       
   `// timestamp when the campaign ends`  
   `// public means anyone can call a function to read its value`

   `uint public totalFundsCollected;`   
   `// total amount collected, updated every time someone funds the campaign`  
   `// public means anyone can call a function to read its value`

   `uint public platformOwnerAssignedFunds;`  
   `// 5% assigned to platform owner`  
   `// Assigned Funds (used only if campaign is successful)`  
   `// public means anyone can call a function to read its value`

   `uint public campaignAdminAssignedFunds;`  
   `// 95% assigned to campaign admin`  
   `// Assigned Funds (used only if campaign is successful)`  
   `// public means anyone can call a function to read its value`

   `// In case of an unsuccessful campaign, no specific assigned funds are stored`  
   `// refunds are determined using mapping(address => uint) public donor`

   `// Booleans`  
   `bool public campaignClosed;`       
   `// indicates if the campaign has been closed`  
   `// public means anyone can call a function to read its value`

   `bool public campaignSuccessful;`   
   `// indicates if the campaign reached the target`  
   `// public means anyone can call a function to read its value`

   `// Constructor runs only once when the contract is deployed (created), and is used to initialize key variables`  
   `constructor() {`

   `platformOwner = payable(msg.sender);`  
   `// sets the platform owner as the address that deploys the contract`

   `currentState = State.NoCampaign;`  
   `// sets the initial state to indicate that no campaign exists yet`

   `// other variables are left to default values and initialized later during campaign creation`  
`}`

   `// createCampaign(minimumTarget, campaignDuration)`  
   `function createCampaign(uint _minimumTarget, uint _campaignDuration) public {`  
       `// require ensures that no campaign has been created yet`  
       `require(currentState == State.NoCampaign, "Campaign already created");`  
    
       `// require ensures that the minimum target is a positive value`  
       `require(_minimumTarget > 0, "Minimum target must be > 0");`

       `// require ensures that the campaign duration is a positive value`  
       `require(_campaignDuration > 0, "Duration must be > 0");`

       `// caller becomes campaign admin`  
       `campaignAdmin = msg.sender;`  
        
       `// stores the minimum amount required for the campaign to succeed`  
       `minimumTarget = _minimumTarget;`

       `// stores the duration of the campaign`  
       `campaignDuration = _campaignDuration;`

      `// records the time when the campaign starts`  
       `campaignStartTime = block.timestamp;`

       `// calculates and stores the time when the campaign will end`  
       `campaignEndTime = block.timestamp + _campaignDuration;`

       `// initializes the total funds collected to zero`  
       `totalFundsCollected = 0;`

       `// sets the campaign as not closed`  
       `campaignClosed = false;`

       `// sets the campaign as not successful`  
       `campaignSuccessful = false;`

       `// updates the state to indicate that the campaign is now active`  
       `currentState = State.CampaignOpen;`  
   `}`

   `// fundCampaign()`  
   `function fundCampaign() public payable {`  
   `// public means that any user can call this function from outside the contract`

   `require(currentState == State.CampaignOpen, "Campaign is not open");`  
   `// require ensures that the campaign is currently active`

   `require(!campaignClosed, "Campaign already closed");`  
   `// require ensures that the campaign has not been closed`

   `require(msg.value > 0, "Contribution must be > 0");`  
   `// require ensures that the user sends a positive amount of funds`

   `// if funding is attempted after the campaign duration has passed,`  
   `// emit an event, refund the sender, and do not record the contribution`  
   `if (block.timestamp >= campaignEndTime) {`

       `emit CampaignReadyToClose(block.timestamp);`  
       `// emits an event to signal that the campaign duration has passed and the campaign can now be closed`

       `payable(msg.sender).transfer(msg.value);`  
       `// returns the funds sent with this call to the donor (no message can be attached to the transfer)`

       `return;`  
       `// stops the function without recording the contribution`  
   `}`

   `donor[msg.sender] += msg.value;`  
   `// records the contribution of the sender in donor[address]`

   `totalFundsCollected += msg.value;`  
   `// increases the total funds collected by the amount sent`

   `// funds remain stored in the contract`  
`}`

   `// closeCampaign()`  
   `function closeCampaign() public {`  
   `// public means that any user can call this function from outside the contract`

       `require(currentState == State.CampaignOpen, "Campaign is not active");`  
       `// require ensures that the campaign is currently active`

       `require(!campaignClosed, "Campaign already closed");`  
       `// require ensures that the campaign has not already been closed`

       `require(block.timestamp >= campaignEndTime, "Campaign duration not yet passed");`  
       `// require ensures that the campaign duration has passed before allowing closure`

       `campaignCloser = msg.sender;`  
       `// record who closes the campaign`

       `campaignClosed = true;`  
      `// marks the campaign as closed so that no further contributions can be made`

       `if (totalFundsCollected >= minimumTarget) {`  
       `// checks if the campaign has reached the minimum target and is therefore successful`

           `campaignSuccessful = true;`  
           `// marks the campaign as successful`

           `platformOwnerAssignedFunds = (totalFundsCollected * 5) / 100;`  
           `// assign 5% to platform owner`

           `campaignAdminAssignedFunds = totalFundsCollected - platformOwnerAssignedFunds;`  
           `// assign remaining 95% to admin`

           `currentState = State.CampaignClosedSuccessful;`  
          `// updates the state to indicate that the campaign has been closed successfully`

       `} else {`

           `campaignSuccessful = false;`  
           `// marks the campaign as unsuccessful`

           `currentState = State.CampaignClosedUnsuccessful;`  
           `// donors will recover funds using donor[address]`  
       `}`  
   `}`

   `// withdrawAssignedFunds()`  
   `function withdrawAssignedFunds() public {`  
   `// public means that any user can call this function from outside the contract`

   `uint amount = 0;`  
   `// temporary variable used to store the total amount to be withdrawn and transferred safely at the end of the function`

   `if (currentState == State.CampaignClosedSuccessful) {`  
       `// checks if the campaign was successful, so assigned funds can be withdrawn by the platform owner or campaign admin`  
           
       `// ensures that only the platform owner or campaign admin can withdraw funds in this state`  
       `require(`  
        `msg.sender == platformOwner || msg.sender == campaignAdmin,`  
        `"Caller has no withdrawable funds"`  
       `);`

       `if (msg.sender == platformOwner) {`  
           `// if the caller is the platform owner, add the assigned 5% to amount`

           `amount = amount + platformOwnerAssignedFunds;`  
         `// add the platform owner’s assigned funds (5% share) to the total withdrawal amount`

           `platformOwnerAssignedFunds = 0;`  
           `// reset after adding to amount, to prevent double withdrawal`  
       `}`

       `if (msg.sender == campaignAdmin) {`  
           `// if the caller is the campaign admin, add the assigned 95% to amount`

           `amount = amount + campaignAdminAssignedFunds;`  
           `// add the campaign admin’s assigned funds (95% share) to the total withdrawal amount`

           `campaignAdminAssignedFunds = 0;`  
           `// reset after adding to amount, to prevent double withdrawal`  
       `}`

       `require(amount > 0, "No funds available");`  
       `// require ensures that the caller had assigned funds to withdraw`

   `} else if (currentState == State.CampaignClosedUnsuccessful) {`  
       `// checks if the campaign was unsuccessful, so donors may withdraw their recorded contributions`

       `amount = donor[msg.sender];`  
       `// donor withdraws their contribution`

       `require(amount > 0, "No funds available");`  
       `// require ensures that there are funds available to withdraw`

       `donor[msg.sender] = 0;`  
       `// resets the donor's recorded contribution to zero before transfer to prevent double withdrawal`

   `} else {`  
       `revert("Withdrawal not available in current state");`  
       `// reverts if withdrawal is attempted before the campaign has been closed`  
   `}`

   `payable(msg.sender).transfer(amount);`  
   `// transfers the withdrawn amount to the caller`  
`}`

`}`  
