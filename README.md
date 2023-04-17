# Sudoku Game in Assembly Language
Sudoku is a popular puzzle game that provides entertainment and a mental challenge to players. The primary objective of creating a Sudoku game is to offer users an enjoyable experience and keep them engaged.

## Table of Contents

- [Introduction](#introduction)
- [Objectives](#objectives)
- [Socio-economic benefits](#socio-economic-benefits)
- [Real Life Applications](#real-life-applications)
- [Software](#software-needed)
- [Installation](#installation)
- [Libraries](#libraries)
- [Procedures and Functions used](#procedures-and-functions-used)
- [Output Results](#output-results)
- [Contributing](#contributing)
- [License](#license)

## Introduction:
Sudoku is a puzzle that has enjoyed worldwide popularity since 2005. The Sudoku game is a popular logic puzzle that requires players to fill a 9x9 grid with numbers from 1 to 9, in such a way that each row, column, and 3x3 sub-grid contains all the numbers from 1 to 9 without any repetitions. To solve a Sudoku puzzle, one needs to use a combination of logic and trial-and-error. More math is involved behind the scenes: combinatorics used in counting valid Sudoku grids, group theory used to describe ideas of when two grids are equivalent, and computational complexity with regards to solving Sudokus.
In this term project, we’ll make the Sudoku game using assembly language.
## Objectives:
1.	This project will provide us with the critical knowledge of assembly language programing.

2.	This is a fully functional project developed in Assembly Language that covers all of the features that an IT student needs to make a Sudoku game.

3.	We will become familiar to interact with Assembly language and its core concepts.

4.	It will provide practical experience and understanding by working on different projects.

## Socio-economic benefits:
1.	Entertainment: Sudoku is a popular puzzle game that provides entertainment and a mental challenge to players. The primary objective of creating a Sudoku game can be to offer users an enjoyable experience and keep them engaged.

2.	Education: Sudoku can also be used as an educational tool to teach logical reasoning, problem-solving, and critical thinking skills. A creator might develop a Sudoku game with the primary objective of helping users improve their cognitive abilities.

3.	Competition: Sudoku can be played competitively, with players aiming to solve the puzzle in the shortest time possible or to achieve the highest score. A creator might design a Sudoku game with the objective of offering a competitive platform for users to compete against each other.

4.	Branding: Some organizations or individuals create custom Sudoku games as a way to promote their brand or business. In this case, the primary objective is to increase brand awareness and engage with potential customers.

5.	Research: Finally, Sudoku puzzles have also been used in research studies to investigate cognitive abilities and brain function. A creator might develop a Sudoku game with the objective of gathering data for research purposes.

## Real Life Applications:

1.	It is a game and a game is always pleasant to play with. This game can be played by children or any person.

2. It is a kind of brain storming game; you use your mind to play it.

## Software Needed:
Visual Studio 22

## Installation:

To get started with Sudoku Game, you need to have Visual Studio installed on your system. Then, follow these steps:

1. Clone this repository:
```python
git clone https://github.com/aaltamashzaheer/Sudoku-Game-in-Assembly-Language
```
2. Navigate to the project directory:
```python
cd Sudoku-Game-in-Assembly-Language
```
3. Install the required packages:
```python
pip install -r installation.txt
```

To view the installation process of the project click [Installation](Installation.txt)
## Libraries:

We have used two libraries in this project:
1.	Irvine32
2. Macros

## Procedures and Functions used:

Then we have created 14 procedures.
1.	Read Array
2. Read Array 2
3.	Check Index
4. Get Value
5. Check Answer
6. Print Array
7. Print Solved Array
8. Take Input
9. Get difficulty
10.	Edit Cell
11.	Is Editable
12.	Update Remaining cells Count
13.	Load last game
14.	Write Board to file
15.	Main

###	Read Array:
This procedure takes two parameters; offset of the array to be filled and the offset of string file name. Array offset is moved to ESI and offset of filename is moved the EBX which is then moved to EDX. OpenInputFile procedure is called to open the desired file. File handle and buffer size are checked to see if there is any error in file. Then the content is added into the array and after converting character into integer, the file is being closed. This function actually reads the array from file in EDX.
 
### Read Array 2:
This procedure is somehow similar to the Read Array but the main difference is this procedure works if we want to load our previous game instead of playing new game. This procedure also takes two parameters; offset of the array to be filled and the offset of string file name and reads the array of the previously loaded game.

 

###	Check Index:
This procedure will take three parameters x-cordinate, y-cordinate and the value you want to store at that index. We are comparing the values and using jumps to see that if the x,y coordinates value and the value you want to store is between the range of (1-9).  If both 3 values are in the range of (1-9), it will mov 1 in EAX otherwise 0.
 
###	Get Value:
The procedure takes 3 parameters, array offset,  x-coordinate and y-coordinate. The MUL instruction is used in this procedure. It is used to perform a multiplication. Always multiplies EAX by a value. The result of the multiplication is stored in a 32-bits value accross EDX (most significant 32 bits of the operation) and EAX (least significant 32 bits of the operation). The result will be stored in dx:ax. This is a register pair, and means that the high portion of the result will be stored in dx, while the low portion of the result will be stored in ax. The procedure will return the given coordinates value in EAX.

 
###	Check Answer:
The procedure takes 3 parameters x-coordinate, y-coordinate, cell value , and checks if the answer in the given index is correct or not. If correct then it will move 1 in EAX, else 0.
 

###	Print Array:
It takes offset of array in EDX and take 2 variables x,y coordinates to make board firstly we make have to print column (1-9) by EAX resistor and ECX similarly, for row wise printing we make (1-9) numbers through ECX and EAX register. Stack structure is mainly used for this purpose. For making block we used loop counter variable and use loop operator to print "|" in both horizontal and vertical axis.
 

###	Print Solved Array:
Print solved array automatically created solved board.it has 4 main functions.
1. For row wise printing it uses EAX and ECX register (1-9).
2. For column wise printing used EAX, ECX, EDX register (1-9).
3. Stack structure mainly is used for this purpose for making block we used loop counter variable and use loop operator to print "|" in both vertical and horizontal axis

### Take Input:
The procedure does not take any parameter. It will ask user the values of x-coordinate and y-coordinate and the value you want to store at that index and update these values.
 
###	Get difficulty:
In this procedure we have used jumps and comparing the difficulty level value enter by the user which is then stored in EAX. We have 3 text files in the backend. Depending on the difficulty level, it will select 1 of 3 files. And we will invoke the Read Array procedure giving the offset of the selected file which will read the file and store it into an array.

###	Edit Cell:
This procedure will take three parameters x-cordinate, y-cordinate and cell value. It will return 1 in EAX if the cell was edited otherwise 0.

###	Is Editable:
Checks if cell at x, y (global variables) in board is editable. Do not take any parameter. It will return 1 in EAX if the place is editable and 0 otherwise.
 
###	Update Remaining cells Count:
It takes no parameter. We are using a global variable remainingCellsCount to store number of remaining cells in it. We are using loops and jumps in it. And we are comparing the values stored in board. If its 0 we will increment the remainingCellsCount value by 1, otherwise 0.

 ###	Load last game:
To keep track of last game we used procedure called load last game that takes two arguments. 
1.	offset of board 
2.	offset of last game file. 
Board offset moves into to EDX and load last game offset moves into EBX then convert all numbers of array to chars to be written in the file. Push and pop functunality is used in this procedure.
 

###	Write Board to file:
Firstly to set color by calling to built-in function "settextcolor" and asked from the player that whether he/she wants to play the previous game or new one and also includes some important function for example:
1.	Adds a new cell
2.	Resets the current board
3.	Prints the current board 
4.	Saves the current board.

 
###	Main:
In the very start of the game, it is asked from the player that whether he/she wants to play the previous game or new one. The response must be in the form of Y(for yes) and N(for no). If Y, previously loaded game board is shown to continue the game but in case of N, new game is started. In the latter case, the difficulty level of choosing among the 3 is asked fromthe user. According to player’s choice, game board is shown. Following four options are given to the player in both the cases:
1.	Press A to Add a new cell
2.	Press C to reset the current board
3.	Press S to print the solved board
4.	Press E to exit and save current board
Add a new cell: 
New cell is added by giving x and y- coordinate to specify the exact position of the number to be added. And finally the number will be given. Then, updated board is shown after adding the number. If any number is already placed there or any invalid number is given, game will indicate in the regarding case. And also tells if the number is correct or not after matching it from the solved board. 
Reset the Current board:  
If the player chooses this option, game will start from the very first option, asking to load the previous game or new one and so on. If the board is successfully reset, it’ll show a message regarding this too. 
Print the solved board: 
With the help of this option, the player is able to see the solved board of the level he was playing. After displaying the solved board, it will also give the following information:
1. Number of remaining cells
2. Time taken 
3. Number of correct solutions 
4. Number of incorrect solutions
Exit and save the board:
If the player selects this option, the board will be saved and again show the following information: 
0. Number of remaining cells
1. Time taken 
2. Number of correct solutions 
3. Number of incorrect solutions

### Text Colors: 
For different messages, different colors have used like if input is wrong or any error occurred, error message will be displayed in red color. For correct input, green color is used.
 

#### Difference between CALL and Invoke:

The INVOKE directive is a powerful replacement for Intel's CALL instruction that lets you pass multiple arguments.

The call instruction is used to call a function. The CALL instruction performs two operations: It pushes the return address (address immediately after the CALL instruction) on the stack. 
 
#### What is a file handle?

A file handle is an integer value which is used to address an open file. Such handles are highly operating system specific, but on systems that support the open() call, you create a handle like this: int handle = open( "foo. txt", OTHER_STUFF_HERE ); You can then use the handle with read/write calls.

For opening an existing file, perform the following tasks −
1.	Put the system call sys_open() number 5, in the EAX register.
2.	Put the filename in the EBX register.
3.	Put the file access mode in the ECX register.
4.	Put the file permissions in the EDX register.
The system call returns the file descriptor of the created file in the EAX register, in case of error, the error code is in the EAX register.

## Output Results:
1.	The output of this game starts with a menu asking to open the previous game to start a new game.
2.	Then if we start a new game, it will ask for difficulty level. There are 3 difficulty levels. It is our choice to select a difficulty level. 
3.	Then it will ask to add cell, or to show the solved board or you can reset the game. 
4.	After adding number in the required coordinates, if we win after various attempts. It will show solved board with number of correct and incorrect solutions.
5.  It will also display the time in milliseconds, time of game played. 
6.	It will also display the remaining cells count. 
7.	Then you can also reset the game.
8.  On playing previous game, it will open last game played if you had saved it.
9.	If you don’t want to play but want to see the solved board you can select the option of solved boards.

## Contributing:
If you would like to contribute to the CRUD APP? You can follow these steps:

1. Fork this repository.
2. Create a new branch for your feature or bug fix.
3. Write your code and add tests if possible.
4. Submit a pull request.
5. Pull requests are welcome. For major changes, please open an issue first
to discuss what you would like to change.
6. Please make sure to update tests as appropriate.

## License:
The Sudoku Game in Assembly language is licensed under the MIT License. See [LICENSE](LICENSE) for more information.
