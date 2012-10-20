
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


private package JSON.Reader.Lexer is

   -- The token type
   type Token_Type is ( Token_Invalid, Token_None,
                        Token_Comma, Token_Colon, Token_Open_Bracket, Token_Close_Bracket, Token_Open_Brace, Token_Close_Brace,
                        Token_String, Token_Number,
                        Token_Null, Token_False, Token_True );

   type Token (Is_A : Token_Type := Token_Invalid) is record
      case Is_A is
         when Token_String =>
            String_Value : Ada.Strings.Unbounded.Unbounded_String;

         when Token_Number =>
            Number_Value : Long_Float;

         when Token_Invalid | Token_None | Token_Comma | Token_Colon | Token_Open_Bracket | Token_Close_Bracket |
              Token_Open_Brace | Token_Close_Brace | Token_Null | Token_False | Token_True =>
            null;
      end case;
   end record;

   -- Try to count lines for better error reporting
   Line_Number : Positive := 1;

   -- Get next token from given stream
   procedure Get_Token (From  :           access Ada.Streams.Root_Stream_Type'Class;
                        To    :    out    Token);

end JSON.Reader.Lexer;
