with ada.text_io;
use Ada.Text_IO;
with ada.io_exceptions;
use Ada.IO_Exceptions;
with Ada.Containers.Indefinite_Vectors;
use  Ada.Containers;
with ada.strings.maps;
with ada.strings.fixed;

procedure flesch is
	
	package ASM renames ada.strings.maps;
   In_File      : Ada.Text_IO.File_Type;
   value        : Character;
   string_array : array (1..2000000) of Character;
   pos          : Integer;
   package String_Vector is new Indefinite_Vectors (Natural,String); use String_Vector;
   s       : String(1..2000000) := (others => Character'Val(0));
   current : Positive := s'First;
   v       : Vector;

begin

   Ada.Text_IO.Put (Item => "Done initilizing variables");
   Ada.Text_IO.Open (File => In_File, Mode => Ada.Text_IO.In_File, Name => "/home/moshell_jw/alice.txt");

	--for each
   pos := 0;
   while not Ada.Text_IO.End_Of_File(In_File) loop
    Ada.Text_IO.Get (File => In_File, Item => value);
    pos := pos + 1;
    string_array(pos) := value;
   end loop;
   exception
   when Ada.IO_Exceptions.END_ERROR => Ada.Text_IO.Close (File => In_File);


   for i in string_array'range loop
     s(i) := string_array(i);
   end loop;

	--separate
  for i in s'range loop
    --if s (i) = ' ' or i = s'last then
    if ASM.is_in(s(i), ASM.to_set(" !.?;:")) then
      v.append (s(current .. i));
      current := i + 1;
    end if;
   end loop;

  for s of v loop
   put(s);
   new_line;
  end loop;

   Ada.Text_IO.New_Line;

end flesch;
