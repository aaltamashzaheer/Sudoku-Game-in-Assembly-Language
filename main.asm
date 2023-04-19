
INCLUDE Irvine32.INC
INCLUDE macros.INC
BUFFER_SIZE=5000

.data

;Sudoko board
board Byte 81 DUP(?)    

;Solved Sudoku board
solvedBoard Byte 81 DUP(?)	

;Unsolved Board
unSolvedBoard Byte 81 DUP(?)	

;X and Y coordinates
xCor Byte ?		
yCor Byte ?     

;User input value for chosen cell
num Byte 1   

difficulty Byte ?	;1 Easy, 2 Medium, 3 Hard

;Game stats counters
wrongCounter Dword 0
correctCounter Dword 0
remainingCellsCount Byte ?

;Bool indicating if current game is continuation of last game
lastGameLoaded Byte ?

;Data files paths
fileName Byte "sudoku_boards/diff_?_?.txt",0
solvedFileName Byte "sudoku_boards/diff_?_?_solved.txt",0

lastGameFile Byte "sudoku_boards/last_game/board.txt",0
lastGameSolvedFile Byte "sudoku_boards/last_game/board_solved.txt",0
lastGameUnsolvedFile Byte "sudoku_boards/last_game/board_unsolved.txt",0

lastGameDetailsFile Byte "sudoku_boards/last_game/board_details.txt",0

;Variables for reading from file
buffer Byte BUFFER_SIZE DUP(?)
fileHandle HANDLE ?

;Variables for writing in array
str1 BYTE "Cannot create file",0dh,0ah,0  
newline byte 0Dh,0Ah

;Helper variables for PrintArray procedure
helpCounter Dword ?
helpCounter2 Byte ?

;Used for calculating game duration
startTime Dword ?

beep byte 07h

.code
;----------------------ReadArray-----------------------------
;Reads the array from the file.                             |
;param arrayOffset (ESI): offset of the array to be filled.	|
;param fileNameOffset (EBX): offset of string file name.	|
;Returns: Array read from file in EDX.						|
;------------------------------------------------------------
ReadArray PROC, arrayOffset:Dword, fileNameOffset:Dword
	
	;Setting ECX with the max string size
	MOV ESI, arrayOffset
	MOV ebx, fileNameOffset
	MOV ECX,34

	;Open the file for input
	MOV EDX,ebx
	CALL OpenInputFile
	MOV fileHandle, EAX

	;Check for reading from file errors
	CMP EAX, INVALID_HANDLE_VALUE	
	JNE FileHandleIsOk	
	mWrite <"Cannot open file", 0dh, 0ah>
	JMP quit

	FileHandleIsOk :
		; Read the file into a buffer
		MOV EDX, OFFSET buffer
		MOV ECX, BUFFER_SIZE
		CALL ReadFromFile
		JNC CheckBufferSize	;if carry flag =0 then size of the buffer is ok
		mWrite "Error reading file. "	
		CALL WriteWindowsMsg
		JMP CloseFilee

	CheckBufferSize	 :
		;Check if buffer is large enough
		CMP EAX, BUFFER_SIZE	
		jb BufferSizeOk
		mWrite <"Error: Buffer too small for the file", 0dh, 0ah>
		JMP quit

BufferSizeOk :
	;Insert null terminator
	MOV buffer[EAX], 0

	MOV ebx, OFFSET buffer
	MOV ECX, 97
	;store the offset of the array in EDX to reuse it
	MOV EDX,ESI

	StoreContentInTheArray :
		  MOV AL, [ebx]
		  INC ebx
		  CMP AL, 13
		  JE SkipBecOfEndl
		  CMP AL, 10
		  JE SkipBecOfEndl
		  MOV [ESI], AL
		  INC ESI
		 SkipBecOfEndl : 
	loop StoreContentInTheArray


	MOV ESI, EDX
	;store the offset of the array in EDX to reuse it
	
	MOV ECX, 81
   ConvertFromCharToInt:
		  SUB byte ptr[ESI],48
	      INC ESI 
	loop ConvertFromCharToInt

	;Return the offset of the filled array in ESI
	 MOV ESI, EDX

CloseFilee :
	MOV EAX, fileHandle
	CALL CloseFile

	quit :
	ret
ReadArray ENDP



;----------------------CheckIndex----------------------------
;Checks if index out of range.								|
;param val1: xCor.             -------------                |
;param val2: yCor.		       |Global Vars|				|
;param val3: cell value.       -------------                |
;Returns: 1 in EAX if coordinates and input are valid,		|
;	or 0 otherwise.											|
;------------------------------------------------------------
CheckIndex PROC, val1:Byte, val2:Byte, val3:Byte
	
	PUSH EAX
	
	MOV AL, val1
	MOV xCor, AL
	MOV AL, val2
	MOV yCor, AL
	MOV AL, val3
	MOV num, AL
	
	POP EAX

	;Checking xCor lies between 1 and 9
	CMP xCor,9
	ja WRONG
	CMP xCor,1
	jb WRONG

	;Checking yCor lies between 1 and 9
	CMP YCor,9
	ja WRONG
	CMP YCor,1
	jb WRONG

	;Checking num lies between 1 and 9
	CMP num,9
	ja WRONG
	CMP num,1
	jb WRONG

	JMP RIGHT

	WRONG:
		MOV EAX,0
		ret
	RIGHT:
		MOV EAX,1
		ret
CheckIndex ENDP



;----------------------GetValue------------------------------
;Returns the value in the given index						|
;Param val1 (EDX): pointer to the array.					|
;Param val2: xCor.											|
;Param val3: yCor.											|
;Return: given coordinates' value in EAX.					|
;------------------------------------------------------------
GetValue PROC, val1:Dword, val2:Byte, val3:Byte 
	PUSH ECX
	PUSH EDX
	PUSH EAX

	MOV EDX, val1
	MOV AL, val2
	MOV xCor, AL
	MOV AL, val3
	MOV yCor, AL

	POP EAX

	INVOKE CheckIndex, val2, val3, num 
	PUSH ECX
	PUSH EDX
	CMP EAX, 1
	JE Body
		MOV EAX, -1
		POP EDX
		POP ECX
		ret
	Body:
		DEC xCor
		DEC yCor
		MOV EAX, 9
		MOVZX ECX, xCor
		Mul ECX
		MOVZX ECX, yCor
		ADD EAX, ECX
		POP EDX
		PUSH EDX
		ADD EDX, EAX
		MOV EAX, 0
		MOV AL, [EDX]
		INC xCor
		INC yCor
		POP ECX
		POP EDX
		POP EDX
		POP ECX
	ret
GetValue ENDP



;----------------------CheckAnswer---------------------------
;Checks if the answer in the given index is correct			|
;Param val1: xCor.											|
;Param val2: yCor.											|
;Param val3: cell value.									|
;Returns: 1 in EAX if true, and 0 otherwise.				|
;------------------------------------------------------------
CheckAnswer PROC, val1:Byte, val2:Byte, val3:Byte

	PUSH EAX
	
	;Setting global variables with given parameters
	MOV AL, val1
	MOV xCor, AL
	
	MOV AL, val2
	MOV yCor, AL

	MOV AL, val3
	MOV num, AL

	POP EAX

	;Getting the answer value in AL
	INVOKE GetValue, offset solvedBoard, val1, val2

	;MOVing the value to check to BL
	MOV bl,num

	;Comparing the given value with the answer
	CMP bl,AL
	JE RIGHT
	JMP WRONG

	RIGHT:
	MOV EAX,1
	ret

	WRONG:
	MOV AL,beep
	CALL writechar
	MOV EAX,0
	
	ret
CheckAnswer ENDP



;----------------------GetBoards----------------------------
;Fills board,solvedBoards variables with data read from	   |
;	file depending on given difficulty and a generated	   |
;	random number.										   |	
;Param val1:   Difficulty	(Gloval Var)				   |
;Returns: Desired board in board variable				   |
;-----------------------------------------------------------
GetBoards PROC, val1: Byte

	PUSH EAX

	;Set global variable with given parameter
	MOV AL, val1
	MOV Difficulty, AL

	POP EAX

	;Generating random value from AX and CX
	xor AX,CX

	;Getting the value modulu 3
	MOV DX,0
	MOV BX,4
	DIV BX		;DX carries a random value less than 4

	;Setting value to 1 if it's 0
	CMP DX,0
	JE ZeroDX
	JMP cont

	ZeroDX:
	MOV DX,1

	cont:
	;Customizing fileName string variables with random choice and difficulty
	MOV AL,dl
	ADD AL,'0'
	MOV fileName[21],AL

	MOV AL,difficulty
	ADD AL,'0'
	MOV fileName[19],AL

	MOV AL,dl
	ADD AL,'0'
	MOV solvedFileName[21],AL

	MOV AL,difficulty
	ADD AL,'0'
	MOV solvedFileName[19],AL

	;Calling ReadArray with required params to populate board var
	INVOKE ReadArray, offset board, offset filename

	;Calling ReadArray with required params to populate unSolved var
	INVOKE ReadArray, offset unSolvedBoard, offset filename

	;Calling ReadArray with required params to populate solvedBoard var
	INVOKE ReadArray, offset solvedBoard, offset solvedFileName

	ret
GetBoards ENDP



;----------------------PrintArray----------------------------
;Prints the array to the console screen.					|
;Param val1 (EDX): offset of array.							|
;------------------------------------------------------------
PrintArray PROC, val1:Dword

	MOV xCor,0
	MOV yCor,1

	MOV helpCounter,1
	MOV helpCounter2,1
	MOV EDX, val1

	CALL crlf
	MOV AL,' '
	CALL writechar
	CALL writechar
	CALL writechar
	CALL writechar
	MOV EAX,1
	MOV ECX,9

	topNumbers:	
		CALL writedec
		PUSH EAX
		MOV AL,' '
		CALL writechar
		CALL writechar
		
		pop EAX
		INC EAX
	loop topNumbers
	
	PUSH EDX	;will be popped after finishing the function 

	MOV ECX,81
	l1:
		MOV EAX,0
		MOVZX EAX,byte ptr [EDX]	;EAX contains current number
		PUSH EAX
		PUSH EDX

		MOV DX,0
		MOV AX,CX     ;DX = CX % 9
 		MOV BX,9
		DIV BX

		CMP DX,0
		JNE NoEndl	  ;if DX % 9 = 0 print endl
		INC xCor
		MOV yCor,1
		CALL crlf
		MOV AL,' ' 
		CALL writechar
		CALL writechar
		CALL writechar


		MOV AL,'|' 
		CALL writechar
		

		PUSH ECX
		MOV EDI,ECX
		MOV ECX,9
		dashes:
			MOV AL,196	 ;horizontal line
			CMP EDI,81
			JNE process
			PUSH ECX
			MOV ECX,3
			MOV AL,196
			horiDashes:
			CALL writechar
			loop horiDashes
			POP ECX
			JMP endloop

			process:
			CMP EDI,54
			JE print
			CMP EDI,27
			JE print
			CMP EDI,0


			MOV AL,' '
			print:
			CALL writechar
			CMP ECX,1
			JNE noBar
			MOV AL,196
			Nobar:
			CMP ECX,1
			JNE yarab
			MOV AL,' ';leave
			yarab:
			CALL writechar
			CMP ECX,7
			JE draw
			CMP ECX,1
			JE draw
			CMP ECX,4
			JNE skip
			draw:
			MOV AL,'|'
			skip:
			CALL writechar
			endloop:
		loop dashes
		POP ECX
	
		CALL crlf
		MOV AL,' '
	CALL writechar
		MOV AL,helpCounter2
		CALL writedec
		MOV AL,' '
	CALL writechar
		INC helpcounter2
		MOV AL,'|'
		CALL writechar

		NoEndl:
		POP EDX
		POP EAX
		PUSH EAX
		
		CMP EAX,0
		JE NoRed	;dont Color 0s with red

		INVOKE GetValue, offset unsolvedBoard,xCor,yCor
		CMP EAX,0
		JNE NoRed

		MOV EAX,4 ;red color
		CALL SetTextColor
		NoRed:
		POP EAX
		CALL writeDec
		MOV EAX,15
		CALL SetTextColor
		INC yCor
		MOV AL,' '
		CALL writechar
		
		MOV AL, ' '
		CMP helpCounter,3
		JNE print2
		MOV AL,'|'
		MOV helpCounter,0
		print2:
		CALL writechar
		INC EDX
		INC helpCounter
		
		dec cx
		JNE l1  ;because of loop causes too far error

	CALL crlf
	MOV AL,' '
	CALL writechar
	CALL writechar
	CALL writechar
	
	MOV ECX,27
	MOV AL,196
	BottomDashes:
	CALL writechar
	loop BottomDashes
	MOV AL,'|'
	CALL writechar
	CALL crlf
	MOV AL,' '
	CALL writechar
	POP EDX
	ret
PrintArray ENDP




;----------------------PrintSolvedArray----------------------------
;Prints the solved array to the console screen.				|
;Param val1 (EDX): offset of array.							|
;------------------------------------------------------------
PrintSolvedArray PROC, val1:Dword

	MOV xCor,0
	MOV yCor,1
	
	MOV helpCounter,1
	MOV helpCounter2,1
	MOV EDX, val1

	CALL crlf
	MOV AL,' '
	CALL writechar
	CALL writechar
	CALL writechar
	CALL writechar
	MOV EAX,1
	MOV ECX,9

	topNumbers:	
		CALL writedec
		PUSH EAX
		MOV AL,' '
		CALL writechar
		CALL writechar
		
		POP EAX
		INC EAX
	loop topNumbers
	
	PUSH EDX ;will be popped after finishing the function 
	MOV ECX,81
	l1:
		MOV EAX,0
		MOVZX EAX,byte ptr [EDX]	;EAX contains current number
		PUSH EAX
		PUSH EDX

		MOV DX,0
		MOV AX,CX     ;DX = CX % 9
 		MOV BX,9
		DIV BX

		CMP DX,0
		JNE NoEndl	  ;if DX % 9 = 0 print endl
		INC xCor
		MOV yCor,1
		CALL crlf
		MOV AL,' ' 
		CALL writechar
		CALL writechar
		CALL writechar


		MOV AL,'|' 
		CALL writechar
		


		PUSH ECX
		MOV EDI,ECX
		MOV ECX,9
		dashes:
			MOV AL,196 ;horizontal line
			CMP EDI,81
			JNE process
			PUSH ECX
			MOV ECX,3
			MOV AL,196
			horiDashes:
			CALL writechar
			loop horiDashes
			POP ECX
			JMP endloop

			process:
			CMP EDI,54
			JE print
			CMP EDI,27
			JE print
			CMP EDI,0


			MOV AL,' '
			print:
			CALL writechar
			CMP ECX,1
			JNE noBar
			MOV AL,196
			Nobar:
			CMP ECX,1
			JNE yarab
			MOV AL,' '
			yarab:
			CALL writechar
			CMP ECX,7
			JE draw
			CMP ECX,1
			JE draw
			CMP ECX,4
			JNE skip
			draw:
			MOV AL,'|'
			skip:
			CALL writechar
			endloop:
		loop dashes
		POP ECX
	
		CALL crlf
		MOV AL,' '
	CALL writechar
		MOV AL,helpCounter2
		CALL writedec
		MOV AL,' '
	CALL writechar
		INC helpcounter2
		MOV AL,'|'
		CALL writechar

		NoEndl:
		POP EDX
		POP EAX
		PUSH EAX
		
		INVOKE GetValue, offset board, xCor, yCor
		
		CMP EAX,0
		JNE NoBlue
		MOV EAX,1
		CALL SetTextColor
		NoBlue:
		POP EAX
		CALL writeDec
		MOV EAX,15
		CALL SetTextColor

		INC yCor
		MOV AL,' '
		CALL writechar
		
		MOV AL, ' '
		CMP helpCounter,3
		JNE print2
		MOV AL,'|'
		MOV helpCounter,0
		print2:
		CALL writechar
		INC EDX
		INC helpCounter
		
		dec cx
		JNE l1  ;because of loop causes too far error


	CALL crlf
	MOV AL,' '
	CALL writechar
	CALL writechar
	CALL writechar

	
	MOV ECX,27
	MOV AL,196
	BottomDashes:
	CALL writechar
	loop BottomDashes
	MOV AL,'|'
	CALL writechar
	CALL crlf
	MOV AL,' '
	CALL writechar
	POP EDX
	ret
PrintSolvedArray ENDP



;----------------------TakeInput-----------------------------
;Prompts user to enter a cells value.						|
;Does not take parameters.									|
;Updates: x, y, num global variables.						|
;------------------------------------------------------------
TakeInput PROC

	again:

	mWrite "Enter the x coordinate :  " 
	CALL ReadDec
	MOV xCor,AL

	mWrite "Enter the y coordinate :  " 
	CALL ReadDec
	MOV yCor,AL

	mWrite "Enter the number :  " 
	CALL ReadDec
	MOV num,AL

	INVOKE checkindex, xCor, yCor, num
	CMP EAX ,1
	JE done

	mWrite "There is an error in your input values... Please reEnter them. " 
	CALL crlf
	JMP again

	done:

	CALL iseditable
	CMP EAX,1
	JE Editable

	mWrite "You Cannot edit this place, Please change it."
	CALL crlf
	JMP again

	Editable:
	mWrite "Edited"
	CALL crlf
	ret
TakeInput ENDP



;----------------------GetDifficulty-------------------------
;Prompts the user to enter desired game difficulty.			|
;Does not take parameters.									|
;Updates: Difficulty global variable.						|
;------------------------------------------------------------
GetDifficulty PROC
	
	again:
	mWrite "Please Enter the difficulty: "
	CALL crlf

	;Checks if the difficulty is 1 or 2 or 3
	CALL ReadDec
	CMP AL,1
	JE NoError
	CMP AL,2
	JE NoError
	CMP AL,3
	JE NoError

	mWrite "Please enter a valid difficulty ( 1 or 2 or 3 ) "
	CALL crlf
	JMP again	;Re Enter difficulty if it was wrong

	NoError:
	MOV difficulty,AL	;take the byte from EAX which will be 1 or 2 or 3
	
	ret
GetDifficulty ENDP



;----------------------EditCell------------------------------
;Updates cell's value at co-ordinate (x,y).					|
;Param val1: xCor.											|
;Param val2: yCor.											|
;Param val3: cell value.                                    |
;Return: 1 in EAX if the cell was edited ,0 otherwise.      |
;------------------------------------------------------------
EditCell PROC, val1:Byte, val2:Byte, val3:Byte

	PUSH EAX

	MOV AL, val1
	MOV xCor, AL

	MOV AL, val2
	MOV yCor, AL

	MOV AL, val3
	MOV num, AL

	POP EAX

	PUSH EDX
	PUSH ECX
	;INVOKE CheckIndex, xCor, yCor, num  |Already done in TakeInput
	CMP EAX, 0
	JE Ending
		INVOKE CheckAnswer, val1, val2, val3
		CMP EAX, 0
	JE Ending
		DEC xCor
		DEC yCor
		MOV EAX, 9
		MOVZX ECX, xCor
		Mul ECX
		MOVZX ECX, yCor
		ADD EAX, ECX
		MOV EDX, offset board
		ADD EDX, EAX
		MOV AL, num
		MOV [EDX], AL
		INC xCor
		INC yCor
		DEC remainingCellsCount
		MOV EAX,1
		POP ECX
		POP EDX
		ret
	Ending:
		POP ECX
		POP EDX
		MOV EAX,0
		ret
EditCell ENDP



;----------------------IsEditable----------------------------
;Checks if cell at x,y (global vars) in board is editable.	 |
;Does not take parameters.									 |
;Returns: 1 in EAX if the place is editable and 0 otherwise. |
;------------------------------------------------------------
IsEditable PROC
	
	INVOKE GetValue, offset board, xCor, yCor

	;Checking value returned from GetValue
	CMP EAX,0
	JE RIGHT
	JMP WRONG

	RIGHT:
	MOV EAX,1
	JMP SKIP

	WRONG:
	MOV EAX,0

	SKIP:
	ret
IsEditable ENDP



;----------------UpdateRemainingCellsCount------------------
;Counts the number of unchanged cells in the board.		   |
;Param: Board (global variable).						   |
;Update: remainingCellsCount global variable.			   |
;-----------------------------------------------------------
UpdateRemainingCellsCount PROC
	PUSH EDX
	PUSH ECX
	PUSH EAX

	MOV remainingCellsCount, 0
	MOV EDX, offset Board
	MOV ECX, 81
	L1:
		MOV AL, [EDX]
		CMP AL, 0
		JNE skip
			INC remainingCellsCount
		skip:
			INC EDX
	Loop L1

	POP EAX
	POP ECX
	POP EDX

	ret
UpdateRemainingCellsCount ENDP



;----------------------LoadLastGame--------------------------
;Fills board variable with last played game boards.			|
;Does not take parametrs.									|
;------------------------------------------------------------
LoadLastGame PROC
	INVOKE ReadArray, offset board, offset lastGameFile
	INVOKE ReadArray, offset solvedBoard, offset lastGameSolvedFile
	INVOKE ReadArray, offset unSolvedBoard, offset lastGameUnSolvedFile

	MOV lastGameLoaded,1

	ret
LoadLastGame ENDP



;----------------------WARNING !-----------------------------
;  This function changes the values of the board variable.  |
;  So it must be CALLed only in the end of the program !    |
;------------------------------------------------------------

;-------------------WriteBoardToFile-------------------------
;Writes given array to file with given string as name.		|
;Param val1 (EDX): offset of array to write to file.		|	
;Param val2 (EBX): offset of file name string.				|
;------------------------------------------------------------
WriteBoardToFile PROC, val1:Dword, val2:Dword

	PUSH EAX

	MOV EDX, val1
	MOV ebx, val2

	POP EAX

	PUSH EDX
	;Convert all Numbers of the array to chars to be written in the file
	 MOV ECX,81		 ; Move number of board elements to ECX
	 loo:
		 MOV EAX,48
		 ADD [EDX],AL
		 INC EDX
	 LOOP loo

	; Create a new text file and error check.
	 MOV EDX,EBX	;Move file name offset to EDX for CreatOutputFile
	 CALL CreateOutputFile
	 MOV fileHandle,EAX

	 ; Check for errors.
	 CMP EAX, INVALID_HANDLE_VALUE 
	 ; error found? 
	 JNE file_ok	; no: skip
	 MOV EDX,OFFSET str1

	 ; display error 
	 CALL WriteString
	 JMP quit 
	 file_ok:  

;Writing in the file
   POP EDX		;address of the array to be typed
   MOV ECX,81	;Length of array

   l5:
	   ;write charachter in the file
	   MOV EAX,fileHandle
	   PUSH EDX		 ;PUSH current character address
	   PUSH ECX		 ;PUSH the loop iterator
	   MOV ECX,1
	   CALL WriteToFile
	   POP ECX

	   ;check if a new line should be printed or not
			MOV DX,0
			DEC ECX
			MOV AX,CX     ;DX = CX-1 % 9
 			MOV BX,9
			DIV BX

			CMP DX,0 ; if not DIV by 9 , then no newline required.
			JNE noEndl

			PUSH ECX
			 MOV EAX,fileHandle
			 MOV ECX,lengthof newline
			 MOV EDX,offset newline
			 CALL WriteToFile
			POP ECX
	
		noEndl:
	   INC ECX  ;as it was decremented above for calculating modulus
	   POP EDX  ;return the address of the read char
	   INC EDX  ;staging for writing next char
   loop l5

   quit:
	ret
WriteBoardToFile ENDP




main PROC
	
	mWrite "*** Welcome to Sudoku Game built with Assembly ***"
	CALL crlf
	CALL crlf

	;Ask user to continue last played game
	mWrite "Do you want to continue the last game ?"
	CALL crlf
	mWrite "Enter Y if Yes or N if No"
	CALL crlf
	CALL ReadChar

	CMP AL,'Y'
	JE RunLastGame
	JMP StartGame

	;Loading last game boards from file
	RunLastGame:
	;start timer
	INVOKE GetTickCount
	MOV StartTime, EAX
		CALL LoadLastGame
		JMP showBoard

	StartGame:

	;Fetch Sudoku Boards from files depending on chosen difficulty
	CALL GetDifficulty
	INVOKE GetBoards, difficulty

	;start timer
	INVOKE GetTickCount
	MOV StartTime, EAX

	JMP showBoard

	GamePlay:
		;Prompt user for input
		CALL TakeInput
		
		
		INVOKE EditCell, xCor, yCor, num

		;updates count of cremaining cells 
		CALL updateRemainingCellsCount

		;Finish game if no empty cells remaining
		CMP remainingCellsCount, 0
		JE Finish

		;Print updated board
		CALL clrscr
		PrintUpdatedBoard:
		CMP EAX,1
		JNE WrongAnswer
			MOV EAX,2    ;Set to Green Color
			CALL SetTextColor
			mWrite "Correct !"
			INC correctCounter
			MOV EAX,15    ;Set Color Back to white
			CALL SetTextColor
			CALL crlf
			JMP ShowBoard
		WrongAnswer:
				MOV EAX,4    ;Set to Red Color
			CALL SetTextColor
			mWrite "Wrong Input :( !"
			INC WrongCounter
			MOV EAX,15    ;Set Color Back to white
			CALL SetTextColor
			CALL crlf

		ShowBoard:
		INVOKE PrintArray, offset Board

		ShowOptions:
		mWrite "Press A to Add a new cell"
		CALL crlf
		mWrite "Press C to reset the current board"
		CALL crlf
		mWrite "Press S to print the solved board"
		CALL crlf
		mWrite "Press E to exit and save current board"
		CALL crlf
		CALL ReadChar

		GetChoice:
		CMP AL,'A'
		JE GamePlay
		CMP AL,'E'
		JE SaveBoard
		CMP AL,'C'
		JE ResetBoard
		CMP AL,'S'
		JE PrintSolvedBoard

		mWrite "Enter a valid choice!"
		JMP ShowBoard

		;Saving current board if user choses exit
		SaveBoard:
			INVOKE GetTickCount
			SUB EAX, startTime

			mWrite <"Time Taken: ">
			CALL writedec
			CALL crlf
			mWrite "Number of Remaining cells: "
			CALL UpdateRemainingCellsCount
			MOVZX EAX,remainingCellsCount
			CALL writedec

			;Saving boards in data files
			INVOKE WriteBoardToFile, offset board, offset lastGameFile
			INVOKE WriteBoardToFile, offset solvedBoard, offset lastGameSolvedFile

			;Prevent calling dummy file if the game is a continued game
			CMP lastGameLoaded, 1
			JE SkipLoading

			;Restoring unsolved board from data file
			INVOKE ReadArray, offset board, offset fileName
			INVOKE WriteBoardToFile, offset board, offset lastGameUnsolvedFile

			SkipLoading:
			CALL crlf
			mWrite " ** Your Board was saved succssfully ! **"
			CALL crlf
			mWrite " ** Thanks for Playing **"
			CALL crlf
			CALL crlf
			exit

		;Rreset current board to initial state
		ResetBoard:
			CMP lastGameLoaded,1
			JE ResetLastGame

			;CALL ReadArray with required params to populate board var
			INVOKE ReadArray, offset board, offset filename
			JMP ResetSuccessful

			ResetLastGame:
			;CALL ReadArray with required params to populate board
			INVOKE ReadArray, offset board, offset lastGameUnsolvedFile

			ResetSuccessful:
				CALL clrscr
				mWrite "Your Game Was Reset!"
				CALL crlf
				JMP ShowBoard


		PrintSolvedBoard:
			INVOKE PrintSolvedArray, offset solvedBoard

			INVOKE GetTickCount
			SUB EAX, startTime

			CALL crlf
			mWrite <"Time Taken: ">
			CALL writedec
			CALL crlf
			mWrite "Number of Remaining cells: "
			CALL UpdateRemainingCellsCount
			MOVZX EAX,remainingCellsCount
			CALL writedec
			CALL crlf
			CALL crlf
			mWrite "Number of Incorrect Solutions: "
			MOV EAX,wrongCounter
			CALL writedec
			CALL crlf
			mWrite "Number of Correct Solutions: "
			MOV EAX,correctCounter
			CALL writedec
			CALL crlf
			mWrite " ** Thanks for Playing **"
			CALL crlf

			exit

	Finish:
		INC correctCounter	;Count last correct submission

		CALL clrscr
		mWrite "Congratulations You have Finished the board !"
		CALL crlf
		INVOKE GetTickCount
			SUB EAX, startTime

			mWrite <"Time Taken: ">
			CALL writedec
			CALL crlf
			mWrite "Number of Incorrect Solutions: "
			MOV EAX,wrongCounter
			CALL writedec
			CALL crlf
			mWrite "Number of Correct Solutions: "
			MOV EAX,correctCounter
			CALL writedec
			CALL crlf

				mWrite " ** Thanks for Playing **"
			CALL crlf


	exit
main ENDP

END main
