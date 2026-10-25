/*
Sudoku — a picture sudoku (Latin square) for young kids, animated by Hero (cs.hero).

A 3×3 grid uses three picture elements (fruits, animals, unicorns…). A few cells are
given; the child fills the rest so that **every row and every column holds all three
elements, with no repeat** — the rule of a Latin square, which is what a 3-symbol sudoku
is. Pick an element from the palette, tap an empty cell to place it; a cell that clashes
in its row or column is flagged in red. Fill the grid with no clashes to win.

Store the instance in Form.game.

(4D evaluates left-to-right with NO operator precedence, so arithmetic inside a comparison
or an index is parenthesised. Logical AND is &, OR is |, each operand parenthesised.)
*/

property transition : cs.hero.ElementTransition

property N : Integer:=3                 // grid side (3 elements → 3×3); scalable
property cells : Integer                 // N*N

// theme sets — each is N emojis; a new puzzle picks one at random
property themes : Collection:=[\
["🍎"; "🍌"; "🍇"]; \
["🐶"; "🐱"; "🐰"]; \
["🦄"; "🧜‍♀️"; "🐬"]; \
["⭐"; "🌈"; "🌸"]; \
["🚗"; "🚲"; "✈️"]; \
["🍓"; "🍦"; "🍰"]]
property theme : Collection              // the N emojis in play

property solution : Collection           // [idx] -> 1..N (a valid Latin square)
property given : Collection              // [idx] -> locked clue
property value : Collection              // [idx] -> 0 empty, else 1..N
property brush : Integer:=1              // the element currently picked from the palette
property over : Boolean:=False

property colGiven : Integer:=0x00E4E7EC
property colFree : Integer:=0x00FFFFFF
property colBad : Integer:=0x00FFD4D4
property cellFont : Integer                // the cell emoji size, read from the form

Class constructor($transition : cs.hero.ElementTransition)

	This.transition:=$transition
	This.cells:=This.N*This.N
	This.cellFont:=cs.hero.ElementState.new("cellLbl_1").fontSize
	This.newPuzzle()

	// === === === === === === === === === === === === === === === === === === === ===
Function newPuzzle()

	This.over:=False
	OBJECT SET VISIBLE(*; "message"; False)

	This.theme:=This.themes[(Random % This.themes.length)]

	// a valid Latin square: base (r+c)%N, then relabel symbols and permute rows/cols
	var $sym : Collection:=This._perm(This.N)
	var $rows : Collection:=This._perm(This.N)
	var $cols : Collection:=This._perm(This.N)

	This.solution:=[]
	This.given:=[]
	This.value:=[]

	var $i : Integer
	For ($i; 0; This.cells-1)
		This.solution.push(0)
		This.given.push(False)
		This.value.push(0)
	End for

	var $r; $c : Integer
	For ($r; 0; This.N-1)
		For ($c; 0; This.N-1)
			var $base : Integer:=(($rows[$r]-1)+($cols[$c]-1)) % This.N
			var $idx : Integer:=($r*This.N)+$c
			This.solution[$idx]:=$sym[$base]
		End for
	End for

	// reveal some clues, leave a handful empty to fill
	var $empties : Integer:=This._hi((This.N=3); 4; (This.cells\2))
	var $clues : Integer:=This.cells-$empties
	var $order : Collection:=This._shuffle(This._range(This.cells))
	For ($i; 0; $clues-1)
		var $cell : Integer:=$order[$i]
		This.given[$cell]:=True
		This.value[$cell]:=This.solution[$cell]
	End for

	This.brush:=1
	This._render()

	// === === === === === === === === === === === === === === === === === === === ===
	// Pick an element from the palette.
Function selectBrush($b : Integer)

	This.brush:=$b
	This._highlightPalette()

	// === === === === === === === === === === === === === === === === === === === ===
	// Tap a cell: place the current brush, or clear it if it is already there.
Function tapCell($i : Integer)

	If (This.over) || (This.given[$i])
		return
	End if

	If (This.value[$i]=This.brush)
		This.value[$i]:=0
	Else
		This.value[$i]:=This.brush
	End if

	This._renderCell($i; True)
	This._refresh()

	// === === === === === === === === === === === === === === === === === === === ===
	// Recompute clashes, repaint, and check for a win.
Function _refresh()

	var $bad : Collection:=This._clashes()
	var $filled : Integer:=0
	var $anyBad : Boolean:=False

	var $i : Integer
	For ($i; 0; This.cells-1)
		If (This.value[$i]>0)
			$filled:=$filled+1
		End if
		If ($bad[$i])
			$anyBad:=True
		End if
		This._paintCell($i; $bad[$i])
	End for

	If (($filled=This.cells) & (Not($anyBad)))
		This._win()
	End if

	// === === === === === === === === === === === === === === === === === === === ===
Function _win()

	This.over:=True
	OBJECT SET TITLE(*; "message"; "Bravo !")
	OBJECT SET VISIBLE(*; "message"; True)

	// a little pulse across the grid
	var $i : Integer
	For ($i; 0; This.cells-1)
		This._pulseCell($i)
	End for

	// === === === === === === === === === === === === === === === === === === === ===
	// [idx] -> True when the cell repeats its value in its row or column
Function _clashes() : Collection

	var $bad : Collection:=[]
	var $i; $a; $b : Integer
	var $ra; $ca; $rb; $cb : Integer

	For ($i; 0; This.cells-1)
		$bad.push(False)
	End for

	For ($a; 0; This.cells-1)
		If (This.value[$a]>0)
			For ($b; 0; This.cells-1)
				If (($a#$b) & (This.value[$b]=This.value[$a]))
					$ra:=($a\This.N)
					$ca:=($a%This.N)
					$rb:=($b\This.N)
					$cb:=($b%This.N)
					If (($ra=$rb) | ($ca=$cb))
						$bad[$a]:=True
					End if
				End if
			End for
		End if
	End for

	return $bad

	// MARK:- rendering
	// === === === === === === === === === === === === === === === === === === === ===
Function _render()

	var $i : Integer
	For ($i; 0; This.cells-1)
		This._renderCell($i; False)
		This._paintCell($i; False)
	End for

	// palette shows the three elements
	For ($i; 1; This.N)
		OBJECT SET TITLE(*; "palLbl_"+String($i); This.theme[($i-1)])
	End for
	This._highlightPalette()

	// === === === === === === === === === === === === === === === === === === === ===
	// Set a cell's emoji (empty when 0); $pop scales it in.
Function _renderCell($i : Integer; $pop : Boolean)

	var $name : Text:="cellLbl_"+String($i+1)
	var $v : Integer:=This.value[$i]

	If ($v=0)
		OBJECT SET TITLE(*; $name; "")
	Else
		OBJECT SET TITLE(*; $name; This.theme[($v-1)])
		If ($pop)
			This._popIn($name)
		End if
	End if

	// === === === === === === === === === === === === === === === === === === === ===
	// Background colour: given, clashing, or free.
Function _paintCell($i : Integer; $bad : Boolean)

	var $name : Text:="cellBg_"+String($i+1)
	var $col : Integer:=This.colFree

	Case of
		: ($bad)
			$col:=This.colBad
		: (This.given[$i])
			$col:=This.colGiven
	End case

	OBJECT SET RGB COLORS(*; $name; $col; $col)

	// === === === === === === === === === === === === === === === === === === === ===
Function _highlightPalette()

	var $i : Integer
	For ($i; 1; This.N)
		If ($i=This.brush)
			OBJECT SET RGB COLORS(*; "palPad_"+String($i); 0x00344054; 0x00344054)
		Else
			OBJECT SET RGB COLORS(*; "palPad_"+String($i); 0x00E4E7EC; 0x00E4E7EC)
		End if
	End for

	// MARK:- helpers
	// === === === === === === === === === === === === === === === === === === === ===
	// A size "pop" via font size only — the cell box never changes, so an interrupted
	// or re-triggered pop can leave the emoji a little small, but NEVER invisible, and
	// the target is a stored constant (not the possibly-mid-animation current box).
Function _popIn($name : Text)

	This.transition.animate($name).from({fontSize: (This.cellFont\3)}).to({fontSize: This.cellFont}).duration(240).easing("easeOutBack").start()

Function _pulseCell($i : Integer)

	var $name : Text:="cellLbl_"+String($i+1)
	If (This.value[$i]>0)
		This._popIn($name)
	End if

	// --------------------------------------------------------------------------------
Function _perm($n : Integer) : Collection

	return This._shuffle(This._seq($n))

Function _seq($n : Integer) : Collection   // [1 .. n]

	var $c : Collection:=[]
	var $i : Integer
	For ($i; 1; $n)
		$c.push($i)
	End for
	return $c

Function _range($n : Integer) : Collection   // [0 .. n-1]

	var $c : Collection:=[]
	var $i : Integer
	For ($i; 0; $n-1)
		$c.push($i)
	End for
	return $c

Function _shuffle($src : Collection) : Collection

	var $pool : Collection:=$src.copy()
	var $out : Collection:=[]
	While ($pool.length>0)
		var $k : Integer:=(Random % $pool.length)
		$out.push($pool[$k])
		$pool.remove($k)
	End while
	return $out

Function _hi($cond : Boolean; $a : Integer; $b : Integer) : Integer

	If ($cond)
		return $a
	End if
	return $b
