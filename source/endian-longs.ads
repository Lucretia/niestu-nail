
-- Byte re-ordering routines for "long" (64-bit) values
--
-- Chip Richards, Phoenix AZ, April 2007


generic
   type Long_Type is (<>);
package Endian.Longs is

   ---------------------------------------------------------------------------

   -- Swap the bytes, no matter the host ordering
   function Swap_Bytes  (Value : Long_Type) return Long_Type;

   -- Swap bytes if host is little-endian, or no-op if it's big-endian
   function To_Big      (Value : Long_Type) return Long_Type;

   -- Swap bytes if host is big-endian, or no-op if it's little-endian
   function To_Little   (Value : Long_Type) return Long_Type;

   -- Swap bytes if host is little-endian, or no-op if it's big-endian
   function From_Big    (Value : Long_Type) return Long_Type renames To_Big;

   -- Swap bytes if host is big-endian, or no-op if it's little-endian
   function From_Little (Value : Long_Type) return Long_Type renames To_Little;

   ---------------------------------------------------------------------------

   -- Swap the bytes in place, no matter the host ordering
   procedure Swap_Bytes  (Value : in out Long_Type);

   -- Swap bytes in place if host is little-endian, or no-op if it's big-endian
   procedure To_Big      (Value : in out Long_Type);

   -- Swap bytes in place if host is big-endian, or no-op if it's little-endian
   procedure To_Little   (Value : in out Long_Type);

   -- Swap bytes in place if host is little-endian, or no-op if it's big-endian
   procedure From_Big    (Value : in out Long_Type) renames To_Big;

   -- Swap bytes in place if host is big-endian, or no-op if it's little-endian
   procedure From_Little (Value : in out Long_Type) renames To_Little;

   ---------------------------------------------------------------------------

   pragma Inline (Swap_Bytes, To_Big, To_Little, From_Big, From_Little);

   ---------------------------------------------------------------------------

end Endian.Longs;
