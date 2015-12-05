// Example:
// html(https://twitter.com/oraclizeit/status/671316655893561344).xpath(//*[contains(@class, 'tweet-text')]/text())

import "accountProvider.sol";

contract Twitter is accountProvider {
  // map the expected identifier to an oraclize identifier
  mapping (bytes32 => bytes32) expectedId;

  function __callback(bytes32 myid, string result) {
    if (msg.sender != oraclize_cbAddress()) throw;

    // this is basically a bytes32 to hexstring piece
    string memory expected = string(addressToBytes(address(expectedId[myid])));
    if (strCompare(expected, result) == 0) {
      // matches, call back storage and let it know that expectedId has verified twitter
    }
  }

  function verify(bytes32 id, string tweetUrl) {
  //    bytes32 oraclizeId = oraclize_query("html(https://twitter.com/oraclizeit/status/671316655893561344).xpath(//*[contains(@class, 'tweet-text')]/text())");

    // build up the request string
    string memory head = "html(";
    bytes memory _head = bytes(head);
    string memory tail = ").xpath(//*[contains(@class, 'tweet-text')]/text())";
    bytes memory _tail = bytes(tail);

    bytes memory _tweetUrl = bytes(tweetUrl);

    string memory query = new string(_head.length + _tail.length + _tweetUrl.length + 2);
    bytes memory _query = bytes(query);
    uint i = 0;
    for (uint j = 0; j < _head.length; j++)
      _query[i++] = _head[j];
    for (j = 0; j < _tweetUrl.length; j++)
      _query[i++] = _tweetUrl[j];
    for (j = 0; j < _tail.length; j++)
      _query[i++] = _tail[j];
    _query[i++] = 0;

    expectedId[id] = oraclize_query("URL", query);
  }
}
