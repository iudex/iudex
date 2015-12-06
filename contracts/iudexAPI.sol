// Public API for Iudex

contract Iudex is abstract {
  uint8 public accountProvider_ALL = 0; // I think this should COMBINED, WEIGHTED, or something but not ALL
  uint8 public accountProvider_TWITTER = 1;
  uint8 public accountProvider_FACEBOOK = 2;
  uint8 public accountProvider_GITHUB = 3;

  uint8 public extraData_BITCOIN = 0;

  //mapping (address => bytes32) public addressToPersonId;
  function addressToPersonId(address addr) returns (bytes32);
  function register() returns (bytes32);
  function linkAddress(address addr);
  function unlinkAddress(address addr);
  function linkAccount(uint8 accountProvider, string userId, string proofLocation);
  function getScore(uint accountProvider, bytes32 id) public returns (uint);
  function refreshScore(uint8 accountProvider, bytes32 id);
}

contract IudexLookupI is abstract {
  address public addrStorage;
}

// FIXME: optimise to store Iudex instance variable
contract usingIudex is abstract {
  // Get Iudex contract
  function getIudex(address lookupAddr) internal returns (Iudex) {
    return Iudex(IudexLookupI(lookupAddr).addrStorage());
  }

  // Get combined score based on Iudex identifier
  function getIudexScoreAll(address lookupAddr, bytes32 userId) internal returns (uint) {
    Iudex iudex = getIudex(lookupAddr);
    return iudex.getScore(iudex.accountProvider_ALL(), userId);
  }

  // Get combined score based on Ethereum address
  function getIudexScoreAll(address lookupAddr, address addr) internal returns (uint) {
    Iudex iudex = getIudex(lookupAddr);
    return getIudexScoreAll(lookupAddr, iudex.addressToPersonId(addr));
  }
}
