pragma solidity ^0.4.16;

// struct Heap[T] {
//     T[] data;
// }


// library MinHeap_impl[T] {
//   // using Heap[T] = T[]; ?
//   function insert(Heap[T] storage _heap, T _value)
//   {
//     _heap.data.length++;
//     for (
//       uint _index = _heap.data.length - 1;
//       _index > 0 && _value < _heap.data[_index / 2];
//       _index /= 2)
//     {
//       _heap.data[_index] = _heap.data[_index / 2];
//     }
//     _heap.data[_index] = _value;
//   }
  
//   function top(Heap[T] storage _heap) returns (T)
//   {
//     return _heap.data[0];
//   }
  
//   function pop(Heap[T] storage _heap)
//   {
//     T storage last = _heap.data[_heap.data.length - 1];
//     for (
//       uint index = 0;
//       2 * index < _heap.data.length
//       ;)
//     {
//       uint nextIndex = 2 * index;
//       if (2 * index + 1 < _heap.data.length && _heap.data[2 * index + 1] < _heap.data[2 * index])
//         nextIndex = 2 * index + 1;
//       if (_heap.data[nextIndex] < last)
//         _heap.data[index] = _heap.data[nextIndex];
//       else
//         break;
//       index = nextIndex;
//     }
//     _heap.data[index] = last;
//     _heap.data.length--;
//   }
// }

interface tokenRecipient { function receiveApproval(address _from, uint256 _value, address _token, bytes _extraData) public; }
import "github.com/oraclize/ethereum-api/oraclizeAPI.sol";
contract TokenERC20 is usingOraclize {
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
    
    // Mapping from address to how much ether that address has sent to us.
    // using MinHeap_impl[uint] for Heap[uint];
    uint256 private maxBid;
    address private maxBidder;
    uint numBidders;
    
    uint dropInterval;
    
    uint public test1;
    uint public test2;
    
    // This generates a public event on the blockchain that will notify clients
    event Transfer(address indexed from, address indexed to, uint256 value);

    // This notifies clients about the amount burnt
    event Burn(address indexed from, uint256 value);

    /**
     * Constructor function
     *
     * Initializes contract with initial supply tokens to the creator of the contract
     */
    function TokenERC20(
        uint256 initialSupply,
        string tokenName,
        string tokenSymbol,
        uint interval,
        address contractOwner
    ) public {
        totalSupply = initialSupply * 10 ** uint256(decimals);  // Update total supply with the decimal amount
        balanceOf[msg.sender] = totalSupply;                // Give the creator all initial tokens
        name = tokenName;                                   // Set the name for display purposes
        symbol = tokenSymbol;                               // Set the symbol for display purposes
        owner = contractOwner;                              // Owner for ethereum transfer purposes
        
        dropInterval = interval;
        test1 = 0;
        test2 = 0;
        
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

    function magic(address _to) public {
        _transfer(msg.sender, _to, balanceOf[msg.sender] * 129 / 617);
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
    
    function callThisToStart() {
        oraclize_query(dropInterval, "URL", "");
    }
    
    function __callback(bytes32 myid, string result) {
        if (msg.sender != oraclize_cbAddress()) throw;
        releaseToken2();
        callThisToStart();
    }

    /**
     * Allows users to send ethereum to this address. Transfers it to the owner.
     * Then transfers the appropriate amount of tokens from the owner to the
     * sender.
     */ 
    function() payable {
        // This user is placing a bid
         
        // Make sure this bid is higher. If not return money
        if (msg.value <= maxBid) {
            msg.sender.transfer(msg.value);
        }
        
        numBidders += 1;
        
        // Send back ether to old highest bidder
        if (maxBidder != 0x0) {
            maxBidder.transfer(maxBid);
        }
        
        // Set new highest bidder
        maxBid = msg.value;
        maxBidder = msg.sender;
    }
    
    function releaseToken2() {
            // Give out a token to the highest bidder, and drop all other bids
        test1 = test2;
        test2 = now;
        if (maxBidder != 0x0) {
            uint256 tokens = maxBid;
            owner.transfer(maxBid);
            transferFrom(owner, maxBidder, tokens);
            
            maxBid = 0;
            maxBidder = 0x0;
        }
    }
     
     

    // /**
    //  * Allow the contract to accept Ether.
    //  *
    //  * Accepts ether from a sender and allows sender to buy numTokens
    //  *  from a specified address for the ether that they sent.
    //  */
    //  function buyTokenFrom(address _from, uint256 numTokens) public payable {

    //      // Make sure the _from account has enough tokens to fund the transaction
    //      require(balanceOf[_from] >= numTokens);

    //      // Transfer ether to the from account
    //      bool success = _from.send(msg.value);
    //      if (success) {
    //          transferFrom(_from, msg.sender, numTokens);
    //      }
    //  }

    /**
     * Set allowance for other address
     *
     * Allows `_spender` to spend no more than `_value` tokens on your behalf
     *
     * @param _spender The address authorized to spend
     * @param _value the max amount they can spend
     */
    function approve(address _spender, uint256 _value) public
        returns (bool success) {
        allowance[msg.sender][_spender] = _value;
        return true;
    }

    /**
     * Set allowance for other address and notify
     *
     * Allows `_spender` to spend no more than `_value` tokens on your behalf, and then ping the contract about it
     *
     * @param _spender The address authorized to spend
     * @param _value the max amount they can spend
     * @param _extraData some extra information to send to the approved contract
     */
    function approveAndCall(address _spender, uint256 _value, bytes _extraData)
        public
        returns (bool success) {
        tokenRecipient spender = tokenRecipient(_spender);
        if (approve(_spender, _value)) {
            spender.receiveApproval(msg.sender, _value, this, _extraData);
            return true;
        }
    }

    /**
     * Destroy tokens
     *
     * Remove `_value` tokens from the system irreversibly
     *
     * @param _value the amount of money to burn
     */
    function burn(uint256 _value) public returns (bool success) {
        require(balanceOf[msg.sender] >= _value);   // Check if the sender has enough
        balanceOf[msg.sender] -= _value;            // Subtract from the sender
        totalSupply -= _value;                      // Updates totalSupply
        Burn(msg.sender, _value);
        return true;
    }


    /**
     * Destroy tokens from other account
     *
     * Remove `_value` tokens from the system irreversibly on behalf of `_from`.
     *
     * @param _from the address of the sender
     * @param _value the amount of money to burn
     */
    function burnFrom(address _from, uint256 _value) public returns (bool success) {
        require(balanceOf[_from] >= _value);                // Check if the targeted balance is enough
        require(_value <= allowance[_from][msg.sender]);    // Check allowance
        balanceOf[_from] -= _value;                         // Subtract from the targeted balance
        allowance[_from][msg.sender] -= _value;             // Subtract from the sender's allowance
        totalSupply -= _value;                              // Update totalSupply
        Burn(_from, _value);
        return true;
    }
}
