# Libmozok Godot Demo

Libmozok godot demo TODO list.

### Todo

- [ ] Add: add `server.flush()` or some non-blocking alternative to flush all queues before the saving (see main.gd::_save_game(...)).
- [ ] Replace large lists with rlist's `...` notation once it is supported.

### In Progress

- [ ] Finish all the tutorials
	- [x] Add: Puzzle tutorial
	- [ ] Add: Dialogue tutorial
- [ ] Add: Non-linear quests bound with an engaging story.

### Done ✓

- [x] Add: License
- [x] Add: LimMozok icon to LimMozokServer node
- [x] Move to libmozok v1.0.0
- [x] Move tutorial-related signals from the player class to the tutorial map class.
- [x] In the `tutorial.gd`, instead of a list of different tutorial variables and methods, create a dedicated tutorial class.
- [x] Add: Make `.qsf` and `.quest` visible in filesystem inspector.
- [x] Add: Syntax highlighter for `.qsf` and `.quest`.
