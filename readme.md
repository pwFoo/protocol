# Federated chat system with [E2EE][1] and low risk of [MITM attack][2]

## Problems

Existing chat platforms and protocols have some or all of the following
problems:

- lack of privacy of the conversation, partially caused by [E2EE][1]
  implementations.
- lack of privacy of the user profile and connections.
- unsolicited messages (spam and abuse).
- lack of data ownership and protection.
- complexity of usage for all non-centralised protocols to all non-technical
  users

Some of these problems are covered in more details in the proposed protocols on
which this chat system will be based on:

- [simplex messaging][6] - low level client-server protocol for asynchronous
  distributed unidirectional messaging.
- [graph-chat][8] - high level chat protocol for client applications that
  communicate via simplex messaging protocol.

Even though EU-wide GDPR legislation to ensure users' privacy and data
protection was adopted, the centralisation of the communication in a small
number of platforms makes resolving these problems quite difficult.

# Comparison with [P2P][9] messaging protocols

There are several P2P chat/messaging protocols and implementations that aim to
solve privacy and centralisation problem, but they have their own set of
problems that makes them less reliable than the proposed chat system design,
more complex to implement and analyse and more vulnerable to attacks.

1. [P2P][9] networks either have some centralised component, which makes them
   highly vulnerable, or, more commonly, use some variant of [DHT][10] to route
   messages/requests through the network. DHT implementations have complex
   designs that have to balance reliability, delivery guarantee and latency, and
   also have some other problems. The proposed chat system design has both
   higher delivery guarantee and low latency (the message is passed multiple
   times in parallel, through one node each time, using servers chosen by the
   recipient, while in P2P networks the message is passed through `O(log N)`
   nodes sequentially, using nodes chosen by the algorithm).
2. The proposed design, unlike most P2P networks, has no global identity of any
   form, even temporary.
3. P2P itself does not solve [MITM attack][2] problem, but most existing
   solutions do not use out-of-band messages for the initial key exchange. The
   proposed design uses out-of-band messages or, in some cases, pre-existing
   secure and trusted connections for the initial key exchange.
4. P2P implementations can be blocked by some Internet providers (like
   [BitTorrent][11]). The proposed design is transport agnostic - it can work
   over standard web protocols, and the servers can be deployed on the same
   domains as the existing public websites.
5. All known P2P networks are likely to be vulnerable to [Sybil attack][12],
   because each node is discoverable, and the network operates as a whole. Known
   measures to reduce the probability of the Sybil attack either require a
   vulnerable centralised component or expensive [proof of work][13]. The
   proposed design, on the opposite, has no server discoverability - servers are
   not connected, not known to each other and to all clients. The chat network
   is fragmented and operates as multiple isolated connections. It makes Sybil
   attack on the whole simplex messaging network impossible - even if some
   servers are compromised, other parts of the network can operate normally, and
   affected clients can always switch to using other servers without losing
   contacts or messages.
6. P2P networks are likely to be vulnerable to [DRDoS attack][14]. In the
   proposed design clients only relay traffic from known trusted connection and
   cannot be used to reflect and amplify the traffic in the whole network.

## Privacy requirements

- User profile is only visible to the profile connections, but not to the chat
  network
- User profile is not stored on the servers.
- Profile connections are not stored on the server.
- It should not be possible to construct the list of user connections by
  analysing server database or any logs.
- It should not be possible, other than by compromising the client, to send
  messages from another user profile.
- It should not be possible, other than by compromising all servers the user is
  connected to, to prevent message delivery to a user.
- All participants of the conversation should be able to:
  - prove that the received messages were actually sent by another party.
  - prove that the sent messages were received by another party.

## Chat scenarios

Any advanced chat system needs to support several main chat scenarios:

- direct messaging.
- group chat.
- broadcasts.

In addition to that, there are other important chat scenarios:

- [OTR messaging][3]
- multiple user devices sharing contacts and conversation histories.
- introductions

While it is not required to be supported in the v1 of the protocol, it is
important to have clarity on how all these scenarios can be supported in the
future.

## Chat system features

- No user identity known to system servers - no phone numbers, user names and no
  DNS are needed to identify the users to the system.
- Each user can be connected to multiple servers to ensure message delivery,
  even if some of the servers are compromised.
- Uses standard asymmetric cryptographic protocols, so that system users can
  create independent server and client implementations complying with the
  protocols.
- Open-source server implementations that can be easily deployed by any user
  with minimal technical expertise (e.g. on Heroku via web UI).
- Open-source client implementations so that system users can independently
  assess system security model.
- Only client applications store user profiles, contacts of other user profiles,
  messages; servers do NOT have access to any of this information and (unless
  compromised) do NOT store encrypted messages or any logs.
- Multiple client applications and devices can be used by each user profile to
  communicate and to share connections and message history - the devices are not
  known to the servers.
- Initial key exchange and establishing connections between user profiles is
  done by sharing QR code via any independent communication channel (or directly
  via screen and camera), system servers are NOT used for key exchange - to
  reduce risk of key substitution in [MITM attack][2]. QR code contains the
  connection-specific public key and other information needed to establish the
  connection.
- Connections between users can be established via shared trusted connections to
  simplify key exchange.
- Servers do NOT communicate with each other, they only communicate with client
  applications.
- Unique public key is used for each user profile connection in order to:
  - reduce the risk of attacker posing as user's connection
  - avoid exposing all user connections to the servers
- Unique public key is used to identify each connection participant to each
  server.
- Public keys used between connections are regularly rotated to prevent
  decryption of the full message history ([forward secrecy][4]) in case when
  some servers or middlemen preserve message history and the current key is
  compromised.
- Users can repeat key exchange using QR code and alternative channel at any
  point to increase communication security and trust.
- No single server in the system has visibility of all connections or messages
  of any user, as user profiles are identified by multiple rotating public keys,
  using separate key for each profile connection.
- User profile (meta-data of the user including non-unique name / handle and
  optional additional data, e.g. avatar and status) is stored in the client apps
  and is shared only with accepted user profile connections.

## System components

- simplex messaging servers
- graph-chat client applications (using simplex messaging protocol to
  communicate with the servers)

### Chat servers

Simplex messaging servers can be either available to all users or only to users
who have a valid URI to create connections (see [simplex messaging
protocol][6]).

### Chat client application

Graph-chat applications are installed by users on their devices.

Client apps should provide the following features:

- create and manage user profiles
- support multiple user profiles.
- share access to all or selected user profiles with other devices (optionally
  including existing connections and message histories).
- for each user profile:
  - generate and show QR code with connection-specific public key and other
    information that can be shown on the screen and/or sent via alternative
    channel.
  - read QR code (via the camera) to establish connection with another user.
  - receive and accept connection requests.
  - exchange user profiles once connection is accepted.
  - send messages to connected user profiles.
  - receive messages from connected user profile.
  - define the servers to use.
  - store history of all conversations encrypted using user client app key with
    passphrase (or some other device specific encryption method).

## System design

The chat system design is based on 2 protocols, each with the generic part,
describing protocol flow and logic, and implementation part, describing protocol
transports, data structures and algorithms.

1. [simplex messaging protocol][6] - a low level messaging protocol that defines
   establishing and using a simplex connection between chat participants on a
   single server. While this protocol is designed to support graph-chat client
   protocol (below), it can be used for other messaging scenarios, not limited
   to chats.
2. [graph-chat protocol][8] - a high level generic chat protocol for client
   applications (graph vertices) that communicate via simplex connections
   created using simplex messaging protocol. This protocol defines connection
   and message types and semantics for:
   - various chat elements (user profiles, direct chats, chat groups,
     broadcasts, etc.).
   - other communication scenarios - e.g. introduction, off-the-record chat,
     etc.
   - using multiple servers to ensure message delivery.
   - sharing user profiles, contacts and chats across multiple client devices.
   - changing cryptographic keys and servers used to send and receive messages
     using simplex messaging server protocol.
   - sending and receiving out-of-band messages between client applications
     using "visual code".
3. graph-chat client application protocol (TODO) - a high level specific chat
   protocol for client applications. This protocol specifies:
   - data structures for sending and receiving messages of all types.
   - process to send and receive out-of-band messages between client
     applications.
   - other requirements for graph-chat client applications.
   - defines a specific "visual code" format to send an out-of-band message.

[1]: https://en.wikipedia.org/wiki/End-to-end_encryption
[2]: https://en.wikipedia.org/wiki/Man-in-the-middle_attack
[3]: https://en.wikipedia.org/wiki/Off-the-Record_Messaging
[4]: https://en.wikipedia.org/wiki/Forward_secrecy
[5]: https://mermaid-js.github.io/mermaid-live-editor
[6]: simplex-messaging.md
[8]: graph-chat.md
[9]: https://en.wikipedia.org/wiki/Peer-to-peer
[10]: https://en.wikipedia.org/wiki/Distributed_hash_table
[11]: https://en.wikipedia.org/wiki/BitTorrent
[12]: https://en.wikipedia.org/wiki/Sybil_attack
[13]: https://en.wikipedia.org/wiki/Proof_of_work
[14]:
  https://www.usenix.org/conference/woot15/workshop-program/presentation/p2p-file-sharing-hell-exploiting-bittorrent
