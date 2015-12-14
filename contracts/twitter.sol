//
// This contract will validate that a twitter message url:
// 1) corresponds to a given username
// 2) containts an expected message (the user identifier)
//

import "accountProviderBase.sol";

contract Twitter is accountProviderBase {
  Lookup lookup;

  address owner;

  modifier owneronly { if (msg.sender == owner) _ }

  function setOwner(address addr) owneronly {
    owner = addr;
  }

  function Twitter() {
    owner = msg.sender;
  }

  function setLookup(address addr) owneronly {
    lookup = Lookup(addr);
  }

  // map the expected identifier to an oraclize identifier
  mapping (bytes32 => bytes32) expectedId;

  // true if verification, otherwise scoring
  mapping (bytes32 => bool) isVerification;

  // callback from oraclize with the result, let the storage contract know
  function __callback(bytes32 myid, string result, bytes proof) {
    if (msg.sender != oraclize_cbAddress()) throw;

    if (isVerification[myid])
      processVerification(myid, result);
    else
      processScore(myid, result);

    // clean up
    delete expectedId[myid];
    delete isVerification[myid];
  }

  function processScore(bytes32 myid, string result) internal {
    uint followers = parseInt(result);
    uint24 newScore = 1000000;
    if (followers / 10000 == 0)
      newScore = 100 * uint24(followers % 10000);

    Storage(lookup.addrStorage()).updateScore(lookup.accountProvider_TWITTER(), expectedId[myid], newScore);
  }

  // start the scoring process and call oraclize with the URL
  function score(bytes32 id, string userId) coupon("HackEtherCamp") {
    bytes memory _userId = bytes(userId);
    string memory head = "html(https://twitter.com/";
    bytes memory _head = bytes(head);
    string memory tail = ").xpath(//*[contains(@data-nav, 'followers')]/*[contains(@class, 'ProfileNav-value')]/text())";
    bytes memory _tail = bytes(tail);
    string memory query = new string(_head.length + _userId.length + _tail.length);
    bytes memory _query = bytes(query);
    uint i = 0;
    for (uint j = 0; j < _head.length; j++)
      _query[i++] = _head[j];
    for (j = 0; j < _userId.length; j++)
      _query[i++] = _userId[j];
    for (j = 0; j < _tail.length; j++)
      _query[i++] = _tail[j];
    oraclize_setProof(proofType_TLSNotary | proofStorage_IPFS);
    bytes32 oraclizeId = oraclize_query("URL", query);
    expectedId[oraclizeId] = id;
    isVerification[oraclizeId] = false;
  }

  function processVerification(bytes32 myid, string result) internal {
    // this is basically a bytes32 to hexstring piece
    string memory expected = iudexIdToString(expectedId[myid]);
    bool asExpected = indexOf(result, expected) > -1;
    Storage(lookup.addrStorage()).updateAccount(lookup.accountProvider_TWITTER(), expectedId[myid], asExpected, myid);
  }

  // ensure that the proofLocation corresponds to a twitter.com URL for the user `userId`
  function verifyUrl(string userId, string proofLocation) internal returns (bool){
    bytes memory _userId = bytes(userId);
    string memory twitterPrefix = "://twitter.com/";
    bytes memory _twitterPrefix = bytes(twitterPrefix);
    string memory urlHead = new string(_twitterPrefix.length + _userId.length + 1);
    bytes memory _urlHead = bytes(urlHead);
    uint i = 0;
    for (uint j = 0; j < _twitterPrefix.length; j++)
      _urlHead[i++] = _twitterPrefix[j];
    for (j = 0; j < _userId.length; j++)
      _urlHead[i++] = _userId[j];
    _urlHead[i++] = byte("/");

    if (indexOf(proofLocation, string(_urlHead)) == -1)
      return false;

    return true;
  }

  // start the verification process and call oraclize with the URL
  function verify(bytes32 id, string userId, string proofLocation) coupon("HackEtherCamp") {
  //    bytes32 oraclizeId = oraclize_query("html(https://twitter.com/oraclizeit/status/671316655893561344).xpath(//*[contains(@class, 'tweet-text')]/text())");

    // check that userId matches the username in proofLocation
    if (!verifyUrl(userId, proofLocation))
      throw;

    // build up the request string
    string memory head = "html(";
    bytes memory _head = bytes(head);
    string memory tail = ").xpath(//*[contains(@class, 'tweet-text')]/text())";
    bytes memory _tail = bytes(tail);

    bytes memory _tweetUrl = bytes(proofLocation);

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

    oraclize_setProof(proofType_TLSNotary | proofStorage_IPFS);
    bytes32 oraclizeId = oraclize_query("URL", query);
    expectedId[oraclizeId] = id;
    isVerification[oraclizeId] = true;
  }
}
