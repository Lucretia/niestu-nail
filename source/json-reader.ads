
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
with Ada.Streams;


package JSON.Reader is

   -- Parse a JSON stream
   function Parse (From : access Ada.Streams.Root_Stream_Type'Class) return Val_Ptr;

end JSON.Reader;
