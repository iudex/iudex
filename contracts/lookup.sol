contract Lookup {
  address owner;
  modifier owneronly { if (msg.sender == owner) _ }
  function setOwner(address _owner) owneronly {
    owner = _owner;
  }

  function Lookup() {
    owner = msg.sender;
  }

  address public storage;
  function setStorage(address addr) owneronly {
    storage = addr;
  }

  address public twitter;
  function setTwitter(address addr) owneronly {
    twitter = addr;
  }
}
