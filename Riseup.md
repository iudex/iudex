Intro
=====

Use cases:
    1) A user building a reputation index
    2) A service using this reputation data


Similar services
================

Keybase.io supports: (example: https://keybase.io/mgwsoftware, https://keybase.io/cjb )
    - nickname / username
    - "real name"
    - pgp pubkey (in ascii + fingerprint)
    - github [via gist confirmation] [ https://gist.github.com/cjb/10410941 ]
    - twitter [via tweet confirmation] [ https://twitter.com/cjbprime/status/648316716708167680 ]
    - bitcoin address
    - website(s) [via DNS record confirmation or file placement]
    - photo / avatar
    - news.ycombinator.com [ https://news.ycombinator.com/user?id=cjbprime ]
    - reddit [via post] [ https://www.reddit.com/r/KeybaseProofs/comments/3nei9i/my_keybase_proof_redditcjbprime_keybasecjb/ ]
    - devices?? https://keybase.io/cjb/devices
("sigchains" as a history chain: https://keybase.io/docs/sigchain )

Onename.io supports: (example: https://onename.com/gavin )
    - email/username
    - location
    - text description
    - twitter
    - facebook
    - github
    - bitcoin address (ownership not verified)
    - website (ownership not verified)
    - pgp pubkey
    - photo/avtar from twitter

Bitrated supports: (example: https://www.bitrated.com/derek )
    - email
    - text description
    - tags
    - SIN: https://en.bitcoin.it/wiki/Identity_protocol_v1
    - others vouching for a user (!)
    - other reviewing the user
    - #bitcoin-otc
    - localbitcoins
    - coinbase
    - bitcointalk
    - twitter
    - reddit
    - facebook
    - hacker news
    - google+
    - linkedin
    - github
    - stackexchange
    - angelist
    - paypal
    - fiverr
    - airbnb


Easily verifiable sources with Oraclize:
    - ethereum address
    - twitter (public tweet)
    - facebook (public post) [ https://www.facebook.com/yann.girard.1238/posts/1808311066062433?pnref=story ]
    - github (gist)
    - reddit (post on subreddit)
    - linkedin (you could add as project/organization "Iudex" + your linked address as part of the description)
    - bitrated/onebase/
    - google?
    - youtube?


Iudex
=====

Decisions:
    - updating data will update in-place (e.g. we dont keep history in the contract)
    - changes history is based purely on blockchain history
    - history won't be shown in PoC
    - if we have enough time as a last milestone we'll support validated bitcoin addresses (checking via btcrelay and ecrecover)
    - secure linking/data processing and scoring are two separate conceptual parts; there can be multiple algorithms for scoring of the same source (e.g. twitter)


Process:
    1) user creates a new iudex "account" via a transaction, gets a unique id assigned
    2) posts that id on various mediums
    3) initiates a "verification" for them via a transaction (and pays oraclize fees)
    4) each verification triggers scoreUpdate
    5) anyone can transact scoreUpdate (and pay the fees associated with it)
    6) anyone can call data retrieval

Contract model 1 (bulky storage):
    1) storage contract [SC] (has linked account idenfitiers)
    2) verification contract [VC] (calls oraclize and stores the result in the SC)
    3) scoring algorithm [SA] (uses data from SA, stores TYPE (e.g. twitter) and SCORE (the value) in itself) - there is a "special" algorithm with TYPE=ALL
    4) scoring proxy [SP] (has the currently top voted scoring algorithms for each TYPE selected)
    5) SA voting [SV] (-lets think about this-)
    6)
    7) lookup contract [LC] (stores the address of SC, VC, SP, SV?)


Contract model 2 (lean storage):
    1) storage contract [SC] (has linked account identifiers, scores, timestamps for last score updates)
    2) vertification contract [VC] (calls oraclize and stores the result in the SC)
    3) scoring algorithm [SA]
    4) .. voting, lookup, etc.


Reputation data should consists of:
    - identifier (first ethereum
    - "score"/"index" (yep I like this word)
    - linked accounts along with their respective scores
        a) twitter username (include verified tag)
        b) facebook userid/username
        c) linkedin username
        d) github username
        e) reddit
        f) onename/keybase/bitrated - milestone 2/3
    - website? (place file in a given location, e.g. /iudex.key)
    - non trusted data:
        - email address
        - nickname/username
        - "real name"
        - "description"
        - "location"
        - pgp key
    - ethereum address(es)
    - date of last update


Actual storage data:
    a) Identifier
    b) Twitter/Facebook/Linkedin/Reddit/Github: username, ipfs hash, timestamp
    d) Array of ethereum addresses
    e) "hashmap" of non-trusted data (e.g. a mapping + another lookup, when we get there)

        Milestone 1: one "random text field"

    f) Scores: twitter, facebook, linkedin, reddit, github, <overall>



Default algo for now - needs to be normalized somehow (range of 1 to 1.000.000):
    - Twitter: (followers-following)+0.25*likes
    - Facebook: friends, ?
    - Github: Contributions in the last year? followers? forks?
    - Reddit: link karma, comment karma
    - LinkedIn: connections, recommendations, skills votes



  Any party should be able to call an "update" method to get fresh results back. Being it expensive the update is optional.




API v1
======
worth reading: https://www.bitrated.com/docs
======


register() returns (bytes32)

    - creates ID

    sha3(msg.sender, block.number)

    - stores `msg.sender` in `ethereum_addresses`

    - returns ID


linkAddress(address)

    - check if `address` belongs to any user

    - store `address` in `ethereum_addresses`


unlinkAddress(address)

    - check if `address` belongs to any user

    - remove `address` from `ethereum_addresses` unless it is the only address


linkAccount(TWITTER, "@Username")
unlinkAccount?

updateScores(ALL/TWITTER/..)
updateScores(address, ALL/TWITTER/..)
updateScores(uint, string, ALL/TWITTER/..)


getScores() returns (..)
getScores(address) returns (..)
getScores(uint, string) returns (..) //getInfo(TWITTER, "@ThomasBertani")  = {'reputation_index': 99,}

getLinked() returns (..)
getLinked..

getReputationIndex() return (..)
getReputationIndex..
