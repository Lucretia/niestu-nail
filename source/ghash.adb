
--
-- A simple Perl-style hash-table package
--


--
-- Standard packages
with
  Ada.Strings.Unbounded,
  Ada.Unchecked_Deallocation;

use
  Ada.Strings.Unbounded;

------------------------------------------------------------------------------
--
-- NOTE:  This implementation is dependent on GNAT-specific services
--
------------------------------------------------------------------------------
with GNAT.HTable;

package body GHash is

------------------------------------------------------------------------------
--
-- Package constants
--
------------------------------------------------------------------------------

   Hash_Table_Size:  constant := 4096;  -- arbitrary, tunable

------------------------------------------------------------------------------
--
-- Package types
--
------------------------------------------------------------------------------

   subtype Hash_Range  is natural range 0 .. Hash_Table_Size - 1;
   subtype Key_Value   is Unbounded_String;

   type Table_Rec;
   type Value_Ptr is access Table_Rec;
   type Table_Rec is record
      Key:   Key_Value;
      Next:  Value_Ptr;
      Data:  Element;
   end record;

------------------------------------------------------------------------------
--
-- Package subroutines
--
------------------------------------------------------------------------------

   -- Forward declarations of local support routines
   procedure Set_Next_Ptr (E : Value_Ptr; Next : Value_Ptr);
   function  Get_Next_Ptr (E : Value_Ptr) return Value_Ptr;
   function  Get_Key_Val  (E : Value_Ptr) return Key_Value;
   function  UStrHash     (F : Key_Value) return Hash_Range;

   ---------------------------------------------------------------------------

   -- Instantiate the generic Static_HTable package and the supporting
   -- simple Hash function

   package HT is new GNAT.HTable.Static_HTable
     (
      Header_Num => Hash_Range,
      Element    => Table_Rec,
      Elmt_Ptr   => Value_Ptr,
      Null_Ptr   => null,
      Set_Next   => Set_Next_Ptr,
      Next       => Get_Next_Ptr,
      Key        => Key_Value,
      Get_Key    => Get_Key_Val,
      Hash       => UStrHash,
      Equal      => "="
     );
   use HT;

   ---------------------------------------------------------------------------

   -- Instantiate the unchecked deallocation procedure
   procedure Free is new Ada.Unchecked_Deallocation (Table_Rec, Value_Ptr);

   ---------------------------------------------------------------------------

   procedure Set_Next_Ptr (E : Value_Ptr; Next : Value_Ptr) is
   begin  -- Set_Next_Ptr
      E.Next := Next;
   end Set_Next_Ptr;

   ---------------------------------------------------------------------------

   function  Get_Next_Ptr (E : Value_Ptr) return Value_Ptr is
   begin  -- Get_Next_Ptr
      return E.Next;
   end Get_Next_Ptr;

   ---------------------------------------------------------------------------

   function  Get_Key_Val  (E : Value_Ptr) return Key_Value is
   begin  -- Get_Key_Val
      return E.Key;
   end Get_Key_Val;

   ---------------------------------------------------------------------------

   function  UStrHash     (F : Key_Value) return Hash_Range is
      function StrHash is new GNAT.HTable.Hash (Hash_Range);
   begin  -- UStrHash
      return StrHash (To_String (F));
   end UStrHash;

------------------------------------------------------------------------------
--
-- Exported subroutines
--
------------------------------------------------------------------------------

   procedure Set    (Key:    in string;
                     Value:  in Element) is

      Got:  Value_Ptr;

   begin
      Got := Get (To_Unbounded_String (Key));
      if Got = null then
         Set (new Table_Rec'(To_Unbounded_String (Key), null, Value));
      else
         Got.Data := Value;
      end if;
   end Set;

   ---------------------------------------------------------------------------

   function  Get    (Key: string) return Element is

      Got:  Value_Ptr;

   begin
      Got := Get (To_Unbounded_String (Key));
      if Got = null then
         return No_Element;
      else
         return Got.Data;
      end if;
   end Get;

   ---------------------------------------------------------------------------

   function  Exists (Key: string) return boolean is

      Got:  Value_Ptr;

   begin
      Got := Get (To_Unbounded_String (Key));
      return Got /= null;
   end Exists;

   ---------------------------------------------------------------------------

   procedure Remove (Key: string) is

      Got:  Value_Ptr;

   begin
      Got := Get (To_Unbounded_String (Key));
      HT.Remove (To_Unbounded_String (Key));
      if Got /= null then
         Free (Got);
      end if;
   end Remove;

   ---------------------------------------------------------------------------

   function  First_Key return string is

      Got:  Value_Ptr;

   begin
      Got := Get_First;
      if Got = null then
         return "";
      else
         return To_String (Got.Key);
      end if;
   end First_Key;

   ---------------------------------------------------------------------------

   function  Next_Key  return string is

      Got:  Value_Ptr;

   begin
      Got := Get_Next;
      if Got = null then
         return "";
      else
         return To_String (Got.Key);
      end if;
   end Next_Key;

   ---------------------------------------------------------------------------

   function  First_Val return Element is

      Got:  Value_Ptr;

   begin
      Got := Get_First;
      if Got = null then
         return No_Element;
      else
         return Got.Data;
      end if;
   end First_Val;

   ---------------------------------------------------------------------------

   function  Next_Val  return Element is

      Got:  Value_Ptr;

   begin
      Got := Get_Next;
      if Got = null then
         return No_Element;
      else
         return Got.Data;
      end if;
   end Next_Val;

   ---------------------------------------------------------------------------

   function  Count return natural is

      Got:     Value_Ptr;
      Result:  natural;

   begin
      Result := 0;
      Got := Get_First;
      while Got /= null loop
         Result := Result + 1;
         Got := Get_Next;
      end loop;
      return Result;
   end Count;

   ---------------------------------------------------------------------------

end GHash;
