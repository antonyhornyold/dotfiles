# Rex scripts

Store standalone Lua scripts here for explicit execution with `rex do`:

```sh
rex do ~/.config/rex/scripts/example.lua
```

`example.lua` is illustrative; no executable scripts have been added yet.
Event listeners (`rex.on`) and timers (`rex.after`, `rex.every`) work in these
scripts, not in `init.lua` or its required configuration modules. Scripts are
not loaded automatically by this configuration.
