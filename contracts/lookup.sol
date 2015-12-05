//
// The contract to store addresses of others, including the main storage and verifiers.
//

contract Lookup {
  address owner;

  modifier owneronly { if (msg.sender == owner) _ }

  function setOwner(address addr) owneronly {
    owner = addr;
  }

  function Lookup() {
    owner = msg.sender;
  }

  address public addrStorage;
  function setStorage(address addr) owneronly {
    addrStorage = addr;
  }

  uint8 public accountProvider_TWITTER = 0;
  uint8 public accountProvider_FACEBOOK = 1;
  uint8 public accountProvider_LINKEDIN = 2;

  mapping(uint8 => address) public accountProviders;
  function setAccountProvider(uint8 accountProvider, address addr) owneronly {
    accountProviders[accountProvider] = addr;
  }
}
