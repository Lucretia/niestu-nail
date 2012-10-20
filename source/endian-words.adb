
-- Byte re-ordering routines for "word" (32-bit) values
--
-- Chip Richards, Phoenix AZ, April 2007


with Ada.Unchecked_Conversion;


package body Endian.Words is

   ---------------------------------------------------------------------------

   type Four_Bytes is record
      B0 : Binary.Byte;
      B1 : Binary.Byte;
      B2 : Binary.Byte;
      B3 : Binary.Byte;
   end record;
   for Four_Bytes'Size use Binary.Word_Bits;

   for Four_Bytes use record
      B0 at 0 range 0 .. 7;
      B1 at 1 range 0 .. 7;
      B2 at 2 range 0 .. 7;
      B3 at 3 range 0 .. 7;
   end record;

   ---------------------------------------------------------------------------

   -- Swap the bytes, no matter the host ordering
   function Swap_Bytes (Value : Word_Type) return Word_Type is

      W : Four_Bytes;
      T : Four_Bytes;

      function VTT is new Ada.Unchecked_Conversion (Word_Type, Four_Bytes);
      function TTV is new Ada.Unchecked_Conversion (Four_Bytes, Word_Type);

   begin  -- Swap_Bytes
      T := VTT (Value);
      W.B0 := T.B3;
      W.B1 := T.B2;
      W.B2 := T.B1;
      W.B3 := T.B0;
      return TTV (W);
   end Swap_Bytes;

   ---------------------------------------------------------------------------

   -- Swap bytes if host is little-endian, or no-op if it's big-endian
   function To_Big (Value : Word_Type) return Word_Type is
   begin  -- To_Big
      if System_Byte_Order /= High_Order_First then
         return Swap_Bytes (Value);
      else
         return Value;
      end if;
   end To_Big;

   ---------------------------------------------------------------------------

   -- Swap bytes if host is big-endian, or no-op if it's little-endian
   function To_Little (Value : Word_Type) return Word_Type is
   begin  -- To_Little
      if System_Byte_Order /= Low_Order_First then
         return Swap_Bytes (Value);
      else
         return Value;
      end if;
   end To_Little;

   ---------------------------------------------------------------------------

   -- Swap the bytes, no matter the host ordering
   procedure Swap_Bytes (Value : in out Word_Type) is

      W : Four_Bytes;
      T : Four_Bytes;

      function VTT is new Ada.Unchecked_Conversion (Word_Type, Four_Bytes);
      function TTV is new Ada.Unchecked_Conversion (Four_Bytes, Word_Type);

   begin  -- Swap_Bytes
      T := VTT (Value);
      W.B0 := T.B3;
      W.B1 := T.B2;
      W.B2 := T.B1;
      W.B3 := T.B0;
      Value := TTV (W);
   end Swap_Bytes;

   ---------------------------------------------------------------------------

   -- Swap bytes if host is little-endian, or no-op if it's big-endian
   procedure To_Big (Value : in out Word_Type) is
   begin  -- To_Big
      if System_Byte_Order /= High_Order_First then
         Swap_Bytes (Value);
      end if;
   end To_Big;

   ---------------------------------------------------------------------------

   -- Swap bytes if host is big-endian, or no-op if it's little-endian
   procedure To_Little (Value : in out Word_Type) is
   begin  -- To_Little
      if System_Byte_Order /= Low_Order_First then
         Swap_Bytes (Value);
      end if;
   end To_Little;

   ---------------------------------------------------------------------------

end Endian.Words;
