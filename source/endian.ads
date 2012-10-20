
-- Parent package for big- vs. little-endian byte-ordering services
--
-- Chip Richards, Phoenix AZ, April 2007


-- Local library packages
with Binary;


package Endian is
   pragma Elaborate_Body;

   ---------------------------------------------------------------------------

   type Byte_Order is (High_Order_First, Low_Order_First);

   ---------------------------------------------------------------------------

   -- This is the order defined as "network byte order" by the widely-used BSD
   -- networking routines, and by common practice on the Internet.
   Network_Byte_Order : constant Byte_Order := High_Order_First;

   ---------------------------------------------------------------------------

   -- Returns the current system's byte ordering configuration.
   function System_Byte_Order return Byte_Order;
   pragma Inline (System_Byte_Order);

   ---------------------------------------------------------------------------

private

   -- This type is needed by the byte-order test in the Endian package body
   -- init code; otherwise, it could just go in the package body for
   -- Endian.Two_Byte
   type Two_Bytes is record
      B0 : Binary.Byte;
      B1 : Binary.Byte;
   end record;
   for Two_Bytes'Size use Binary.Short_Bits;

   for Two_Bytes use record
      B0 at 0 range 0 .. 7;
      B1 at 1 range 0 .. 7;
   end record;

end Endian;
