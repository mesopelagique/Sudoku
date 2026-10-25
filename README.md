# Sudoku

**A picture sudoku for young kids.** A grid uses picture elements (fruits, animals, unicorns…);
fill it so **every row and every column holds each element once, with no repeat** — the rule of a
Latin square, which is what a picture sudoku is. Choose **3×3, 4×4 or 5×5**. Built on
[Hero](https://github.com/mesopelagique/Hero) (`cs.hero`) for the animations.

<p align="center"><img src="Documentation/sudoku.gif" width="320" alt="Sudoku — a 3×3 grid with a few pictures given; pick an element and tap a cell to place it; clashes flag red, a full clash-free grid wins" /></p>

## Play

Open the project — `On Startup` launches it.

- A few cells come **given** (greyed, locked); the rest are empty.
- Pick an element from the **palette**, then tap an empty cell to place it (tap again to clear).
- A cell that **repeats** its element in its row or column turns **red** — fix it.
- Fill the grid with no clashes → **Bravo !**
- Pick the size — **3×3 / 4×4 / 5×5** — and **Nouveau** deals a fresh puzzle with a new set of
  pictures. Bigger grids use more elements and leave more cells to fill.

## How it's built

Each puzzle is a random **Latin square** (base `(r+c) mod N`, then the symbols, rows and columns
shuffled), with some cells revealed as clues. Placing an element pops it in with a `cs.hero`
`easeOutBack` tween; clashes are detected per row/column and painted live; a win pulses the whole
grid. No two tweens fight over one object, and the board geometry comes from the form.

## `cs.Sudoku`

| Function | Action |
|:-|:-|
| `.newPuzzle()` | Deal a new Latin square + theme, reveal the clues. |
| `.selectBrush($b)` | Pick element `$b` from the palette. |
| `.tapCell($i)` | Place the brush in cell `$i` (or clear it); re-check clashes and the win. |
| `.setSize($n)` | Switch the grid to `$n`×`$n` (3, 4 or 5) and lay the pooled cells out. |
