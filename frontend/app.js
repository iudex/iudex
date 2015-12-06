var Web3 = require('web3');

// Connect to node; either Mist, supplied URL or the default on
function connectNode(url) {
  if (typeof web3 !== 'undefined') // Mist
    web3 = new Web3(web3.currentProvider);
  else {
    if (typeof url === 'undefined')
      url = "http://localhost:8080";
//      url = "http://localhost:8545";
    web3 = new Web3(new Web3.providers.HttpProvider(url));
  }

  web3.eth.defaultAccount = web3.eth.coinbase;

  loadContracts();
}

var storageContract;
// accountProvider constants
// FIXME: must be in sync with Iudex, alternatively query it from there here
var accountProvider_ALL = 0; // I think this should COMBINED, WEIGHTED, or something but not ALL
var accountProvider_TWITTER = 1;
var accountProvider_FACEBOOK = 2;
var accountProvider_GITHUB = 3;

function loadContracts() {
  // The ABIs
  var lookupAbi = [ { "constant": true, "inputs": [], "name": "accountProvider_FACEBOOK", "outputs": [ { "name": "", "type": "uint8" } ], "type": "function" }, { "constant": false, "inputs": [ { "name": "addr", "type": "address" } ], "name": "setOwner", "outputs": [], "type": "function" }, { "constant": false, "inputs": [ { "name": "accountProvider", "type": "uint8" }, { "name": "addr", "type": "address" } ], "name": "setAccountProvider", "outputs": [], "type": "function" }, { "constant": true, "inputs": [], "name": "accountProvider_ALL", "outputs": [ { "name": "", "type": "uint8" } ], "type": "function" }, { "constant": false, "inputs": [ { "name": "addr", "type": "address" } ], "name": "setStorage", "outputs": [], "type": "function" }, { "constant": true, "inputs": [], "name": "accountProvider_GITHUB", "outputs": [ { "name": "", "type": "uint8" } ], "type": "function" }, { "constant": true, "inputs": [ { "name": "", "type": "uint8" } ], "name": "accountProviders", "outputs": [ { "name": "", "type": "address" } ], "type": "function" }, { "constant": true, "inputs": [], "name": "addrStorage", "outputs": [ { "name": "", "type": "address" } ], "type": "function" }, { "constant": true, "inputs": [], "name": "accountProvider_TWITTER", "outputs": [ { "name": "", "type": "uint8" } ], "type": "function" }, { "inputs": [], "type": "constructor" } ];
  var storageAbi = [ { "constant": false, "inputs": [ { "name": "addr", "type": "address" } ], "name": "setOwner", "outputs": [], "type": "function" }, { "constant": false, "inputs": [], "name": "register", "outputs": [ { "name": "id", "type": "bytes32" } ], "type": "function" }, { "constant": false, "inputs": [ { "name": "accountProvider", "type": "uint8" }, { "name": "id", "type": "bytes32" }, { "name": "score", "type": "uint24" } ], "name": "updateScore", "outputs": [], "type": "function" }, { "constant": false, "inputs": [ { "name": "addr", "type": "address" } ], "name": "setLookup", "outputs": [], "type": "function" }, { "constant": true, "inputs": [ { "name": "", "type": "address" } ], "name": "addressPresent", "outputs": [ { "name": "", "type": "bool" } ], "type": "function" }, { "constant": true, "inputs": [ { "name": "", "type": "bytes32" } ], "name": "persons", "outputs": [ { "name": "id", "type": "bytes32" } ], "type": "function" }, { "constant": false, "inputs": [ { "name": "accountProvider", "type": "uint8" }, { "name": "id", "type": "bytes32" } ], "name": "refreshScore", "outputs": [], "type": "function" }, { "constant": false, "inputs": [ { "name": "addr", "type": "address" } ], "name": "unlinkAddress", "outputs": [], "type": "function" }, { "constant": false, "inputs": [ { "name": "accountProvider", "type": "uint8" }, { "name": "id", "type": "bytes32" }, { "name": "result", "type": "bool" }, { "name": "ipfsProof", "type": "bytes32" } ], "name": "updateAccount", "outputs": [], "type": "function" }, { "constant": false, "inputs": [ { "name": "addr", "type": "address" } ], "name": "linkAddress", "outputs": [], "type": "function" }, { "constant": false, "inputs": [ { "name": "accountProvider", "type": "uint8" }, { "name": "userId", "type": "string" }, { "name": "proofLocation", "type": "string" } ], "name": "linkAccount", "outputs": [], "type": "function" }, { "constant": true, "inputs": [ { "name": "", "type": "address" } ], "name": "addressToPersonId", "outputs": [ { "name": "", "type": "bytes32" } ], "type": "function" }, { "constant": false, "inputs": [ { "name": "accountProvider", "type": "uint8" }, { "name": "id", "type": "bytes32" } ], "name": "getScore", "outputs": [ { "name": "", "type": "uint24" } ], "type": "function" }, { "inputs": [], "type": "constructor" } ];

  // The lookup contract (the only pre-set address you need)
  var lookupAddr = "0x1801f6139ce165a121e403641f2f7809c7ffa8a8";

  // Retrieve storage address and set it up
  var lookupContract = web3.eth.contract(lookupAbi).at(lookupAddr);
  var storageAddr = lookupContract.addrStorage();
  storageContract = web3.eth.contract(storageAbi).at(storageAddr);

  accountProvider_ALL = lookupContract.accountProvider_ALL();
  accountProvider_TWITTER = lookupContract.accountProvider_TWITTER();
  accountProvider_FACEBOOK = lookupContract.accountProvider_FACEBOOK();
  accountProvider_GITHUB = lookupContract.accountProvider_GITHUB();
}


// Simple helpers for the HTML integration

function register() {
  storageContract.register();
}

function getUserId(addr) {
  return storageContract.addressToPersonId.call(addr);
}

function getScore(userId) {
  return storageContract.getScore.call(accountProvider_TWITTER, userId);
}

function linkTwitter(username, url) {
  storageContract.linkAccount(accountProvider_TWITTER, username, url, { gas: 300000 });
}

$(document).ready(function() {
  console.log("Setting up jquery hooks");

  $("#lookup").submit(function(event) {
    event.preventDefault();

    console.log("Getting user ID");

    var addr = $("#lookup_address");
    var userId = getUserId(addr);
    $("#lookup_result").text(userId);
  });

  $("#score").submit(function(event) {
    event.preventDefault();

    console.log("Getting score");

    var userId = $("#score_userId");
    var score = getScore(userId);
    $("#score_result").text(score);
  });

  $("#register").submit(function(event) {
    event.preventDefault();
  });

  $("#twitter").submit(function(event) {
    event.preventDefault();
  });

  console.log("Callbacks set up");
});

/*

// EXMAPLE USAGE

// Connect and load contrcats
connectNode();

// Register new user
//  function register() returns (bytes32);
storageContract.register();

// Retrieve user id (after tx was mined)
var iudexUserId = storageContract.addressToPersonId.call();
console.log(iudexUserId);

// Get score
//  function getScore(uint accountProvider, bytes32 id) public returns (uint);
var score = storageContract.getScore.call(accountProvider_TWITTER, iudexUserId);
console.log(score);

// Link account
//   function linkAccount(uint8 accountProvider, string userId, string proofLocation);
storageContract.linkAccount(accountProvider_TWITTER, "oraclizeit", "https://twitter.com/oraclizeit/status/671316655893561344", {gas: 300000});
*/
