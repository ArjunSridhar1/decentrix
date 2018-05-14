# Decentrix

## Who Are We?
There are 3 main problems in the music ticketing industry:
  - Fake tickets are sold on the secondary market
  - Ticket resellers hike up prices.
  - Bots buy up a lot of tickets and hike up prices as well.
In each situation, none of the profits are going back to the performing artist! We are solving this issue with blockchain technology.

Decentrix is a blockchain ticketing platform which *ensures authentic tickets* and *profit sharing with artists and venues*.

## Minumum Viable Product
We use the Ethereum platform to tokenize ticket sales. Currently, we have created a smart contract template acting as a ticket management system for a concert/event. We have deployed this contract several times to test the functionality. This contract manages 2 processes: the primary seller selling tickets to consumers (the primary market), and consumers reselling tickets to other consumers (the secondary market). 

In this contract, a preset number of tokens are created, each one representing a ticket. Customers can bid ethereum by sending it to this contract, and, if they are selected as the highest bidder, they receive a ticket from the primary seller.

Customers can also trade these tokens with another customer for ethereum with protocols that we have defined. Below we define protocols for both the consumer selling the token and the consumer buying the token in the secondary market. These would be abstracted away with a UI.

Although cuts on each transcation (going to either the artist or our company) have not been implemented yet, those changes will fit well with our current implementation. It involves introducting a new wallet argument for the artist, imposing some set percentage cut on every transaction (which is agreed upon deploying the contract), and transferring those funds to the artist's wallet regularly. However, the entire consumer / seller ecosystem is already implemented at this time.

## Deploying the MVP
The solidity contract needs to deployed to see the proof-of-concept.  You need to have Metamask installed in your browser.You need two Metamask accounts for this to work. For this entire tutorial, **Account 1 is the primary ticket seller, Account 2 is the ticket buyer / concert-goer.** Account 2 can also be a consumer reselling tickets on the secondary market.

Please use the Rinkeby test network for this proof-of-concept. For ether to play around with, use the Rinkeby Test Network Faucet. 

### As the Primary Seller
To deploy the contract with Account 1, you can use the online Remix solidity editor.
  1. Visit https://remix.ethereum.org/.
  2. Replace the text in the left window with the entire body of the contract in this repo.
  3. In the Compile tab, click "Start to Compile"
  4. In the Run tab, in the field next to the deploy button, you need to enter information about how many tickets to generate, the concert name, the ticket token symbol, and the primary seller Metamask address, which should be Address 1. This address will get ownership of all the tokens first. Each field needs to be surrounded by quotes.
     For example, you would enter the following to create an initial supply in address Account 1 of 10000 tickets with symbol kanye_ticket for a Kanye West Concert:
     "10000", "Kanye West Concert", "kanye_ticket", "address of Account 1 -- need to put actual hex address here"
  5. Accept the transaction in your Metamask addon. Make sure you have enough ether for transaction costs!
  6. You should see your pending transactions in the window below now show all the functions listed in this smart contract. Now you have now deployed the contract, and are connected to the contract with Account 1!
  7. In your Metamask browser addon, add the contract address as a new Token. You should see that Account 1 owns all of the tickets initially. 

### As a Concert-Goer
To connect to the contract with Account 2, you can use the online Remix solidity editor.
In your Metamask wallet, add our test token by entering the contract address from the previous part.
  1. Visit https://remix.ethereum.org/ in a new tab. 
  2. Replace the text in the left window with the entire body of the contract in this repo.
  3. In the Compile tab, click "Start to Compile"
  4. In the Run tab, make sure your Metamask wallet Account 2 is in the Account field. 
  5. In the Run tab, in the "Load contract from Address" field, put the follwing contract address without quotes. Click the "At Address" button. 
     You should see your pending transactions in the window below now show all the functions listed in this smart contract. Now you are connected with Account 2 to the contract you deployed with Account 1!
  6. In your Metamask browser addon, add the contract address as a new Token, if the token is not already listed. You should see that Account 2 owns 0 tickets initially.

## Interacting with the MVP
You can interact with the contract by filling in inputs to the functions and clicking their buttons. I will be referring to the ticket buyer as Account 2 and the primary ticket seller as Account 1 for clarity as to what a consumer can do vs a primary seller. Below are a few things you can do to interact:

NOTE: All prices require 18 additional zeros. For example, if you are selling/buying a ticket for 1 ether, the price you input to the system is 1000000000000000000.
  - **Bidding on Tickets** (Account 2 action) - Bid on a token as a consumer by sending ethereum to the contract address (the field you filled in in step 6). 
  - **Reselling Tickets** (Account 2 action) - Resell your token ticket as a consumer to another consumer on an agreed-upon price in ethereum. This is a two step process. Call the "resellTicketFor" as the seller with the price in ether at which you want to sell the ticket. The contract holds onto your token for you to ensure no foul play. Then when another user calls "buyResoldTicket" with your address and your price (indicating that they want to buy a ticket from you), you will receive your ether and the ticket will be transfered to the buyer.
  - **Buy a Resold Ticket** (Account 2 action) - Buy a resold ticket from a consumer for an agreed-upon price. Currently this requires you to know which address you will be buying from, but this will be solved in future steps. This is a two step process in this MVP. To do this, first send the ethereum you wish to spend on the ticket from Account 2 to the contract address. Then call the "buyResoldTicket" function with the address from which you are purchasing the ticket (Account 1) and the price at which both of you agreed to sell the ticket. This transfers your ethereum to the selling address and transfers a token from them to your wallet. 
  - **Releasing Tickets** (Account 1 action) - As a primary seller, release a ticket to the latest highest bidder from your wallet. This would normally not be a public function (allowing anyone to call it), but it is public for now for proof-of-concept. To do this, call the "releaseTicket" function as Account 1.
  
## Future Steps
We have plenty of improvements to make to take this MVP to a fully functioning system. Here are the most important improvements we hope to make:
  - **Transaction Cuts** - See the last part of the "Minimum Viable Product" section above.
  - **Making a UI** - Interacting with the contract through the Remix IDE is too low level for a customer. We want to abstract away the complexity of the underlying technology by making an easy to use UI for both ticket buyers and sellers.
  - **Different Types of Bids** - We currently only have one class of tickets. But we want to be able to release multiple types of tickets (General Admission, Nosebleeders, etc), each of which has a separate bidding pool.
  - **Claiming Seats and Tickets** - We want to attach seat preferences to bids, so when a consumer gets a ticket, they get the seat they want as well. we also would like to implement a conversion from token to QR code for a unique ticket.
  - **Improving Reselling Tickets** - As mentioned before, currently you need to know who you will buy from to buy a resold ticket. This will be fixed by adding a listing page for reselling tickets. A consumer wishing to buy a resold ticket can then browse this listing and select which ticket he/she would like to purchase. These listings will probably not be stored on the blockchain, but rather some other backing database for scalability reasons.
