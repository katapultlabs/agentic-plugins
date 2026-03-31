# testID Naming Conventions

Every interactive element in a React Native app should have a `testID` prop for autonomous testing. testIDs appear as `AXUniqueId` in the iOS accessibility tree.

## Naming Patterns

| Element Type | Pattern | Examples |
|-------------|---------|----------|
| Screens | `screen-{name}` | `screen-home`, `screen-login`, `screen-settings`, `screen-chat-detail` |
| Buttons | `btn-{action}` | `btn-send`, `btn-sign-in`, `btn-cancel`, `btn-back`, `btn-new-chat` |
| Text inputs | `input-{field}` | `input-email`, `input-password`, `input-search`, `input-message` |
| Lists | `list-{name}` | `list-messages`, `list-contacts`, `list-conversations` |
| List items | `item-{name}-{index}` | `item-message-0`, `item-contact-3`, `item-conversation-5` |
| Cards | `card-{name}-{index}` | `card-recipe-0`, `card-product-2`, `card-pillar-nutrition` |
| Filters | `btn-filter-{type}` | `btn-filter-all`, `btn-filter-active`, `btn-filter-breakfast` |
| Views/sections | `view-{name}` | `view-error`, `view-empty-state`, `view-loading`, `view-attachments-preview` |
| Modals | `modal-{name}` | `modal-confirm`, `modal-settings`, `modal-error` |
| Navigation tabs | `tab-{name}` | `tab-home`, `tab-profile`, `tab-settings` |
| Headers | `header-{name}` | `header-main`, `header-chat` |
| Switches/toggles | `switch-{name}` | `switch-notifications`, `switch-dark-mode` |

## Rules

1. Use kebab-case: `btn-sign-in` not `btn_sign_in` or `btnSignIn`
2. Be descriptive: `btn-send-message` not `btn-1`
3. Use index suffix for repeated elements: `item-message-0`, `item-message-1`
4. Screen containers get the `screen-*` testID on the outermost View/SafeAreaView
5. Dynamic testIDs use template literals: `` testID={`card-pillar-${key}`} ``

## Adding testIDs

```tsx
// Screen container
<SafeAreaView testID="screen-home" className="flex-1">

// Button
<Pressable testID="btn-send" onPress={handleSend}>

// Text input
<TextInput testID="input-email" value={email} onChangeText={setEmail} />

// List
<FlatList testID="list-messages" data={messages} renderItem={...} />

// List items (add index from renderItem)
renderItem={({ item, index }) => (
  <View testID={`item-message-${index}`}>

// Dynamic cards
{pillars.map((key) => (
  <Card testID={`card-pillar-${key}`} key={key}>
```

## Prioritization

Add testIDs incrementally — prioritize:
1. Screen containers (enables "which screen am I on?" checks)
2. Navigation elements (buttons, tabs, links)
3. Form inputs (text fields, toggles)
4. Lists and list items (for content verification)
5. Status indicators (error views, empty states, loading)
