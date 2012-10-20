
-- Byte re-ordering routines for "long" (64-bit) values
--
-- Chip Richards, Phoenix AZ, April 2007


with Ada.Unchecked_Conversion;


package body Endian.Longs is

   ---------------------------------------------------------------------------

   type Eight_Bytes is record
      B0 : Binary.Byte;
      B1 : Binary.Byte;
      B2 : Binary.Byte;
      B3 : Binary.Byte;
      B4 : Binary.Byte;
      B5 : Binary.Byte;
      B6 : Binary.Byte;
      B7 : Binary.Byte;
   end record;
   for Eight_Bytes'Size use Binary.Long_Bits;

   for Eight_Bytes use record
      B0 at 0 range 0 .. 7;
      B1 at 1 range 0 .. 7;
      B2 at 2 range 0 .. 7;
      B3 at 3 range 0 .. 7;
      B4 at 4 range 0 .. 7;
      B5 at 5 range 0 .. 7;
      B6 at 6 range 0 .. 7;
      B7 at 7 range 0 .. 7;
   end record;

   ---------------------------------------------------------------------------

   -- Swap the bytes, no matter the host ordering
   function Swap_Bytes (Value : Long_Type) return Long_Type is

      L : Eight_Bytes;
      T : Eight_Bytes;

      function VTT is new Ada.Unchecked_Conversion (Long_Type, Eight_Bytes);
      function TTV is new Ada.Unchecked_Conversion (Eight_Bytes, Long_Type);

   begin  -- Swap_Bytes
      T := VTT (Value);
      L.B0 := T.B7;
      L.B1 := T.B6;
      L.B2 := T.B5;
      L.B3 := T.B4;
      L.B4 := T.B3;
      L.B5 := T.B2;
      L.B6 := T.B1;
      L.B7 := T.B0;
      return TTV (L);
   end Swap_Bytes;

   ---------------------------------------------------------------------------

   -- Swap bytes if host is little-endian, or no-op if it's big-endian
   function To_Big (Value : Long_Type) return Long_Type is
   begin  -- To_Big
      if System_Byte_Order /= High_Order_First then
         return Swap_Bytes (Value);
      else
         return Value;
      end if;
   end To_Big;

   ---------------------------------------------------------------------------

   -- Swap bytes if host is big-endian, or no-op if it's little-endian
   function To_Little (Value : Long_Type) return Long_Type is
   begin  -- To_Little
      if System_Byte_Order /= Low_Order_First then
         return Swap_Bytes (Value);
      else
         return Value;
      end if;
   end To_Little;

   ---------------------------------------------------------------------------

   -- Swap the bytes, no matter the host ordering
   procedure Swap_Bytes (Value : in out Long_Type) is

      L : Eight_Bytes;
      T : Eight_Bytes;

      function VTT is new Ada.Unchecked_Conversion (Long_Type, Eight_Bytes);
      function TTV is new Ada.Unchecked_Conversion (Eight_Bytes, Long_Type);

   begin  -- Swap_Bytes
      T := VTT (Value);
      L.B0 := T.B7;
      L.B1 := T.B6;
      L.B2 := T.B5;
      L.B3 := T.B4;
      L.B4 := T.B3;
      L.B5 := T.B2;
      L.B6 := T.B1;
      L.B7 := T.B0;
      Value := TTV (L);
   end Swap_Bytes;

   ---------------------------------------------------------------------------

   -- Swap bytes if host is little-endian, or no-op if it's big-endian
   procedure To_Big (Value : in out Long_Type) is
   begin  -- To_Big
      if System_Byte_Order /= High_Order_First then
         Swap_Bytes (Value);
      end if;
   end To_Big;

   ---------------------------------------------------------------------------

   -- Swap bytes if host is big-endian, or no-op if it's little-endian
   procedure To_Little (Value : in out Long_Type) is
   begin  -- To_Little
      if System_Byte_Order /= Low_Order_First then
         Swap_Bytes (Value);
      end if;
   end To_Little;

   ---------------------------------------------------------------------------

end Endian.Longs;
