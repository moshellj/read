with Ada.Text_IO;
use Ada.Text_IO;
with Ada.Characters.Latin_1;
with Ada.Directories;
with ada.direct_io;

procedure flesch is

	package AIO renames Ada.Text_IO;
	package ACL renames Ada.Characters.Latin_1;

	In_File	: aio.File_Type;
	--value	: Character;
	pos		: Integer;
	filename : string := "/home/moshell_jw/alice.txt";
	linesize : natural;
	s: string(1..10000);

begin
	
	AIO.Open(File => In_File, Mode => AIO.In_File, Name => filename);
	
	pos := 0;
	while not aio.End_Of_File(In_File) loop
		s := (others => acl.nul);
		--aio.get(File => In_File, Item => value);
		aio.get_line(file => in_file, item => s, last => linesize);
		AIO.Put(Item => s & ACL.lf);
	end loop;
	
	exception
		when aio.end_error => aio.close(file => In_file);

end flesch;
