## usercase

- tictactoe with two players
  - support redo, undo
  - each step made by user, system must take new snapshot
  - after redo/undo if user make a move, clear all snapshot after that. Cause
    after change history, the rest become invalid

## run dev

```bash
npx vite dev
```

## refactor

> change from ALL imperative version to function core, imperative shell

### what is what?

- core
  - all game logic (take snapshot, undo, redo,...)
  - use plain javascript, functional
- shell
  - receive user interaction, render UI
  - use vuejs
- what is interface between core and shell?
  - minimum data move
  - just provide data that will change (but we not change it, we make new copy
    of it and change the copied instance)

### how
