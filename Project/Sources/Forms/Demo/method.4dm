// Sudoku — picture sudoku (Latin square) for kids, driven by cs.hero.

Case of

		//______________________________________________________
	: (Form event code=On Load)

		Form.transition:=cs.hero.ElementTransition.new()
		Form.game:=cs.Sudoku.new(Form.transition)

		//______________________________________________________
	: (Form event code=On Timer)

		Form.transition.onTimer()

		//______________________________________________________
	: (Form event code=On Clicked)

		var $name : Text:=FORM Event.objectName

		Case of
			: (Position("cellBtn_"; $name)=1)
				Form.game.tapCell(Num(Substring($name; 9))-1)
			: (Position("palBtn_"; $name)=1)
				Form.game.selectBrush(Num(Substring($name; 8)))
			: ($name="newBtn")
				Form.game.newPuzzle()
		End case

		//______________________________________________________
	: (Form event code=On Unload)

		SET TIMER(0)

		//______________________________________________________
End case
