with Ada.Text_IO;
use Ada.Text_IO;
with Ada.Characters.Latin_1;
with Ada.Diretories;

procedure flesch is

	package AIO renames Ada.Text_IO;
	package ACL renames Ada.Characters.Latin_1;

	In_File	: aio.File_Type;
	value	: Character;
	pos		: Integer;
	filename : string := "/home/moshell_jw/alice.txt"
	filesize : natural;
	s: string(1..10000);

begin
	
	--TODO filesize - rosettacode read whole file
	AIO.Open(File => In_File, Mode => AIO.In_File, Name => filename);
	
	pos := 0;
	while not aio.End_Of_File(In_File) loop
		aio.get(File => In_File, Item => value);
		AIO.Put(Item => value);
	end loop;
	
	exception
		when aio.end_error => aio.close(file => In_file);

end flesch;
