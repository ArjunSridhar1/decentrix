pragma solidity ^0.4.16;

interface tokenRecipient { function receiveApproval(address _from, uint256 _value, address _token, bytes _extraData) public; }

contract TokenERC20 {
    // Public variables of the token
    string public name;
    string public symbol;
    uint8 public decimals = 18;
    // 18 decimals is the strongly suggested default, avoid changing it
    uint256 public totalSupply;
    address public owner;
    
    // This creates an array with all balances
    mapping (address => uint256) public balanceOf;
    mapping (address => mapping (address => uint256)) public allowance;
    
    uint256 private maxBid;
    address private maxBidder;
    
    // Mapping of resellers to the amount they are reselling their ticket for
    mapping (address => uint256) public resellerToPrice;
    // Mapping of second hand ticket buyers to the amount of ethereum they have
    //   transfered into the system to buy resold tickets
    mapping (address => uint256) public buyerToAmount;
    
    // This generates a public event on the blockchain that will notify clients
    event Transfer(address indexed from, address indexed to, uint256 value);

    /**
     * Constructor function
     *
     * Initializes contract with initial supply tokens to the creator of the contract
     */
    function TokenERC20(
        uint256 initialSupply,
        string tokenName,
        string tokenSymbol,
        address contractOwner
    ) public {
        totalSupply = initialSupply * 10 ** uint256(decimals);  // Update total supply with the decimal amount
        balanceOf[msg.sender] = totalSupply;                // Give the creator all initial tokens
        name = tokenName;                                   // Set the name for display purposes
        symbol = tokenSymbol;                               // Set the symbol for display purposes
        owner = contractOwner;                              // Owner for ethereum transfer purposes
    }


    /**
     * Internal transfer, only can be called by this contract
     */
    function _transfer(address _from, address _to, uint _value) internal {
        // Prevent transfer to 0x0 address. Use burn() instead
        require(_to != 0x0);
        // Check if the sender has enough
        require(balanceOf[_from] >= _value);
        // Check for overflows
        require(balanceOf[_to] + _value > balanceOf[_to]);
        // Save this for an assertion in the future
        uint previousBalances = balanceOf[_from] + balanceOf[_to];
        // Subtract from the sender
        balanceOf[_from] -= _value;
        // Add the same to the recipient
        balanceOf[_to] += _value;
        Transfer(_from, _to, _value);
        // Asserts are used to use static analysis to find bugs in your code. They should never fail
        assert(balanceOf[_from] + balanceOf[_to] == previousBalances);
    }

    /**
     * Transfer tokens
     *
     * Send `_value` tokens to `_to` from your account
     *
     * @param _to The address of the recipient
     * @param _value the amount to send
     */
    function transfer(address _to, uint256 _value) public {
        _transfer(msg.sender, _to, _value);
    }


    /**
     * Transfer tokens from other address
     *
     * Send `_value` tokens to `_to` on behalf of `_from`
     *
     * @param _from The address of the sender
     * @param _to The address of the recipienttime 
     * @param _value the amount to send
     */
    function transferFrom(address _from, address _to, uint256 _value) public returns (bool success) {
        //require(_value <= allowance[_from][msg.sender]);     // Check allowance
        //allowance[_from][msg.sender] -= _value;
        _transfer(_from, _to, _value);
        return true;
    }
    
    
    /** 
     * Ticket seller action.
     * 
     * Releases a ticket to the highest bidder. Transfers the ethereum to the owner,
     * and transfers a ticket from the owner to the highest bidder.
     */
    function releaseTicket() {
            // Give out a token to the highest bidder, and drop all other bids
        if (maxBidder != 0x0) {
            uint256 tokens = 1;
            owner.transfer(maxBid);
            transferFrom(owner, maxBidder, tokens);
            
            maxBid = 0;
            maxBidder = 0x0;
        }
    }
    
    /**
     * Consumer action.
     * 
     * Resell a ticket for the specified amount of ethereum (include the 18 zeros). This transaction will 
     * go through only if another party agrees to buy it for that much from you.
     * 
     * Note: A ticket owner can only sell one ticket at a time for now.
     */
     function resellTicketFor(uint256 price) {
         require(price != 0);
         require(balanceOf[msg.sender] >= 1);
         
         resellerToPrice[msg.sender] = price;
         
         // The contract holds on to the token to make sure the reseller cannot transfer this token after posting
         transferFrom(msg.sender, owner, 1);
     }
     
     function cancelResellingTicket() {
         require(resellerToPrice[msg.sender] != 0);
         
         resellerToPrice[msg.sender] = 0;
         transferFrom(owner, msg.sender, 1);
     }
     
     
    /**
     * Consumer action.
     * 
     * Buy a ticket from the specified address (that is selling) for the specified amount in ethereum.
     * (include the 18 zeros).
     * 
     * This assumes that the reseller has already called resellTicketFor and that the buyer
     * has transfered the correct amount of etherem to the contract to buy the ticket.
     */
     function buyResoldTicket(address ticketOwner, uint256 price) {
         require(price != 0);
         require(resellerToPrice[ticketOwner] == price);
         require(buyerToAmount[msg.sender] >= price);
         
         transferFrom(owner, msg.sender, 1);
         ticketOwner.transfer(price);
         
         // Reset values
         resellerToPrice[ticketOwner] = 0;
         buyerToAmount[msg.sender] -= price; 
     }
     
      /**
       * As a buyer of resold tickets, if you have transfered money into the system to 
       * buy a resold ticket, you can call this function to get your ether back. 
       * 
       * Note: This assumes that you have transfered at least some money into the system.
       */
     function cancelBuyResoldTicketEther() {
         require(buyerToAmount[msg.sender] != 0);
         
         msg.sender.transfer(buyerToAmount[msg.sender]);
         buyerToAmount[msg.sender] = 0;
     }
     
    
    
     /**
      * Checks whether a byte array equals the given integer. Used for 
      * comparisons with msg.data
      */
    function equal(uint a, bytes data) constant returns (bool) {
        uint x = 0;
        for (uint i = 0; i < 32; i++) {
            uint b = uint(data[35 - i]);
            x += b * 256**i;
        }
        return a == x;
    }
    
     /** Consumer action
      * 
      * Allows users to send ethereum to this address as a bid on a ticket. 
      * Transfers it to the owner.
      * Then transfers the appropriate amount of tokens from the owner to the
      * sender.
      */ 
    function() payable {
        // This user is placing a bid
        
        if (equal(4660, msg.data)) {
            // 4660 is hex for 0x1234
            // This is a consumer trying to buy a second hand ticket
            buyerToAmount[msg.sender] += msg.value;
        }
        else {
            // This is a consumer trying to buy a ticket from the primary seller 
            
            // Make sure this bid is higher. If not return money
            if (msg.value <= maxBid) {
                msg.sender.transfer(msg.value);
            }
            
            // Send back ether to old highest bidder
            if (maxBidder != 0x0) {
                maxBidder.transfer(maxBid);
            }
            
            // Set new highest bidder
            maxBid = msg.value;
            maxBidder = msg.sender;
        }
    }
    
}
