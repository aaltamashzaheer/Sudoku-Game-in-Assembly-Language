# Sudoku Game in Assembly Language
Sudoku is a popular puzzle game that provides entertainment and a mental challenge to players. The primary objective of creating a Sudoku game is to offer users an enjoyable experience and keep them engaged.
  Let's see how to install the Visual Studio 22 and how to create a project?


## Installation from Miscrosoft Website

First of all install Visual Studio from Microsoft website keeping in view compatibility of your computer. First installing setup and opening it, you will see Visual Studio Installer. You simply need to install 2 of the C++ setups inside the installer (installer will show you options you don't need to install them externaly).
After that simply follow these steps and you are ready to rock.

## Create an empty solution:

Use File | New | Project… Expand the ‘Other Project Type‘ tree, Select ‘Visual Studio Solutions‘, and create a new ‘Blank Solution‘ like Solution1
 
## Add an empty project:

Use File | Add | New Project… Expand the ‘Visual C++‘, ‘General‘ section and create a new ‘Empty Project‘ like myAsmProj

Simply delete three folders:
 
##	Acquire the MASM options:

Right click on the Project in the Solution Explorer and select ‘Build Customizations…‘


Tick the ‘masm‘ box and say OK.

 
##	Add a new source file:

Add a.asm file to the project by right clicking on the Project and selecting ‘Add | New Item…‘with ‘Text File ‘or ‘C++ File’. Enter a filename ending with .asm like test.asm


##	Verify MASM :

Right click on the Project and select ‘Properties‘. You should see a dialog like this (Note the MASM item at the bottom of the tree). If you don’t then something went wrong

 
##	Configure the linker:

In the above dialog, use Configuration Properties > Linker > System> SubSystem, set the SubSystem to Windows or Console like this


Don’t set Entry Point to the name of ‘main’ method (as per the END directive – see code). Make sure to go Configuration Properties > Linker > Advanced > Entry Point

 
##	Add Kip Irvine Support:

Set c:\Irvine in Include Path under the Microsoft Macro Assembler | General section


Set c:\Irvine in Additional Library Directories under the Link | General section

 
Set Irvine32.Lib in Additional Dependencies under the Link | Input section



##	Try test code:
Copy the code and run it. Now, you are ready to work on Visual Studio 22

