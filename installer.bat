@echo off
set gameName="sautdoux"

:DELETE_FILES
rem ----------------------------------
rem Delete the old object file
rem ----------------------------------
if exist %gameName%.obj del %gameName%.obj

rem -----------------------------------------------------------------
rem             PREPARE THE ENVIRONMENT VARIABLES
rem 
rem  Set the VS_HOME environment variable to the location of Visual 
rem  Studio 2013 (or Visual C++ 2013 Express)
rem -----------------------------------------------------------------
rem set VS_HOME=C:\Program Files\Microsoft Visual Studio 12.0

rem -----------------------------------------------------------------
rem Add Visual Studio to the system path.
rem -----------------------------------------------------------------
rem set PATH=%VS_HOME%\VC\bin;%VS_HOME%\Common7\IDE;%PATH%

rem -----------------------------------------------------------------
rem  Set the INCLUDE environment variable to the location of the 
rem  MASM include files used by Irvine's book.
rem -----------------------------------------------------------------
set INCLUDE="%~dp0";"%~dp0\lib\masm;%INCLUDE%"

rem -----------------------------------------------------------------
rem  Set the LIB environment variable to the location of the 
rem  Link libraries used by Irvine's book.
rem -----------------------------------------------------------------
rem set LIB=%VS_HOME%\VC\LIB;C:\Irvine;%LIB%
set LIB="%~dp0\lib";"%~dp0\lib\masm;%LIB%"

rem -----------------------------------------------------------------
rem                   EXECUTE THE ASSEMBLER
rem Parameters:
rem  -nologo           suppress the Microsoft logo
rem  -c                assemble only
rem  -Zi               generate debugging information
rem  %%F               source filename, held in loop variable
rem -----------------------------------------------------------------

rem for %%F in (%gameName% %gameName% %3 %4 %5) do ml -nologo -c -Zi -Fl %%F.asm
"%~dp0\lib\masm\ml" /nologo /c /coff /Zi /Zd /W3 /FR /Fm /Fl  %gameName%.asm

if errorlevel 1 goto QUIT
rem (the preceding IF statement only affects the last source file to be assembled)


rem -----------------------------------------------------------------------------------------
rem                   EXECUTE THE LINKER
rem Parameters:
rem   /NOLOGO                                   (suppress the Microsoft logo display)
rem   /DEBUG                                       (include debugging information)
rem   /SUBSYSTEM:CONSOLE         (generate a Windows Console-aware application)
rem   irvine32.lib, kernel32.lib, user32.lib    (link libraries)
rem   %gameName%                                                (EXE filename produced by the linker)
rem ------------------------------------------------------------------------------------------

echo.
echo Linking Assembler output files to the Irvine32, Kernel32, User32 And Winmm libraries.

rem SET LINKCMD=link /NOLOGO /DEBUG /SUBSYSTEM:CONSOLE irvine32.lib kernel32.lib user32.lib
SET LINKCMD="%~dp0\lib\masm\link" /NOLOGO /SUBSYSTEM:CONSOLE /DEBUG /PDB:%gameName%.pdb /DEBUGTYPE:CV lib\Irvine\irvine32.lib lib\Irvine\kernel32.lib lib\Irvine\user32.lib lib\winmm\winmm.lib
SET FILELIST=%gameName%.obj
SET EXENAME=%gameName%.exe


rem -------------------------------------------------------------------
rem Execute the linker, using the command line and list of input files.
rem -------------------------------------------------------------------
%LINKCMD% %FILELIST%

echo.
echo Linker successful. The executable file %EXENAME% was produced.
echo ..................................
echo.

for %%F in ("ilk", "lst", "obj", "pdb", "sbr") do if exist %gameName%.%%F del %gameName%.%%F

:QUIT

rem ENDLOCAL clears all local environment variable settings.

ENDLOCAL
