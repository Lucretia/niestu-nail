
-- JSON -- World's simplest JSON packages
--
-- Chip Richards, NiEstu, Phoenix AZ, Winter 2011

-- This is the lexical analyzer used by the reader.  It is a private
-- package because there's no real way for apps to use it directly.

-- This code is covered by the ISC License:
--
-- Copyright © 2011, NiEstu
--
-- Permission to use, copy, modify, and/or distribute this software for any
-- purpose with or without fee is hereby granted, provided that the above
-- copyright notice and this permission notice appear in all copies.
--
-- The software is provided "as is" and the author disclaims all warranties
-- with regard to this software including all implied warranties of
-- merchantability and fitness. In no event shall the author be liable for any
-- special, direct, indirect, or consequential damages or any damages
-- whatsoever resulting from loss of use, data or profits, whether in an
-- action of contract, negligence or other tortious action, arising out of or
-- in connection with the use or performance of this software.


-- Environment
with Ada.Characters.Latin_1;  -- JSON is really Unicode, but we don't care


package body JSON.Reader.Lexer is

   -- Our "pushback" token, set in Gather_Number, reset when used
   Pushback_Token : Token := (Is_A => Token_None);

   -- Get next token from given stream
   procedure Get_Token (From  :           access Ada.Streams.Root_Stream_Type'Class;
                        To    :    out    Token) is

      use Ada.Characters.Latin_1;

      Next               : Character;
      Token_String_Value : Ada.Strings.Unbounded.Unbounded_String;

      ------------------------------------------------------------------------

      -- Handle a syntax error
      procedure Syntax_Fail (Msg : in String) is
      begin  -- Syntax_Fail
         if When_Error = Error_Fail then
            raise Syntax_Error with """" & Msg & """ not a valid JSON token, line" & Positive'Image (Line_Number);
         elsif When_Error = Error_Report then
            To := (Is_A => Token_Invalid);
         end if;
      end Syntax_Fail;

      ------------------------------------------------------------------------

      -- Skip comment text until next newline (doesn't work on Mac)
      procedure Skip_To_Newline is
      begin  -- Skip_To_Newline
         loop
            Character'Read (From, Next);
            exit when Next = LF;
         end loop;
      end Skip_To_Newline;

      ------------------------------------------------------------------------

      -- Skip comment text until next "*/"
      procedure Skip_To_Star_Slash is
      begin  -- Skip_To_Star_Slash
         loop
            Character'Read (From, Next);
            if Next = '*' then
               Character'Read (From, Next);
               exit when Next = '/';
            end if;
         end loop;
      end Skip_To_Star_Slash;

      ------------------------------------------------------------------------

      -- Gather a string value, handling escape sequences if encountered
      procedure Gather_String is

         use Ada.Strings.Unbounded;

         Hex_String : Unbounded_String;
         Hex_Value  : Natural;

      begin  -- Gather_String
         Token_String_Value := Null_Unbounded_String;

         loop
            Character'Read (From, Next);

            -- Translate volid escape sequences
            if Next = '\' then
               Character'Read (From, Next);

               case Next is
                  when '"' =>
                     Append (Token_String_Value, '"');

                  when '\' =>
                     Append (Token_String_Value, '\');

                  when '/' =>
                     Append (Token_String_Value, '/');

                  when 'b' =>
                     Append (Token_String_Value, BS);

                  when 'f' =>
                     Append (Token_String_Value, FF);

                  when 'n' =>
                     Append (Token_String_Value, LF);

                  when 'r' =>
                     Append (Token_String_Value, CR);

                  when 't' =>
                     Append (Token_String_Value, HT);

                  when 'u' =>

                     -- Decoding UTF-16 into UTF-8 is a bit more work.
                     -- This code currently does not handle anything
                     -- outside the BMP, and fails badly on malformed
                     -- escape sequences.
                     Hex_String := Null_Unbounded_String;
                     for Digit in 1 .. 4 loop
                        Character'Read (From, Next);
                        Append (Hex_String, Next);
                     end loop;
                     Hex_Value := Natural'Value ("16#" & To_String (Hex_String) & "#");
                     if Hex_Value < 16#7F# then
                        -- 7-bit characters just pass through unchanged
                        Append (Token_String_Value, Character'Val (Hex_Value));
                     else
                        -- 8-bit characters are encoded in two bytes
                        Append (Token_String_Value, Character'Val (16#C0# + (Hex_Value  /  2 ** 6)));
                        Append (Token_String_Value, Character'Val (16#80# + (Hex_Value rem 2 ** 6)));
                     end if;

                  when others =>
                     Append (Token_String_Value, Next);

               end case;

            elsif Next < Space then
               Syntax_Fail ("control character" & Integer'Image (Character'Pos (Next)) & " in string");
               if When_Error = Error_Report then
                  return;
               end if;
            elsif Next = '"' then
               To := (Is_A => Token_String, String_Value => Token_String_Value);
               return;
            else
               Append (Token_String_Value, Next);
            end if;

         end loop;

      end Gather_String;

      ------------------------------------------------------------------------

      -- Gather a number value
      procedure Gather_Number is

         use Ada.Strings.Unbounded;

         Num_String     : Unbounded_String := Null_Unbounded_String & Next;

      begin  -- Gather_Number

         -- Whatever ends a number might be a valid token, sigh.  Only
         -- case where pushback is necessary.  From the grammar, a
         -- number is a value, and only three things can legally
         -- follow a value, so those are the only things we push back.
         loop
            Character'Read (From, Next);
            case Next is
               when '0' .. '9' | '.' | 'e' | 'E' | '+' | '-' =>
                  Append (Num_String, Next);

               when ',' =>
                  Pushback_Token := (Is_A => Token_Comma);
                  exit;

               when ']' =>
                  Pushback_Token := (Is_A => Token_Close_Bracket);
                  exit;

               when '}' =>
                  Pushback_Token := (Is_A => Token_Close_Brace);
                  exit;

               when others =>
                  -- Usually whitespace, but whatever it is we don't care.
                  exit;
            end case;
         end loop;

         -- Got our number, convert it to binary and return it
         To := (Is_A => Token_Number, Number_Value => Long_Float'Value (To_String (Num_String)));
      end Gather_Number;

      ------------------------------------------------------------------------

   begin  -- Get_Token

      -- This is a very simple lexer, due to the fact that JSON is a very simple format

      -- First, see if a token was pushed back because it followed a
      -- number.  We assume this can be only a very small subset of
      -- possible token types.  If one was, return it and reset the
      -- pushback mechanism.
      if Pushback_Token.Is_A /= Token_None then
         To := Pushback_Token;
         Pushback_Token := (Is_A => Token_None);
         return;
      end if;

      loop
         Character'Read (From, Next);
         case Next is
            when HT | CR | Space =>
               null;  -- skip whitespace

            when LF =>
               Line_Number := Line_Number + 1;  -- skip newlines as whitespace (doesn't work right on Mac, too bad)

            when '#' =>
               Skip_To_Newline;  -- # comments are used in YAML, so why not here too

            when '/' =>
               Character'Read (From, Next);
               if Next = '/' then
                  Skip_To_Newline;  -- // comments are used in YAML, so why not here too
               elsif Next = '*' then
                  Skip_To_Star_Slash;
               else
                  Syntax_Fail ("/");
                  if When_Error = Error_Report then
                     return;
                  end if;
               end if;

            when ',' =>
               To := (Is_A => Token_Comma);
               return;

            when ':' =>
               To := (Is_A => Token_Colon);
               return;

            when '[' =>
               To := (Is_A => Token_Open_Bracket);
               return;

            when ']' =>
               To := (Is_A => Token_Close_Bracket);
               return;

            when '{' =>
               To := (Is_A => Token_Open_Brace);
               return;

            when '}' =>
               To := (Is_A => Token_Close_Brace);
               return;

            when 'n' =>
               To := (Is_A => Token_Null);
               Character'Read (From, Next);
               if Next /= 'u' then
                  Syntax_Fail ("n" & Next);
               end if;
               Character'Read (From, Next);
               if Next /= 'l' then
                  Syntax_Fail ("nu" & Next);
               end if;
               Character'Read (From, Next);
               if Next /= 'l' then
                  Syntax_Fail ("nul" & Next);
               end if;
               return;

            when 'f' =>
               To := (Is_A => Token_False);
               Character'Read (From, Next);
               if Next /= 'a' then
                  Syntax_Fail ("f" & Next);
               end if;
               Character'Read (From, Next);
               if Next /= 'l' then
                  Syntax_Fail ("fa" & Next);
               end if;
               Character'Read (From, Next);
               if Next /= 's' then
                  Syntax_Fail ("fal" & Next);
               end if;
               Character'Read (From, Next);
               if Next /= 'e' then
                  Syntax_Fail ("fals" & Next);
               end if;
               return;

            when 't' =>
               To := (Is_A => Token_True);
               Character'Read (From, Next);
               if Next /= 'r' then
                  Syntax_Fail ("t" & Next);
               end if;
               Character'Read (From, Next);
               if Next /= 'u' then
                  Syntax_Fail ("tr" & Next);
               end if;
               Character'Read (From, Next);
               if Next /= 'e' then
                  Syntax_Fail ("tru" & Next);
               end if;
               return;

            when '"' =>
               Gather_String;
               return;

            when '-' | '0' .. '9' =>
               Gather_Number;
               return;

            when others =>
               Syntax_Fail (Next & "");  -- hack to convert Next to a string
               if When_Error = Error_Report then
                  return;
               end if;
         end case;

      end loop;

   end Get_Token;

end JSON.Reader.Lexer;
