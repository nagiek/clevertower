define [
  'underscore',
  'parse',
], (_, Parse) ->
  # This is the transient application state, not persisted on Parse
  AppState = Parse.Object.extend "AppState",
    defaults:
      filter: "all"