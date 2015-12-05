contract Storage {
  uint8 constant ACC_TWITTER = 0;
  uint8 constant ACC_FACEBOOK = 1;
  uint8 constant ACC_LINKEDIN = 2;

  struct Account {
    bool verified;
    uint8 provider;
    string userid;
    uint24 score; // fits 0..1000000 (where 0 means no score yet, while >1 is a score)
  }

  struct Person {
    bytes32 id;
    address[] ethaddrs; // not yet populated
    mapping (uint8 => Account) accounts;
  }

  // map unique id to person
  mapping (bytes32 => Person) persons;

  // quick lookup index based on ethereum addresses
  mapping (address => bytes32) addressToPersonId;

  // well, this can be removed if we assume id != 0
  mapping (address => bool) addressPresent;

  function bindEthereumAddress(address addr, bytes32 id) internal {
    addressPresent[addr] = true;
    addressToPersonId[addr] = id;
    // FIXME: amend person.ethaddrs too
  }

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
  function linkAddress(address addr) {
    if (!addressPresent[msg.sender])
      throw;

    if (addressPresent[addr])
      throw; // already linked

    bindEthereumAddress(addr, addressToPersonId[msg.sender]);
  }

  // remove ethereum link
  function unlinkAddress() {

  }

  function linkAccount(uint8 provider, string userid) {
    if (!addressPresent[msg.sender])
      throw;

    bytes32 id = addressToPersonId[msg.sender];
    Person person = persons[id];

    // call in "twitter" contract? or keep all of them here for the moment?
  }
}
