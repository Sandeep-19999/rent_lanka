# Delete Conversation

## Existing structure and behavior

`MessagesScreen` streams shared `chats/{chatId}` documents whose `participants`
array contains the authenticated user's UID. Cards use `participantNames`,
`lastMessage`, `lastMessageAt` and `unreadCounts`. `ChatContext` holds optional
rental/exchange metadata; there is no standalone conversation model.
`ChatScreen` streams `chats/{chatId}/messages`, represented by `MessageModel`
with sender, receiver, text, timestamp and read status. `ChatService` uses
Firebase Authentication for identity.

Long press a conversation, select **Delete Conversation**, then confirm the
requested dialog. Cancel changes nothing. A transaction reads the shared chat,
checks membership and writes only:

```
users/{currentUserUid}/hidden_conversations/{chatId}
  hiddenAt: server timestamp
```

The shared chat, messages, participant names and unread counts are untouched.
There is no write under the other user's profile. Each participant's list streams
only their own markers. The existing search filters the remaining visible chats.
The existing empty state appears when all chats are hidden. Pending marker writes
do not hide a card until acknowledged; errors allow retry.

Markers persist across restart. A conversation reappears when `lastMessageAt`
becomes newer than `hiddenAt` (an incoming or outgoing message). Name/context
updates and marking messages read do not restore it. Legacy chats without a
timestamp stay hidden until a timestamped message is sent. Opening a hidden chat
through another existing entry point still works and retains its message history.

## Required Firestore rule addition

There is no Firestore security rules source in this repository. The deployed
rules could not be inspected and were not changed or deployed. Merge this block
inside the existing `match /databases/{database}/documents` block, preserving all
existing chat and message permissions:

```firestore
match /users/{uid}/hidden_conversations/{chatId} {
  function isOwner() {
    return request.auth != null && request.auth.uid == uid;
  }

  allow read: if isOwner();
  allow create, update: if isOwner()
    && request.auth.uid in
       get(/databases/$(database)/documents/chats/$(chatId)).data.participants
    && request.resource.data.keys().hasOnly(['hiddenAt'])
    && request.resource.data.hiddenAt == request.time;
  allow delete: if isOwner();
}
```

The transaction also needs the existing participant-only read access to the chat.
Server timestamp validation prevents a forged future cutoff. Owner-only marker
rules prevent a user from changing another participant's list visibility.
Review overlapping recursive rules: a restrictive rule cannot override another
matching rule granting access. If a broader user-subcollection rule already
exists, scope it so it does not bypass these protections. Do not deploy this
snippet as an entire replacement ruleset.

See [Firebase rule conditions](https://firebase.google.com/docs/firestore/security/rules-conditions)
and [snapshot metadata and listeners](https://firebase.google.com/docs/firestore/query-data/listen).

## Verification

Automated tests use controlled Firebase SDK doubles and the real list filtering
and service methods. They check ownership, targeted private writes, failed
transactions, confirmation/cancellation, loading protection, search, empty
state, reopening the screen and restoration after a newer message. They do not
claim to verify deployed rules or a live device restart.

After merging rules, verify with two test accounts in the emulator or development
project: A hides a chat, other chats stay visible, B still sees its chat and
message history, and A still cannot see it after restarting. Search should exclude
the hidden chat. A newer message from B should restore it. Direct SDK attempts to
write B's marker as A, write as a nonparticipant or write a future timestamp must
fail. Denied/network failures must leave the list entry visible.

## Separate Delete Message feature

The current chat screen has no message-delete action. Physically deleting a
message would remove a shared document and affect both participants, while also
requiring updates to the conversation preview and unread state. A safe per-user
message-hide feature would need its own visibility records and rules; sender-only
unsend would need a different product policy. Individual message deletion was
not implemented as part of conversation deletion.
