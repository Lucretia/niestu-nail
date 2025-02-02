
--
-- Strings -- String manipulation utility package
--


--
-- Standard packages
with Ada.Strings.Unbounded;


package Strings is
pragma Preelaborate;

------------------------------------------------------------------------------
--
-- Public constants
--
------------------------------------------------------------------------------

   -- Give this one a shorter local name
   Null_UString : Ada.Strings.Unbounded.Unbounded_String renames Ada.Strings.Unbounded.Null_Unbounded_String;

------------------------------------------------------------------------------
--
-- Public types
--
------------------------------------------------------------------------------

   -- Give this one a shorter local name, since it's used so much
   subtype UString is Ada.Strings.Unbounded.Unbounded_String;

------------------------------------------------------------------------------
--
-- Public subroutines
--
------------------------------------------------------------------------------

   -- Version of the 'Image attribute that does not include the leading space
   -- for positive values
   function Img (Num : in integer) return string;

   -- Return number padded on the left with Pad out to Width; returns full
   -- number if it's wider than Width.  Note that negative integers with
   -- non-blank Pad values don't work well.
   function Img (Number : in integer;
                 Width  : in positive;
                 Pad    : in character := ' ') return string;

   -- Like regular Trim, but always trims both ends
   function BTrim (Source : in string) return string;
   pragma Inline (BTrim);

   -- Like regular Trim, but always trims on the left
   function LTrim (Source : in string) return string;
   pragma Inline (LTrim);

   -- Like regular Trim, but always trims on the right
   function RTrim (Source : in string) return string;
   pragma Inline (RTrim);

   -- Convenient for avoiding "use Ada.Strings.Unbounded"
   function Equal (Left, Right : in UString) return boolean;

   -- Rename these to shorter names, since we use them so much
   function S  (Source : in Ada.Strings.Unbounded.Unbounded_String) return string
     renames Ada.Strings.Unbounded.To_String;

   function US (Source : in string) return Ada.Strings.Unbounded.Unbounded_String
     renames Ada.Strings.Unbounded.To_Unbounded_String;

   -- Re-export these useful functions, so that callers don't always have to
   -- use Ada.Strings.Unbounded directly just to do simple operations
   function "&" (Left, Right : in Ada.Strings.Unbounded.Unbounded_String)
                return Ada.Strings.Unbounded.Unbounded_String
     renames Ada.Strings.Unbounded."&";

   function "&" (Left  : in Ada.Strings.Unbounded.Unbounded_String;
                 Right : in string)
                return Ada.Strings.Unbounded.Unbounded_String
     renames Ada.Strings.Unbounded."&";

   function "&" (Left  : in string;
                 Right : in Ada.Strings.Unbounded.Unbounded_String)
                return Ada.Strings.Unbounded.Unbounded_String
     renames Ada.Strings.Unbounded."&";

   function "&" (Left  : in Ada.Strings.Unbounded.Unbounded_String;
                 Right : in character)
                return Ada.Strings.Unbounded.Unbounded_String
     renames Ada.Strings.Unbounded."&";

   function "&" (Left  : in character;
                 Right : in Ada.Strings.Unbounded.Unbounded_String)
                return Ada.Strings.Unbounded.Unbounded_String
     renames Ada.Strings.Unbounded."&";

   ---------------------------------------------------------------------------

end Strings;
