
--
-- A simple Perl-style hash-table package, generic version
--

generic
   type Element is private;
   No_Element:  Element;

package GHash is

------------------------------------------------------------------------------
--
-- Exported subroutines
--
------------------------------------------------------------------------------

   procedure Set    (Key:    in string;
                     Value:  in Element);

   function  Get    (Key: string) return Element;
   function  Exists (Key: string) return boolean;

   procedure Remove (Key: string);

   function  First_Key return string;
   function  Next_Key  return string;
   function  First_Val return Element;
   function  Next_Val  return Element;

   function  Count     return natural;

end GHash;
