
-- Byte re-ordering routines for "short" (16-bit) values
--
-- Chip Richards, Phoenix AZ, April 2007


-- Standard packages
with Ada.Unchecked_Conversion;


package body Endian.Shorts is

   ---------------------------------------------------------------------------

   -- Swap the bytes, no matter the host ordering
   function Swap_Bytes (Value : Short_Type) return Short_Type is

      S : Two_Bytes;
      T : Two_Bytes;

      function VTT is new Ada.Unchecked_Conversion (Short_Type, Two_Bytes);
      function TTV is new Ada.Unchecked_Conversion (Two_Bytes, Short_Type);

   begin  -- Swap_Bytes
      T := VTT (Value);
      S.B0 := T.B1;
      S.B1 := T.B0;
      return TTV (S);
   end Swap_Bytes;

   ---------------------------------------------------------------------------

   -- Swap bytes if host is little-endian, or no-op if it's big-endian
   function To_Big (Value : Short_Type) return Short_Type is
   begin  -- To_Big
      if System_Byte_Order /= High_Order_First then
         return Swap_Bytes (Value);
      else
         return Value;
      end if;
   end To_Big;

   ---------------------------------------------------------------------------

   -- Swap bytes if host is big-endian, or no-op if it's little-endian
   function To_Little (Value : Short_Type) return Short_Type is
   begin  -- To_Little
      if System_Byte_Order /= Low_Order_First then
         return Swap_Bytes (Value);
      else
         return Value;
      end if;
   end To_Little;

   ---------------------------------------------------------------------------

   -- Swap the bytes, no matter the host ordering
   procedure Swap_Bytes (Value : in out Short_Type) is

      S : Two_Bytes;
      T : Two_Bytes;

      function VTT is new Ada.Unchecked_Conversion (Short_Type, Two_Bytes);
      function TTV is new Ada.Unchecked_Conversion (Two_Bytes, Short_Type);

   begin  -- Swap_Bytes
      T := VTT (Value);
      S.B0 := T.B1;
      S.B1 := T.B0;
      Value := TTV (S);
   end Swap_Bytes;

   ---------------------------------------------------------------------------

   -- Swap bytes if host is little-endian, or no-op if it's big-endian
   procedure To_Big (Value : in out Short_Type) is
   begin  -- To_Big
      if System_Byte_Order /= High_Order_First then
         Swap_Bytes (Value);
      end if;
   end To_Big;

   ---------------------------------------------------------------------------

   -- Swap bytes if host is big-endian, or no-op if it's little-endian
   procedure To_Little (Value : in out Short_Type) is
   begin  -- To_Little
      if System_Byte_Order /= Low_Order_First then
         Swap_Bytes (Value);
      end if;
   end To_Little;

   ---------------------------------------------------------------------------

end Endian.Shorts;
