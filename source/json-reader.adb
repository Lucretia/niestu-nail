
-- JSON -- World's simplest JSON packages
--
-- Chip Richards, NiEstu, Phoenix AZ, Winter 2011

-- This is the reader portion of this JSON suite.  It reads Unicode
-- from a stream and parses it according to RFC 4627 and the rules
-- found at http://json.org/

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
with ada.text_io;            use ada.text_io;  -- for debug/development
with ada.strings.unbounded;  use ada.strings.unbounded;

with JSON.Reader.Lexer;

package body JSON.Reader is

   -- Parse a JSON stream
   function Parse (From : access Ada.Streams.Root_Stream_Type'Class) return Val_Ptr is

      use type Lexer.Token_Type;

      T : Lexer.Token;

      ------------------------------------------------------------------------

      -- Dump a token to stdout
      procedure Dump is
      begin  -- Dump
         put (Lexer.Token_Type'Image (T.Is_A));
         if T.Is_A = Lexer.Token_String then
            put ("  """ & to_string (T.String_Value) & """");
         elsif T.Is_A = Lexer.Token_Number then
            put ("  " & Long_Float'Image (T.Number_Value));
         end if;
         new_line;
      end Dump;

      ------------------------------------------------------------------------

      -- Forward declaration
      function Get_Value (From : access Ada.Streams.Root_Stream_Type'Class) return Val_Ptr;

      ------------------------------------------------------------------------

      -- Parse a JSON array
      function Get_Array (From : access Ada.Streams.Root_Stream_Type'Class) return Arr_Ptr is

         Result : Arr_Ptr := new Arr'(Arr => Arrays.Empty_Vector);
         Item   : Val_Ptr;

      begin  -- Get_Array

         loop

            Item := Get_Value (From);

            if Item = null then
               if T.Is_A = Lexer.Token_Close_Bracket then
                  return Result;
               elsif T.Is_A /= Lexer.Token_Comma and then When_Error = Error_Report then
                  return null;
               end if;
            else
               Arrays.Append (Result.Arr, Item);
            end if;

         end loop;

      end Get_Array;

      ------------------------------------------------------------------------

      -- Parse a JSON object
      function Get_Object (From : access Ada.Streams.Root_Stream_Type'Class) return Obj_Ptr is

         Result : Obj_Ptr := new Obj'(Obj => Objects.Empty_Map);
         Name   : Ada.Strings.Unbounded.Unbounded_String;
         Item   : Val_Ptr;

      begin  -- Get_Object

         loop

            -- Get name
            Item := Get_Value (From);

            if Item = null then
               if T.Is_A = Lexer.Token_Close_Brace then
                  return Result;
               elsif When_Error = Error_Report then
                  return null;
               end if;
            else

               -- Save name, get colon
               Name := Str_Ptr (Item).Str;
               -- FIXME:  free this object
               Item := Get_Value (From);

               if Item = null then
                  if T.Is_A /= Lexer.Token_Colon and then When_Error = Error_Report then
                     return null;
                  end if;

                  -- Get value
                  Item := Get_Value (From);
                  if Item = null then
                     if When_Error = Error_Report then
                        return null;
                     end if;
                  else
                     Objects.Insert (Result.Obj, Name, Item);
                  end if;
               end if;
            end if;

         end loop;

      end Get_Object;

      ------------------------------------------------------------------------

      -- Parse a JSON value
      function Get_Value (From : access Ada.Streams.Root_Stream_Type'Class) return Val_Ptr is
      begin  -- Get_Value

         -- Next token determines type of value to return
         loop
            Lexer.Get_Token (From, T);

            case T.Is_A is

               when Lexer.Token_Open_Bracket =>
                  return Val_Ptr (Get_Array (From));

               when Lexer.Token_Open_Brace =>
                  return Val_Ptr (Get_Object (From));

               when Lexer.Token_String =>
                  return new Str'(Str => T.String_Value);

               when Lexer.Token_Number =>
                  return new Num'(Num => T.Number_Value);

               when Lexer.Token_Null =>
                  return new Con'(Con => Con_Null);

               when Lexer.Token_False =>
                  return new Con'(Con => Con_False);

               when Lexer.Token_True =>
                  return new Con'(Con => Con_True);

               when Lexer.Token_Comma | Lexer.Token_Colon | Lexer.Token_Close_Bracket | Lexer.Token_Close_Brace =>
                  return null;

               when Lexer.Token_Invalid =>
                  if When_Error = Error_Fail then
                     raise Syntax_Error with "JSON syntax error, line" & Positive'Image (Lexer.Line_Number);
                  elsif When_Error = Error_Report then
                     return null;
                  end if;

               when Lexer.Token_None =>
                  raise Program_Error;  -- shouldn't happen

            end case;

         end loop;

      end Get_Value;

      ------------------------------------------------------------------------

   begin  -- Parse

      return Get_Value (From);

   end Parse;

end JSON.Reader;
