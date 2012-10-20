
-- JSON -- World's simplest JSON packages
--
-- Chip Richards, NiEstu, Phoenix AZ, Winter 2011

-- The type names in this spec are deliberately short so you can use
-- "JSON.Foo" in your own code.  If you prefer longer, more
-- descriptive names, write your own damned package.  If you want a
-- full-bodied JSON suite for Ada, get Tero Koskinen's jdaughter
-- (http://hg.stronglytyped.org/jdaughter/).  See http://json.org/ for
-- details about the JSON format.

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


package body JSON is

   ---------------------------------------------------------------------------

   -- Value type classifier
   function Which (V : Val_Ptr) return Value_Type is
   begin  -- Which
      if V.all in Arr'Class then
         return Val_Arr;
      elsif V.all in Obj'Class then
         return Val_Obj;
      elsif V.all in Str'Class then
         return Val_Str;
      elsif V.all in Num'Class then
         return Val_Num;
      elsif V.all in Con'Class then
         if Con_Ptr (V).Con = Con_Null then
            return Val_Null;
         elsif Con_Ptr (V).Con = Con_False then
            return Val_False;
         elsif Con_Ptr (V).Con = Con_True then
            return Val_True;
         else
            return Val_None;
         end if;
      else
         return Val_None;
      end if;
   end Which;

   ---------------------------------------------------------------------------

   function Data (V : Val_Ptr) return Arrays.Vector is
   begin  -- Data
      return Arr_Ptr (V).Arr;
   end Data;

   ---------------------------------------------------------------------------

   function Data (V : Val_Ptr) return Objects.Map is
   begin  -- Data
      return Obj_Ptr (V).Obj;
   end Data;

   ---------------------------------------------------------------------------

   function Data (V : Val_Ptr) return Ada.Strings.Unbounded.Unbounded_String is
   begin  -- Data
      return Str_Ptr (V).Str;
   end Data;

   ---------------------------------------------------------------------------

   function Data (V : Val_Ptr) return Long_Float is
   begin  -- Data
      return Num_Ptr (V).Num;
   end Data;

   ---------------------------------------------------------------------------

   function Data (V : Val_Ptr) return Boolean is
   begin  -- Data
      if Con_Ptr (V).Con = Con_False then
         return False;
      elsif Con_Ptr (V).Con = Con_True then
         return True;
      else
         raise Program_Error with "not a JSON boolean value";
      end if;
   end Data;

   ---------------------------------------------------------------------------

end JSON;
