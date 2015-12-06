# Iudex

Iudex is a smart contract based reputation system. As a user, you are able to verify
your the ownership of accounts of different services (such as your Twitter,
Facebook and Github account) as well as link one or more Ethereum addresses. In the
future it will also support verifying ownership of Bitcoin addresses.

Iudex also includes a scoring system for each of these accounts, calculating how
reputable you are on each of them. Additionally it provides a combined score across
all your linked accounts.

Both the list of verified accounts and the scores can be queried by the public and
used in various way.

The verification and scoring processes are elected based on voting by the public.
Therefore new ways to calculate reputation can replace current ones, if the public
deems them more appropriate or accurate.

### Verification process

Before verification can proceed, a user has to create a new Iudex account, which
at a start will not have anything linked, apart of the Ethereum address used to
register.

The verification process is unique to each of the services, but usually it follows
these steps:
- the registered user of Iudex receives a unique code to publish
- the user publishes this code on the given services (e.g. posts a tweet with it)
- this proof location (e.g. the url of the exact tweet) is then submitted
  to Iudex along with the username
- Iudex will connect to this URL via Oraclize.it and will verify if the code
  matches

### Scoring process

Scoring can only be done with verified accounts. Each of these accounts have
different ways of retrieving user data (such as number of posts, number of followers,
etc) and different ways of creating a score from that.

### Example use case: BTC-ETH escrow

As an example we have included an escrow contract for selling Bitcoins for Ethers.

The reputation score of the seller is used to determine how many confirmations are
needed at a minimum after receiving the Bitcoins and before releasing the Ethers.


## Architecture

The core of the architecture consists of:
- Central storage (CS)
- Verification providers (VP)
- Score providers (SP)

Both *VP* and *SP* are using *CS* to store the results of their operation.

Each of the *VP* and *SP* are selected based on voting (to be implemented).

There are also helpers to manage the address lookups and the voting process.

Important to note, that the *CS* is not keeping a history at all, it only
stores the latest data. The Ethereum blockchain itself can be used to retrieve
the history of changes (e.g. storage changes in the *CS* contract).


## Data stored

- Unique identifiers (this is a 256bit identifier created upon registering)
- One or more Ethereum addresses
- For each of the verified accounts:
  - Username
  - Proof of verification (IPFS key for downloaded web data, see Oraclize.it)
  - Whether verification was successful or not
  - The current reputation score
- Various length of unverified extra data (can hold either *bytes* or *uint*,
  addressed by a *bytes32* key)


## API

### Lookup

The lookup contract stores the address of Storage as well the addresses of
the verification and scoring algorithms.

The public methods are:
- *addStorage()* - retrieve the address
- *setStorage(address)* - set a new address
- *accountProviders(type)* - retrieve the address for a provider
- *setAccountProviders(type, address)* - set a new address for a provider

The types include:
- 1 for Twitter
- 2 for Facebook
- 3 for Github

### Storage

The storage contract stores all the relevant information about a given user.
At the moment it also handles the linking of Ethereum addresses and other accounts.

The public methods are:
- *register()* - register a new account linked to the sender's Ethereum address
- *addressToPersonId(address addr)* - retrieve a user identifier for an address
- *addressPresent(address addr)* - quick check to see if an Ethereum adress is
  linked
- *linkAddress(address addr)* - associate a new Ethereum address
- *unlinkAddress(address addr)* - remove a currently associated Ethereum address
- *linkAccount(uint8 accountProvider, string userId, string proofLocation)* -
  initiate the setup of a new linked account
- *getScore(uint8 accountProvider, bytes32 id)* - get a score for a given user
  and account type
- *refreshScore(uint8 accountProvider, bytes32 id)* - ask for a new score to be
  calculated for a given user and account type

The private methods are:
- *updateAccount(uint8 accountProvider, bytes32 id, bool result, bytes32 ipfsProof)* -
  used by account providers to update Storage with the result of the verifiaciton
- *updateScore(uint8 accountProvider, bytes32 id, uint24 score)* - used by score
  providers to update Storage with a new score


### Linking new account providers

Implementing a new provider couldn't be much simpler. First allocate a new
*accountProvider* type by adding it to both *lookup* and *accountProviderBase*.

Then just create a new provider class with *accountProviderBase* as the parent.

Only two methods need to be supported:
- *verify(bytes32 id, string userId, string proofLocation)*
- *score(bytes32 id, string userId)*

If you need to use an oracle to validate the account, check out the twitter
implementation for an example on how to use *Oraclize.it*.


### Integration as a contract

As a contract author you are encouraged to use our integration piece
called *iudexAPI*.

This lists all the publicly available methods as well as gives you a few
handy methods to retrieve a reputation score:
- *getIudexScoreAll(address lookupAddr, bytes32 userId)* - to get a score for a user id
- *getIudexScoreAll(address lookupAddr, address addr)* - to get a score based on an Ethereum address


## Authors

Iudex was entirely created during the hack.ether.camp online hackathon by:
- Alex Beregszaszi [twitter](@alexberegszaszi) [github](@axic)
- Thomas Bertani [twitter](@ThomasBertani) [github](@bertani)

The live IDE is/was available at http://iudex.on.ether.camp.
