with ada.text_io;
use Ada.Text_IO;
with ada.io_exceptions;
use Ada.IO_Exceptions;
with Ada.Containers.Indefinite_Vectors;
use  Ada.Containers;
with ada.strings.maps;
with ada.strings.fixed;
with ada.characters.handling;
with ada.integer_text_io;
use ada.integer_text_io;
with ada.float_text_io;
with ada.command_line;

procedure flesch is
	
	package ASM renames ada.strings.maps;
	package ASF renames ada.strings.fixed;
	package ACH renames ada.characters.handling;
   In_File      : Ada.Text_IO.File_Type;
	filename : string(1..10000);
   value        : Character;
   string_array : array (1..2000000) of Character;
   pos          : Integer;
   package String_Vector is new Indefinite_Vectors (Natural,String); use String_Vector;
   s       : String(1..2000000) := (others => Character'Val(0));
	word   : string(1..31) := (others => Character'val(0));
   current : Positive := s'First;
   v       : Vector;
	validsent, validword, lchvow : Boolean := False;
	sentcount, wordcount, syllcount, syllinword: natural := 0;
	writeh : natural;
	alpha, beta, result: float := 0.0;

begin
	
	--filename := ada.command_line.Argument(1);
	
	--tokenizer begin
   --Ada.Text_IO.Put (Item => "Done initilizing variables");
   Ada.Text_IO.Open (File => In_File, Mode => Ada.Text_IO.In_File, Name => "/pub/pounds/CSC330/translations/KJV.txt");

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
	validword := False;
	--put("."); put(s); put_line(".");
	--tokenizer end
		if s'length = 0 then
			goto tokEnd;
		end if;
		--punctuation
		for j in s'range loop
			if ASM.is_in(s(j), ASM.to_set(".;:?!")) then
				if(validsent) then
					sentcount := sentcount + 1;
				end if;
				validsent := false;
			end if;
		end loop;
		--fix token
		--lowercasize
		s := ACH.to_lower(s);
		--put(s); put(" / ");
		--strip
		writeh := 1;
		for k in s'range loop
			--put(k);
			if not ACH.is_letter(s(k)) then
				ASF.delete(s, k, k);
			else
				validword := true;
			end if;
		end loop;
		--put(s);
		--new_line;
		
		--analyze
		if validword then
			wordcount := wordcount + 1;
			validsent := true;
		else
			goto tokEnd;
		end if;
		
		--vowel
		syllinword := 0;
		lchvow := false;
		for l in s'range loop
			if ASM.is_in(s(l), ASM.to_set("aeiouy")) then
				if not lchvow then
					syllinword := syllinword + 1;
				end if;
				lchvow := true;
			else
				lchvow := false;
			end if;
		end loop;
		if s(s'last) = 'e' then
			syllinword := syllinword - 1;
		end if;
		if syllinword < 1 then
			syllinword := 1;
		end if;
		syllcount := syllcount + syllinword;
		
		<<tokEnd>>
	end loop;
	
	--calculate scores
	alpha := float(syllcount) / float(wordcount);
	beta := float(wordcount) / float(sentcount);
	
	result := float'rounding(206.835 - alpha*84.6 - beta*1.015);
	--put(syllcount); new_line; put(wordcount); new_line; put(sentcount); new_line;
	put("Flesch Index: "); put(integer(result)'image); new_line;
	
	result := (alpha*11.8+beta*0.39-15.59);
	put("Flesch-Kincaid Index: "); ada.float_text_io.put(result, 2, 1, 0); new_line;
	
end flesch;












