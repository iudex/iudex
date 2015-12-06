import "oraclizeAPI.sol";
import "std.sol";

contract accountProviderBase is abstract, usingOraclize {
  function nibbleToChar(uint nibble) internal returns (uint ret) {
    if (nibble > 9)
      return nibble + 87; // nibble + 'a'- 10
    else
      return nibble + 48; // '0'
  }

  // basically this is an int to hexstring function, but limited to 160 bits
  // FIXME: could be much simpler if we have a simple way of converting bytes32 to bytes or string
  function addressToBytes(address _address) internal returns (bytes) {
    uint160 tmp = uint160(_address);

    // 40 bytes of space, but actually uses 64 bytes
    string memory holder = "                                              ";
    bytes memory ret = bytes(holder);

    // NOTE: this is written in an expensive way, as out-of-order array access
    //       is not supported yet, e.g. we cannot go in reverse easily
    //       (or maybe it is a bug: https://github.com/ethereum/solidity/issues/212)
    uint j = 0;
    for (uint i = 0; i < 20; i++) {
      uint _tmp = tmp / (2 ** (8*(19-i))); // shr(tmp, 8*(19-i))
      uint nb1 = (_tmp / 0x10) & 0x0f;     // shr(tmp, 8) & 0x0f
      uint nb2 = _tmp & 0x0f;
      ret[j++] = byte(nibbleToChar(nb1));
      ret[j++] = byte(nibbleToChar(nb2));
    }

    return ret;
  }

  function b32ToBytes(bytes32 input) internal returns (bytes) {
    uint tmp = uint(input);

    string memory holder = new string(64);
    bytes memory ret = bytes(holder);

    // NOTE: this is written in an expensive way, as out-of-order array access
    //       is not supported yet, e.g. we cannot go in reverse easily
    //       (or maybe it is a bug: https://github.com/ethereum/solidity/issues/212)
    uint j = 0;
    for (uint i = 0; i < 32; i++) {
      uint _tmp = tmp / (2 ** (8*(31-i))); // shr(tmp, 8*(19-i))
      uint nb1 = (_tmp / 0x10) & 0x0f;     // shr(tmp, 8) & 0x0f
      uint nb2 = _tmp & 0x0f;
      ret[j++] = byte(nibbleToChar(nb1));
      ret[j++] = byte(nibbleToChar(nb2));
    }

    return ret;
  }

  function iudexIdToString(bytes32 id) internal returns (string) {
    return string(b32ToBytes(id));
  }

  // To be implemented by the provider
  function verify(bytes32 id, string userId, string proofLocation);
  function score(bytes32 id, string userId);
}
