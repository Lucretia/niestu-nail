
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
with Ada.Containers.Hashed_Maps;
with Ada.Containers.Vectors;
with Ada.Strings.Unbounded;
with Ada.Strings.Unbounded.Hash;


package JSON is

   -- Set up for our nested types
   type Val is tagged null record;
   type Val_Ptr is access all Val'Class;

   -- Declare our two container types
   package Arrays is new Ada.Containers.Vectors (Index_Type   => Positive,
                                                 Element_Type => Val_Ptr);

   package Objects is new Ada.Containers.Hashed_Maps (Key_Type => Ada.Strings.Unbounded.Unbounded_String,
                                                      Element_Type => Val_Ptr,
                                                      Hash => Ada.Strings.Unbounded.Hash,
                                                      Equivalent_Keys => Ada.Strings.Unbounded."=");

   -- Value type classifier
   type Value_Type is ( Val_None, Val_Arr, Val_Obj, Val_Str, Val_Num, Val_Null, Val_False, Val_True );
   function Which (V : Val_Ptr) return Value_Type;

   -- Data fetch functions
   function Data (V : Val_Ptr) return Arrays.Vector;
   function Data (V : Val_Ptr) return Objects.Map;
   function Data (V : Val_Ptr) return Ada.Strings.Unbounded.Unbounded_String;
   function Data (V : Val_Ptr) return Long_Float;
   function Data (V : Val_Ptr) return Boolean;

   -- The various value types
   type Str is new Val with record
      Str : Ada.Strings.Unbounded.Unbounded_String;
   end record;
   type Str_Ptr is access all Str;

   type Num is new Val with record
      Num : Long_Float;
   end record;
   type Num_Ptr is access all Num;

   type Constant_Type is ( Con_True, Con_False, Con_Null );
   type Con is new Val with record
      Con : Constant_Type;
   end record;
   type Con_Ptr is access all Con;

   type Arr is new Val with record
      Arr : Arrays.Vector;
   end record;
   type Arr_Ptr is access all Arr;

   type Obj is new Val with record
      Obj : Objects.Map;
   end record;
   type Obj_Ptr is access all Obj;

   -- Master switch telling how errors are handled.  Ignore means
   -- errors are ignored, leading to unpredictable and almost
   -- certainly invalid output.  Report means that Token_Invalid is
   -- returned.  Fail means a Syntax_Error exception is raised.
   type Error_Handling is ( Error_Ignore, Error_Report, Error_Fail );
   When_Error : Error_Handling := Error_Ignore;

   Syntax_Error : exception;  -- raised on error if When_Error is set to Error_Fail

end JSON;
