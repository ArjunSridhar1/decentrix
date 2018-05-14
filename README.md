# Decentrix

## Who Are We?
There are 3 main problems in the music ticketing industry:
  1. Fake tickets sold in the secondary market
  2. Ticket resellers hike up prices.
  3. Bots buy up a lot of tickets and hike up prices as well.
In each situation, none of the profits are going back to the performing artist! We are solving this issue with blockchain technology.

Decentrix is a blockchain ticketing platform which ensures authentic tickets and profit sharing with artists and venues.

## Minumum Viable Product
Currently, we have a smart contract deployed acting as the managing system for a certain concert as the primary seller of tickets. In this contract, a variable number of tokens have been created, 
each one representing a ticket. Customers can bid ethereum by sending it to this contract, and, if they are selected as the highest bidder, they receive a ticket.
Customers can also trade these tokens with another customer for ethereum with a function that we have defined. Lastly, a customer can claim his or her ticket by using our contract's claim function, allowing them to actually receive their ticket.

## Interacting with the MVP
The solidity contract in this repo is currently deployed at contract address: 
To see the contract details, please visit:

To interact with the contract, you can use the online Remix solidity editor. You need to have a Metamask account and have Metamask installed in your browser.
In your Metamask wallet, add our test token by entering the following address: .

  1. Visit https://remix.ethereum.org/. 
  2. Replace the text in the left window with the entire body of the contract in this repo.
  3. In the Settings tab, select the following compiler version: . It needs to be the same as the one used to originally deploy the contract. 
  4. In the Compile tab, click "Start to Compile"
  5. In the Run tab, make sure your Metamask wallet is in the Account field. 
  6. In the Run tab, in the "Load contract from Address" field, put the follwing (without quotes):. Click the "At Address" button. 
     You should see your pending transactions in the window below now show all the functions listed in this smart contract. Now you are connected to the deployed contract!
     
You can interact with the contract by filling in inputs to the functions and clicking their buttons. Below are a few things you can do to interact:
  - **Bidding on Tickets** (Customer action) - Bid on a token as a consumer by sending ethereum to the contract address (the field you filled in in step 6). 
  - **Reselling Tickets** (Customer action) - Resell your token ticket as a consumer to another consumer on an agreed-upon price in ethereum.
  - **Buy a Resold Ticket** (Customer action) - Buy a resold ticket from a consumer for an agreed-upon price. Currently this requires you to know which address you will be buying from, but this will be solved in future steps.
  - **Releasing Tickets** (Primary seller action) - As a primary seller, release a ticket to the latest highest bidder from your wallet. This would normally not be a public function (allowing anyone to call it), but it is public for now for proof-of-concept.
  
## Future Steps
We have plenty of improvements to make to take this MVP to a fully functioning system. Here are the most important improvements we hope to make:
  - **Making a UI** - Interacting with the contract through the Remix IDE is too low level for a customer. We want to abstract away the complexity of the underlying technology by making an easy to use UI for both ticket buyers and sellers.
  - **Improving Reselling Tickets** - As mentioned before, currently you need to know who you will buy from to buy a resold ticket. This will be fixed by adding a listing page for reselling tickets. A consumer wishing to buy a resold ticket can then browse this listing and select which ticket he/she would like to purchase.
  - **Lasting Bids** - Currently a consumer's bid on a ticket only lasts until the
  - **Different Types of Bids** - We currently only have one class of tickets. But we want to be able to release multiple types of tickets (General Admission, Nosebleeders, etc), each of which has a separate bidding pool.
  - **Claiming Seats and Tickets** - We want to attach seat preferences to bids, so when a consumer gets a ticket, they get the seat they want as well. we also would like to implement a conversion from token to QR code for a unique ticket.
