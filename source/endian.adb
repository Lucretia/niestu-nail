
-- Parent package for big- vs. little-endian byte-ordering services
--
-- Chip Richards, Phoenix AZ, April 2007


-- Standard packages
with Ada.Unchecked_Conversion;


package body Endian is

   ---------------------------------------------------------------------------

   -- Set to the host system's byte order during package initialization, in
   -- case an app ever needs to know.  Normally, the child package functions
   -- will be used instead of querying this directly.
   Host_Byte_Order : Byte_Order;

   ---------------------------------------------------------------------------
   --
   -- Exported subroutines
   --
   ---------------------------------------------------------------------------

   function System_Byte_Order return Byte_Order is
   begin  -- System_Byte_Order
      return Host_Byte_Order;
   end System_Byte_Order;

   ---------------------------------------------------------------------------
   --
   -- Package subroutines
   --
   ---------------------------------------------------------------------------

   -- Discover the system's byte ordering
   procedure Set_System_Byte_Order (Order : out Byte_Order) is

      use Binary;

      S : Short;
      T : Two_Bytes;

      function STT is new Ada.Unchecked_Conversion (Short, Two_Bytes);

   begin  -- Set_System_Byte_Order

      -- Set up a bit pattern that we can recognize later
      S := 16#0102#;

      -- Now stick it into a record of two consecutive bytes, with no swapping
      T := STT (S);

      -- If the first byte is the one that was originally the leftmost byte in
      -- the word, then this is a big-endian platform, otherwise little-endian
      if T.B0 = 16#01# then
         Order := High_Order_First;
      else
         Order := Low_Order_First;
      end if;

   end Set_System_Byte_Order;

   ---------------------------------------------------------------------------

begin  -- package Endian initialization code
   Set_System_Byte_Order (Host_Byte_Order);
end Endian;
