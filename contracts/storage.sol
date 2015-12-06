import "lookup.sol";
import "accountProviderBase.sol";

contract Storage {
  Lookup lookup;

  address owner;

  modifier owneronly { if (msg.sender == owner) _ }

  function setOwner(address addr) owneronly {
    owner = addr;
  }

  function Storage() {
    owner = msg.sender;
  }

  function setLookup(address addr) owneronly {
    lookup = Lookup(addr);
  }

  struct Account {
    bool verified;
    uint8 accountProvider;
    string userId;
    bytes32 ipfsProof;
    uint24 score; // fits 0..1000000 (where 0 means no score yet, while >1 is a score)
  }

  struct Person {
    bytes32 id;
    address[] ethaddrs; // not yet populated
    mapping (uint8 => Account) accounts;
    mapping (bytes32 => bytes) extraDataBytes; // unverified data
    mapping (bytes32 => uint) extraDataUnit; // unverified data
  }

  // map unique id to person
  mapping (bytes32 => Person) public persons;

  // quick lookup index based on ethereum addresses
  mapping (address => bytes32) public addressToPersonId;

  // well, this can be removed if we assume id != 0
  mapping (address => bool) public addressPresent;

  function bindEthereumAddress(address addr, bytes32 id) internal {
    addressPresent[addr] = true;
    addressToPersonId[addr] = id;
    // FIXME: amend person.ethaddrs too
  }

  function unbindEthereumAddress(address addr, bytes32 id) internal {
    delete addressPresent[addr];
    delete addressToPersonId[addr];
    // FIXME: amend person.ethaddress too
  }

  // For methods which needs to come from a registered user
  modifier useronly {
    if (!addressPresent[msg.sender])
      throw;
    _
  }

  // Register a new user
  function register() returns (bytes32 id) {
    // is it already set up?
    if (addressPresent[msg.sender])
      throw;

    // create new record
    Person memory person;
    id = person.id = sha3(msg.sender, block.number);

    // set up mappings
    persons[id] = person;
    bindEthereumAddress(msg.sender, id);
  }

  // add new ethereum address
  function linkAddress(address addr) useronly {
    if (addressPresent[addr])
      throw; // already linked

    bindEthereumAddress(addr, addressToPersonId[msg.sender]);
  }

  // remove ethereum link
  function unlinkAddress(address addr) useronly {
    bytes32 id = addressToPersonId[addr];

    // does the userid of `addr` belongs to the sender?
    if (addressToPersonId[msg.sender] != id)
      throw;

    // FIXME: check if its the only address linked and reject if it is

    unbindEthereumAddress(addr, id);
  }

  // Start the verification process, call up the actual verifier and expect an answer in `updateAccount`
  function linkAccount(uint8 accountProvider, string userId, string proofLocation) useronly {
    bytes32 id = addressToPersonId[msg.sender];
    Person person = persons[id];

    // Prepare new account for the user, set it to non-verified
    Account memory account;
    account.verified = false;
    account.accountProvider = accountProvider;
    account.userId = userId;
    person.accounts[accountProvider] = account;

    accountProviderBase(lookup.accountProviders(accountProvider)).verify(id, userId, proofLocation);
  }

  // Internal function, only accountProviders can call this
  function updateAccount(uint8 accountProvider, bytes32 id, bool result, bytes32 ipfsProof) {
    if (msg.sender != lookup.accountProviders(accountProvider))
      throw;

    Person person = persons[id];
    // This ID is not in the system yet
    if (person.id != id)
      throw; // FIXME: throw?

    // Update the account with the verification result
    Account account = person.accounts[accountProvider];
    // This verification wasn't initiated from Storage
    if (account.accountProvider == 0)
      throw; // FIXME: throw?

    account.verified = result;
    account.ipfsProof = ipfsProof;
    person.accounts[accountProvider] = account; // FIXME: is this needed? I don't think its needed as above is not memory? I think it's already done automatically being a reference
  }

  function getScore(uint8 accountProvider, bytes32 id) public returns (uint24) {
    Person person = persons[id];
    // This ID is not in the system yet
    if (person.id != id)
      throw; // FIXME: throw?

    // Update the account with the verification result
    Account account = person.accounts[accountProvider];
    // This verification wasn't initiated from Storage
    if (account.accountProvider == 0)
      throw; // FIXME: throw?

    return account.score;
  }

  // Internal function, only accountProviders can call this. It updates the score
  function updateScore(uint8 accountProvider, bytes32 id, uint24 score) {
    if (msg.sender != lookup.accountProviders(accountProvider))
      throw;

    Person person = persons[id];
    // This ID is not in the system yet
    if (person.id != id)
      throw; // FIXME: throw?

    Account account = person.accounts[accountProvider];
    // The account isn't created yet
    if (account.accountProvider == 0)
      throw; // FIXME: throw?

    account.score = score;
    person.accounts[accountProvider] = account; // FIXME: is this needed? I don't think its needed as above is not memory? I think it's already done automatically being a reference
  }

  // Initiate recalculation of a score
  function refreshScore(uint8 accountProvider, bytes32 id) {
    Person person = persons[id];
    // This ID is not in the system yet
    if (person.id != id)
      throw; // FIXME: throw?

    Account account = person.accounts[accountProvider];
    // The account isn't created yet
    if (account.accountProvider == 0)
      throw; // FIXME: throw?

    accountProviderBase(lookup.accountProviders(accountProvider)).score(id, account.userId);
  }
}
