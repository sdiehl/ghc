-----------------------------------------------------------------------
-- $Id: primops.txt.pp,v 1.2 2001/08/08 10:50:36 simonmar Exp $
--
-- Primitive Operations
--
-----------------------------------------------------------------------

-- To add a new primop, you currently need to update the following files:
--
--	- this file (ghc/compiler/prelude/primops.txt.pp), which includes
--	  the type of the primop, and various other properties (its
--	  strictness attributes, whether it is defined as a macro
--	  or as out-of-line code, etc.)
--
--	- ghc/lib/std/PrelGHC.hi-boot.pp, to declare the primop
--
--	- if the primop is inline (i.e. a macro), then:
--		ghc/includes/PrimOps.h
--		ghc/compiler/nativeGen/StixPrim.lhs
--
--	- or, for an out-of-line primop:
--	        ghc/includes/PrimOps.h (just add the declaration)
--		ghc/rts/PrimOps.hc     (define it here)
--
--	- the User's Guide
--

#include "config.h"
#include "Derived.h"

-- The default attribute values which apply if you don't specify
-- other ones.  Attribute values can be True, False, or arbitrary
-- text between curly brackets.  This is a kludge to enable 
-- processors of this file to easily get hold of simple info
-- (eg, out_of_line), whilst avoiding parsing complex expressions
-- needed for strictness and usage info.

defaults
   has_side_effects = False
   out_of_line      = False
   commutable       = False
   needs_wrapper    = False
   can_fail         = False
   strictness       = { \ arity -> StrictnessInfo (replicate arity wwPrim) False }
   usage            = { nomangle other }


------------------------------------------------------------------------
--- Support for the bytecode interpreter and linker                  ---
------------------------------------------------------------------------

-- Convert an Addr# to a followable type
primop   AddrToHValueOp "addrToHValue#" GenPrimOp
   Addr# -> (# a #)

primop   MkApUpd0_Op "mkApUpd0#" GenPrimOp
   a -> (# a #)
   with
   out_of_line = True

primop  NewBCOOp "newBCO#" GenPrimOp
   ByteArr# -> ByteArr# -> Array# a -> ByteArr# -> State# s -> (# State# s, BCO# #)
   with
   has_side_effects = True
   out_of_line      = True


------------------------------------------------------------------------
--- Addr#                                                            ---
------------------------------------------------------------------------

primop   AddrGtOp  "gtAddr#"   Compare   Addr# -> Addr# -> Bool
primop   AddrGeOp  "geAddr#"   Compare   Addr# -> Addr# -> Bool
primop   AddrEqOp  "eqAddr#"   Compare   Addr# -> Addr# -> Bool
primop   AddrNeOp  "neAddr#"   Compare   Addr# -> Addr# -> Bool
primop   AddrLtOp  "ltAddr#"   Compare   Addr# -> Addr# -> Bool
primop   AddrLeOp  "leAddr#"   Compare   Addr# -> Addr# -> Bool

primop   Addr2IntOp  "addr2Int#"     GenPrimOp   Addr# -> Int#


------------------------------------------------------------------------
--- Char#                                                            ---
------------------------------------------------------------------------

primop   CharGtOp  "gtChar#"   Compare   Char# -> Char# -> Bool
primop   CharGeOp  "geChar#"   Compare   Char# -> Char# -> Bool

primop   CharEqOp  "eqChar#"   Compare
   Char# -> Char# -> Bool
   with commutable = True

primop   CharNeOp  "neChar#"   Compare
   Char# -> Char# -> Bool
   with commutable = True

primop   CharLtOp  "ltChar#"   Compare   Char# -> Char# -> Bool
primop   CharLeOp  "leChar#"   Compare   Char# -> Char# -> Bool

primop   OrdOp   "ord#"  GenPrimOp   Char# -> Int#

------------------------------------------------------------------------
--- Double#                                                          ---
------------------------------------------------------------------------

primop   DoubleGtOp ">##"   Compare   Double# -> Double# -> Bool
primop   DoubleGeOp ">=##"   Compare   Double# -> Double# -> Bool

primop DoubleEqOp "==##"   Compare
   Double# -> Double# -> Bool
   with commutable = True

primop DoubleNeOp "/=##"   Compare
   Double# -> Double# -> Bool
   with commutable = True

primop   DoubleLtOp "<##"   Compare   Double# -> Double# -> Bool
primop   DoubleLeOp "<=##"   Compare   Double# -> Double# -> Bool

primop   DoubleAddOp   "+##"   Dyadic
   Double# -> Double# -> Double#
   with commutable = True

primop   DoubleSubOp   "-##"   Dyadic   Double# -> Double# -> Double#

primop   DoubleMulOp   "*##"   Dyadic
   Double# -> Double# -> Double#
   with commutable = True

primop   DoubleDivOp   "/##"   Dyadic
   Double# -> Double# -> Double#
   with can_fail = True

primop   DoubleNegOp   "negateDouble#"  Monadic   Double# -> Double#

primop   Double2IntOp   "double2Int#"          GenPrimOp  Double# -> Int#
primop   Double2FloatOp   "double2Float#" GenPrimOp Double# -> Float#

primop   DoubleExpOp   "expDouble#"      Monadic
   Double# -> Double#
   with needs_wrapper = True

primop   DoubleLogOp   "logDouble#"      Monadic         
   Double# -> Double#
   with
   needs_wrapper = True
   can_fail = True

primop   DoubleSqrtOp   "sqrtDouble#"      Monadic  
   Double# -> Double#
   with needs_wrapper = True

primop   DoubleSinOp   "sinDouble#"      Monadic          
   Double# -> Double#
   with needs_wrapper = True

primop   DoubleCosOp   "cosDouble#"      Monadic          
   Double# -> Double#
   with needs_wrapper = True

primop   DoubleTanOp   "tanDouble#"      Monadic          
   Double# -> Double#
   with needs_wrapper = True

primop   DoubleAsinOp   "asinDouble#"      Monadic 
   Double# -> Double#
   with
   needs_wrapper = True
   can_fail = True

primop   DoubleAcosOp   "acosDouble#"      Monadic  
   Double# -> Double#
   with
   needs_wrapper = True
   can_fail = True

primop   DoubleAtanOp   "atanDouble#"      Monadic  
   Double# -> Double#
   with
   needs_wrapper = True

primop   DoubleSinhOp   "sinhDouble#"      Monadic  
   Double# -> Double#
   with needs_wrapper = True

primop   DoubleCoshOp   "coshDouble#"      Monadic  
   Double# -> Double#
   with needs_wrapper = True

primop   DoubleTanhOp   "tanhDouble#"      Monadic  
   Double# -> Double#
   with needs_wrapper = True

primop   DoublePowerOp   "**##" Dyadic  
   Double# -> Double# -> Double#
   with needs_wrapper = True

primop   DoubleDecodeOp   "decodeDouble#" GenPrimOp    
   Double# -> (# Int#, Int#, ByteArr# #)
   with out_of_line = True

------------------------------------------------------------------------
--- Float#                                                            ---
------------------------------------------------------------------------

primop   FloatGtOp  "gtFloat#"   Compare   Float# -> Float# -> Bool
primop   FloatGeOp  "geFloat#"   Compare   Float# -> Float# -> Bool

primop   FloatEqOp  "eqFloat#"   Compare
   Float# -> Float# -> Bool
   with commutable = True

primop   FloatNeOp  "neFloat#"   Compare
   Float# -> Float# -> Bool
   with commutable = True

primop   FloatLtOp  "ltFloat#"   Compare   Float# -> Float# -> Bool
primop   FloatLeOp  "leFloat#"   Compare   Float# -> Float# -> Bool

primop   FloatAddOp   "plusFloat#"      Dyadic            
   Float# -> Float# -> Float#
   with commutable = True

primop   FloatSubOp   "minusFloat#"      Dyadic      Float# -> Float# -> Float#

primop   FloatMulOp   "timesFloat#"      Dyadic    
   Float# -> Float# -> Float#
   with commutable = True

primop   FloatDivOp   "divideFloat#"      Dyadic  
   Float# -> Float# -> Float#
   with can_fail = True

primop   FloatNegOp   "negateFloat#"      Monadic    Float# -> Float#

primop   Float2IntOp   "float2Int#"      GenPrimOp  Float# -> Int#

primop   FloatExpOp   "expFloat#"      Monadic          
   Float# -> Float#
   with needs_wrapper = True

primop   FloatLogOp   "logFloat#"      Monadic          
   Float# -> Float#
   with needs_wrapper = True
        can_fail = True

primop   FloatSqrtOp   "sqrtFloat#"      Monadic          
   Float# -> Float#
   with needs_wrapper = True

primop   FloatSinOp   "sinFloat#"      Monadic          
   Float# -> Float#
   with needs_wrapper = True

primop   FloatCosOp   "cosFloat#"      Monadic          
   Float# -> Float#
   with needs_wrapper = True

primop   FloatTanOp   "tanFloat#"      Monadic          
   Float# -> Float#
   with needs_wrapper = True

primop   FloatAsinOp   "asinFloat#"      Monadic          
   Float# -> Float#
   with needs_wrapper = True
        can_fail = True

primop   FloatAcosOp   "acosFloat#"      Monadic          
   Float# -> Float#
   with needs_wrapper = True
        can_fail = True

primop   FloatAtanOp   "atanFloat#"      Monadic          
   Float# -> Float#
   with needs_wrapper = True

primop   FloatSinhOp   "sinhFloat#"      Monadic          
   Float# -> Float#
   with needs_wrapper = True

primop   FloatCoshOp   "coshFloat#"      Monadic          
   Float# -> Float#
   with needs_wrapper = True

primop   FloatTanhOp   "tanhFloat#"      Monadic          
   Float# -> Float#
   with needs_wrapper = True

primop   FloatPowerOp   "powerFloat#"      Dyadic   
   Float# -> Float# -> Float#
   with needs_wrapper = True

primop   Float2DoubleOp   "float2Double#" GenPrimOp  Float# -> Double#

primop   FloatDecodeOp   "decodeFloat#" GenPrimOp
   Float# -> (# Int#, Int#, ByteArr# #)
   with out_of_line = True

------------------------------------------------------------------------
--- Int#                                                             ---
------------------------------------------------------------------------

primop   IntAddOp    "+#"    Dyadic
   Int# -> Int# -> Int#
   with commutable = True

primop   IntSubOp    "-#"    Dyadic   Int# -> Int# -> Int#

primop   IntMulOp    "*#" 
   Dyadic   Int# -> Int# -> Int#
   with commutable = True

primop   IntQuotOp    "quotInt#"    Dyadic
   Int# -> Int# -> Int#
   with can_fail = True

primop   IntRemOp    "remInt#"    Dyadic
   Int# -> Int# -> Int#
   with can_fail = True

primop   IntGcdOp    "gcdInt#"    Dyadic   Int# -> Int# -> Int#
primop   IntNegOp    "negateInt#"    Monadic   Int# -> Int#
primop   IntAddCOp   "addIntC#"    GenPrimOp   Int# -> Int# -> (# Int#, Int# #)
primop   IntSubCOp   "subIntC#"    GenPrimOp   Int# -> Int# -> (# Int#, Int# #)
primop   IntMulCOp   "mulIntC#"    GenPrimOp   Int# -> Int# -> (# Int#, Int# #)
primop   IntGtOp  ">#"   Compare   Int# -> Int# -> Bool
primop   IntGeOp  ">=#"   Compare   Int# -> Int# -> Bool

primop   IntEqOp  "==#"   Compare
   Int# -> Int# -> Bool
   with commutable = True

primop   IntNeOp  "/=#"   Compare
   Int# -> Int# -> Bool
   with commutable = True

primop   IntLtOp  "<#"   Compare   Int# -> Int# -> Bool
primop   IntLeOp  "<=#"   Compare   Int# -> Int# -> Bool

primop   ChrOp   "chr#"   GenPrimOp   Int# -> Char#

primop   Int2WordOp "int2Word#" GenPrimOp Int# -> Word#
primop   Int2AddrOp   "int2Addr#"GenPrimOp  Int# -> Addr#
primop   Int2FloatOp   "int2Float#"      GenPrimOp  Int# -> Float#
primop   Int2DoubleOp   "int2Double#"          GenPrimOp  Int# -> Double#

primop   Int2IntegerOp    "int2Integer#"
   GenPrimOp Int# -> (# Int#, ByteArr# #)
   with out_of_line = True

primop   ISllOp   "iShiftL#" GenPrimOp  Int# -> Int# -> Int#
primop   ISraOp   "iShiftRA#" GenPrimOp Int# -> Int# -> Int#
primop   ISrlOp   "iShiftRL#" GenPrimOp Int# -> Int# -> Int#

------------------------------------------------------------------------
--- Int64#                                                           ---
------------------------------------------------------------------------

#ifdef SUPPORT_LONG_LONGS
primop   Int64ToIntegerOp   "int64ToInteger#" GenPrimOp 
   Int64# -> (# Int#, ByteArr# #)
   with out_of_line = True
#endif


------------------------------------------------------------------------
--- Integer#                                                         ---
------------------------------------------------------------------------

primop   IntegerAddOp   "plusInteger#" GenPrimOp   
   Int# -> ByteArr# -> Int# -> ByteArr# -> (# Int#, ByteArr# #)
   with commutable = True
        out_of_line = True

primop   IntegerSubOp   "minusInteger#" GenPrimOp  
   Int# -> ByteArr# -> Int# -> ByteArr# -> (# Int#, ByteArr# #)
   with out_of_line = True

primop   IntegerMulOp   "timesInteger#" GenPrimOp   
   Int# -> ByteArr# -> Int# -> ByteArr# -> (# Int#, ByteArr# #)
   with commutable = True
        out_of_line = True

primop   IntegerGcdOp   "gcdInteger#" GenPrimOp    
   Int# -> ByteArr# -> Int# -> ByteArr# -> (# Int#, ByteArr# #)
   with commutable = True
        out_of_line = True

primop   IntegerIntGcdOp   "gcdIntegerInt#" GenPrimOp
   Int# -> ByteArr# -> Int# -> Int#
   with commutable = True

primop   IntegerDivExactOp   "divExactInteger#" GenPrimOp
   Int# -> ByteArr# -> Int# -> ByteArr# -> (# Int#, ByteArr# #)
   with out_of_line = True

primop   IntegerQuotOp   "quotInteger#" GenPrimOp
   Int# -> ByteArr# -> Int# -> ByteArr# -> (# Int#, ByteArr# #)
   with out_of_line = True

primop   IntegerRemOp   "remInteger#" GenPrimOp
   Int# -> ByteArr# -> Int# -> ByteArr# -> (# Int#, ByteArr# #)
   with out_of_line = True

primop   IntegerCmpOp   "cmpInteger#"   GenPrimOp  
   Int# -> ByteArr# -> Int# -> ByteArr# -> Int#
   with needs_wrapper = True

primop   IntegerCmpIntOp   "cmpIntegerInt#" GenPrimOp
   Int# -> ByteArr# -> Int# -> Int#
   with needs_wrapper = True

primop   IntegerQuotRemOp   "quotRemInteger#" GenPrimOp
   Int# -> ByteArr# -> Int# -> ByteArr# -> (# Int#, ByteArr#, Int#, ByteArr# #)
   with can_fail = True
        out_of_line = True

primop   IntegerDivModOp    "divModInteger#"  GenPrimOp
   Int# -> ByteArr# -> Int# -> ByteArr# -> (# Int#, ByteArr#, Int#, ByteArr# #)
   with can_fail = True
        out_of_line = True

primop   Integer2IntOp   "integer2Int#"    GenPrimOp
   Int# -> ByteArr# -> Int#
   with needs_wrapper = True

primop   Integer2WordOp   "integer2Word#"   GenPrimOp
   Int# -> ByteArr# -> Word#
   with needs_wrapper = True

#ifdef SUPPORT_LONG_LONGS
primop   IntegerToInt64Op   "integerToInt64#" GenPrimOp
   Int# -> ByteArr# -> Int64#

primop   IntegerToWord64Op   "integerToWord64#" GenPrimOp
   Int# -> ByteArr# -> Word64#
#endif

primop   IntegerAndOp  "andInteger#" GenPrimOp
   Int# -> ByteArr# -> Int# -> ByteArr# -> (# Int#, ByteArr# #)
   with out_of_line = True

primop   IntegerOrOp  "orInteger#" GenPrimOp
   Int# -> ByteArr# -> Int# -> ByteArr# -> (# Int#, ByteArr# #)
   with out_of_line = True

primop   IntegerXorOp  "xorInteger#" GenPrimOp
   Int# -> ByteArr# -> Int# -> ByteArr# -> (# Int#, ByteArr# #)
   with out_of_line = True

primop   IntegerComplementOp  "complementInteger#" GenPrimOp
   Int# -> ByteArr# -> (# Int#, ByteArr# #)
   with out_of_line = True

------------------------------------------------------------------------
--- Word#                                                            ---
------------------------------------------------------------------------

primop   WordAddOp   "plusWord#"   Dyadic   Word# -> Word# -> Word#
   with commutable = True

primop   WordSubOp   "minusWord#"   Dyadic   Word# -> Word# -> Word#

primop   WordMulOp   "timesWord#"   Dyadic   Word# -> Word# -> Word#
   with commutable = True

primop   WordQuotOp   "quotWord#"   Dyadic   Word# -> Word# -> Word#
   with can_fail = True

primop   WordRemOp   "remWord#"   Dyadic   Word# -> Word# -> Word#
   with can_fail = True

primop   AndOp   "and#"   Dyadic   Word# -> Word# -> Word#
   with commutable = True

primop   OrOp   "or#"   Dyadic   Word# -> Word# -> Word#
   with commutable = True

primop   XorOp   "xor#"   Dyadic   Word# -> Word# -> Word#
   with commutable = True

primop   NotOp   "not#"   Monadic   Word# -> Word#

primop   SllOp   "shiftL#"   GenPrimOp   Word# -> Int# -> Word#

primop   SrlOp   "shiftRL#"   GenPrimOp   Word# -> Int# -> Word#

primop   Word2IntOp   "word2Int#"   GenPrimOp   Word# -> Int#

primop   Word2IntegerOp   "word2Integer#"   GenPrimOp 
   Word# -> (# Int#, ByteArr# #)
   with out_of_line = True

primop   WordGtOp   "gtWord#"   Compare   Word# -> Word# -> Bool
primop   WordGeOp   "geWord#"   Compare   Word# -> Word# -> Bool
primop   WordEqOp   "eqWord#"   Compare   Word# -> Word# -> Bool
primop   WordNeOp   "neWord#"   Compare   Word# -> Word# -> Bool
primop   WordLtOp   "ltWord#"   Compare   Word# -> Word# -> Bool
primop   WordLeOp   "leWord#"   Compare   Word# -> Word# -> Bool

------------------------------------------------------------------------
--- Word64#                                                          ---
------------------------------------------------------------------------

#ifdef SUPPORT_LONG_LONGS
primop   Word64ToIntegerOp   "word64ToInteger#" GenPrimOp
   Word64# -> (# Int#, ByteArr# #)
   with out_of_line = True
#endif

------------------------------------------------------------------------
--- Explicitly sized Int# and Word#                                  ---
------------------------------------------------------------------------

primop   IntToInt8Op       "intToInt8#"       Monadic   Int# -> Int#
primop   IntToInt16Op      "intToInt16#"      Monadic   Int# -> Int#
primop   IntToInt32Op      "intToInt32#"      Monadic   Int# -> Int#
primop   WordToWord8Op     "wordToWord8#"     Monadic   Word# -> Word#
primop   WordToWord16Op    "wordToWord16#"    Monadic   Word# -> Word#
primop   WordToWord32Op    "wordToWord32#"    Monadic   Word# -> Word#

------------------------------------------------------------------------
--- Arrays                                                           ---
------------------------------------------------------------------------

primop  NewArrayOp "newArray#" GenPrimOp
   Int# -> a -> State# s -> (# State# s, MutArr# s a #)
   with
   strictness  = { \ arity -> StrictnessInfo [wwPrim, wwLazy, wwPrim] False }
   usage       = { mangle NewArrayOp [mkP, mkM, mkP] mkM }
   out_of_line = True

primop  NewByteArrayOp_Char "newByteArray#" GenPrimOp
   Int# -> State# s -> (# State# s, MutByteArr# s #)
   with out_of_line = True

primop  NewPinnedByteArrayOp_Char "newPinnedByteArray#" GenPrimOp
   Int# -> State# s -> (# State# s, MutByteArr# s #)
   with out_of_line = True

primop  ByteArrayContents_Char "byteArrayContents#" GenPrimOp
   ByteArr# -> Addr#

primop IndexByteArrayOp_Char "indexCharArray#" GenPrimOp
   ByteArr# -> Int# -> Char#

primop IndexByteArrayOp_WideChar "indexWideCharArray#" GenPrimOp
   ByteArr# -> Int# -> Char#

primop IndexByteArrayOp_Int "indexIntArray#" GenPrimOp
   ByteArr# -> Int# -> Int#

primop IndexByteArrayOp_Word "indexWordArray#" GenPrimOp
   ByteArr# -> Int# -> Word#

primop IndexByteArrayOp_Addr "indexAddrArray#" GenPrimOp
   ByteArr# -> Int# -> Addr#

primop IndexByteArrayOp_Float "indexFloatArray#" GenPrimOp
   ByteArr# -> Int# -> Float#

primop IndexByteArrayOp_Double "indexDoubleArray#" GenPrimOp
   ByteArr# -> Int# -> Double#

primop IndexByteArrayOp_StablePtr "indexStablePtrArray#" GenPrimOp
   ByteArr# -> Int# -> StablePtr# a

primop IndexByteArrayOp_Int8 "indexInt8Array#" GenPrimOp
   ByteArr# -> Int# -> Int#

primop IndexByteArrayOp_Int16 "indexInt16Array#" GenPrimOp
   ByteArr# -> Int# -> Int#

primop IndexByteArrayOp_Int32 "indexInt32Array#" GenPrimOp
   ByteArr# -> Int# -> Int#

#ifdef SUPPORT_LONG_LONGS
primop IndexByteArrayOp_Int64 "indexInt64Array#" GenPrimOp
   ByteArr# -> Int# -> Int64#
#endif

primop IndexByteArrayOp_Word8 "indexWord8Array#" GenPrimOp
   ByteArr# -> Int# -> Word#

primop IndexByteArrayOp_Word16 "indexWord16Array#" GenPrimOp
   ByteArr# -> Int# -> Word#

primop IndexByteArrayOp_Word32 "indexWord32Array#" GenPrimOp
   ByteArr# -> Int# -> Word#

#ifdef SUPPORT_LONG_LONGS
primop IndexByteArrayOp_Word64 "indexWord64Array#" GenPrimOp
   ByteArr# -> Int# -> Word64#
#endif


primop  ReadByteArrayOp_Char "readCharArray#" GenPrimOp
   MutByteArr# s -> Int# -> State# s -> (# State# s, Char# #)

primop  ReadByteArrayOp_WideChar "readWideCharArray#" GenPrimOp
   MutByteArr# s -> Int# -> State# s -> (# State# s, Char# #)

primop  ReadByteArrayOp_Int "readIntArray#" GenPrimOp
   MutByteArr# s -> Int# -> State# s -> (# State# s, Int# #)

primop  ReadByteArrayOp_Word "readWordArray#" GenPrimOp
   MutByteArr# s -> Int# -> State# s -> (# State# s, Word# #)

primop  ReadByteArrayOp_Addr "readAddrArray#" GenPrimOp
   MutByteArr# s -> Int# -> State# s -> (# State# s, Addr# #)

primop  ReadByteArrayOp_Float "readFloatArray#" GenPrimOp
   MutByteArr# s -> Int# -> State# s -> (# State# s, Float# #)

primop  ReadByteArrayOp_Double "readDoubleArray#" GenPrimOp
   MutByteArr# s -> Int# -> State# s -> (# State# s, Double# #)

primop  ReadByteArrayOp_StablePtr "readStablePtrArray#" GenPrimOp
   MutByteArr# s -> Int# -> State# s -> (# State# s, StablePtr# a #)

primop  ReadByteArrayOp_Int8 "readInt8Array#" GenPrimOp
   MutByteArr# s -> Int# -> State# s -> (# State# s, Int# #)

primop  ReadByteArrayOp_Int16 "readInt16Array#" GenPrimOp
   MutByteArr# s -> Int# -> State# s -> (# State# s, Int# #)

primop  ReadByteArrayOp_Int32 "readInt32Array#" GenPrimOp
   MutByteArr# s -> Int# -> State# s -> (# State# s, Int# #)

#ifdef SUPPORT_LONG_LONGS
primop  ReadByteArrayOp_Int64 "readInt64Array#" GenPrimOp
   MutByteArr# s -> Int# -> State# s -> (# State# s, Int64# #)
#endif

primop  ReadByteArrayOp_Word8 "readWord8Array#" GenPrimOp
   MutByteArr# s -> Int# -> State# s -> (# State# s, Word# #)

primop  ReadByteArrayOp_Word16 "readWord16Array#" GenPrimOp
   MutByteArr# s -> Int# -> State# s -> (# State# s, Word# #)

primop  ReadByteArrayOp_Word32 "readWord32Array#" GenPrimOp
   MutByteArr# s -> Int# -> State# s -> (# State# s, Word# #)

#ifdef SUPPORT_LONG_LONGS
primop  ReadByteArrayOp_Word64 "readWord64Array#" GenPrimOp
   MutByteArr# s -> Int# -> State# s -> (# State# s, Word64# #)
#endif



primop  WriteByteArrayOp_Char "writeCharArray#" GenPrimOp
   MutByteArr# s -> Int# -> Char# -> State# s -> State# s
   with has_side_effects = True

primop  WriteByteArrayOp_WideChar "writeWideCharArray#" GenPrimOp
   MutByteArr# s -> Int# -> Char# -> State# s -> State# s
   with has_side_effects = True

primop  WriteByteArrayOp_Int "writeIntArray#" GenPrimOp
   MutByteArr# s -> Int# -> Int# -> State# s -> State# s
   with has_side_effects = True

primop  WriteByteArrayOp_Word "writeWordArray#" GenPrimOp
   MutByteArr# s -> Int# -> Word# -> State# s -> State# s
   with has_side_effects = True

primop  WriteByteArrayOp_Addr "writeAddrArray#" GenPrimOp
   MutByteArr# s -> Int# -> Addr# -> State# s -> State# s
   with has_side_effects = True

primop  WriteByteArrayOp_Float "writeFloatArray#" GenPrimOp
   MutByteArr# s -> Int# -> Float# -> State# s -> State# s
   with has_side_effects = True

primop  WriteByteArrayOp_Double "writeDoubleArray#" GenPrimOp
   MutByteArr# s -> Int# -> Double# -> State# s -> State# s
   with has_side_effects = True

primop  WriteByteArrayOp_StablePtr "writeStablePtrArray#" GenPrimOp
   MutByteArr# s -> Int# -> StablePtr# a -> State# s -> State# s
   with has_side_effects = True

primop  WriteByteArrayOp_Int8 "writeInt8Array#" GenPrimOp
   MutByteArr# s -> Int# -> Int# -> State# s -> State# s
   with has_side_effects = True

primop  WriteByteArrayOp_Int16 "writeInt16Array#" GenPrimOp
   MutByteArr# s -> Int# -> Int# -> State# s -> State# s
   with has_side_effects = True

primop  WriteByteArrayOp_Int32 "writeInt32Array#" GenPrimOp
   MutByteArr# s -> Int# -> Int# -> State# s -> State# s
   with has_side_effects = True

#ifdef SUPPORT_LONG_LONGS
primop  WriteByteArrayOp_Int64 "writeInt64Array#" GenPrimOp
   MutByteArr# s -> Int# -> Int64# -> State# s -> State# s
   with has_side_effects = True
#endif

primop  WriteByteArrayOp_Word8 "writeWord8Array#" GenPrimOp
   MutByteArr# s -> Int# -> Word# -> State# s -> State# s
   with has_side_effects = True

primop  WriteByteArrayOp_Word16 "writeWord16Array#" GenPrimOp
   MutByteArr# s -> Int# -> Word# -> State# s -> State# s
   with has_side_effects = True

primop  WriteByteArrayOp_Word32 "writeWord32Array#" GenPrimOp
   MutByteArr# s -> Int# -> Word# -> State# s -> State# s
   with has_side_effects = True

#ifdef SUPPORT_LONG_LONGS
primop  WriteByteArrayOp_Word64 "writeWord64Array#" GenPrimOp
   MutByteArr# s -> Int# -> Word64# -> State# s -> State# s
   with has_side_effects = True
#endif


primop IndexOffAddrOp_Char "indexCharOffAddr#" GenPrimOp
   Addr# -> Int# -> Char#

primop IndexOffAddrOp_WideChar "indexWideCharOffAddr#" GenPrimOp
   Addr# -> Int# -> Char#

primop IndexOffAddrOp_Int "indexIntOffAddr#" GenPrimOp
   Addr# -> Int# -> Int#

primop IndexOffAddrOp_Word "indexWordOffAddr#" GenPrimOp
   Addr# -> Int# -> Word#

primop IndexOffAddrOp_Addr "indexAddrOffAddr#" GenPrimOp
   Addr# -> Int# -> Addr#

primop IndexOffAddrOp_Float "indexFloatOffAddr#" GenPrimOp
   Addr# -> Int# -> Float#

primop IndexOffAddrOp_Double "indexDoubleOffAddr#" GenPrimOp
   Addr# -> Int# -> Double#

primop IndexOffAddrOp_StablePtr "indexStablePtrOffAddr#" GenPrimOp
   Addr# -> Int# -> StablePtr# a

primop IndexOffAddrOp_Int8 "indexInt8OffAddr#" GenPrimOp
   Addr# -> Int# -> Int#

primop IndexOffAddrOp_Int16 "indexInt16OffAddr#" GenPrimOp
   Addr# -> Int# -> Int#

primop IndexOffAddrOp_Int32 "indexInt32OffAddr#" GenPrimOp
   Addr# -> Int# -> Int#

#ifdef SUPPORT_LONG_LONGS
primop IndexOffAddrOp_Int64 "indexInt64OffAddr#" GenPrimOp
   Addr# -> Int# -> Int64#
#endif

primop IndexOffAddrOp_Word8 "indexWord8OffAddr#" GenPrimOp
   Addr# -> Int# -> Word#

primop IndexOffAddrOp_Word16 "indexWord16OffAddr#" GenPrimOp
   Addr# -> Int# -> Word#

primop IndexOffAddrOp_Word32 "indexWord32OffAddr#" GenPrimOp
   Addr# -> Int# -> Word#

#ifdef SUPPORT_LONG_LONGS
primop IndexOffAddrOp_Word64 "indexWord64OffAddr#" GenPrimOp
   Addr# -> Int# -> Word64#
#endif


primop EqForeignObj "eqForeignObj#" GenPrimOp
   ForeignObj# -> ForeignObj# -> Bool
   with commutable = True

primop IndexOffForeignObjOp_Char "indexCharOffForeignObj#" GenPrimOp
   ForeignObj# -> Int# -> Char#

primop IndexOffForeignObjOp_WideChar "indexWideCharOffForeignObj#" GenPrimOp
   ForeignObj# -> Int# -> Char#

primop IndexOffForeignObjOp_Int "indexIntOffForeignObj#" GenPrimOp
   ForeignObj# -> Int# -> Int#

primop IndexOffForeignObjOp_Word "indexWordOffForeignObj#" GenPrimOp
   ForeignObj# -> Int# -> Word#

primop IndexOffForeignObjOp_Addr "indexAddrOffForeignObj#" GenPrimOp
   ForeignObj# -> Int# -> Addr#

primop IndexOffForeignObjOp_Float "indexFloatOffForeignObj#" GenPrimOp
   ForeignObj# -> Int# -> Float#

primop IndexOffForeignObjOp_Double "indexDoubleOffForeignObj#" GenPrimOp
   ForeignObj# -> Int# -> Double#

primop IndexOffForeignObjOp_StablePtr "indexStablePtrOffForeignObj#" GenPrimOp
   ForeignObj# -> Int# -> StablePtr# a

primop IndexOffForeignObjOp_Int8 "indexInt8OffForeignObj#" GenPrimOp
   ForeignObj# -> Int# -> Int#

primop IndexOffForeignObjOp_Int16 "indexInt16OffForeignObj#" GenPrimOp
   ForeignObj# -> Int# -> Int#

primop IndexOffForeignObjOp_Int32 "indexInt32OffForeignObj#" GenPrimOp
   ForeignObj# -> Int# -> Int#

#ifdef SUPPORT_LONG_LONGS
primop IndexOffForeignObjOp_Int64 "indexInt64OffForeignObj#" GenPrimOp
   ForeignObj# -> Int# -> Int64#
#endif

primop IndexOffForeignObjOp_Word8 "indexWord8OffForeignObj#" GenPrimOp
   ForeignObj# -> Int# -> Word#

primop IndexOffForeignObjOp_Word16 "indexWord16OffForeignObj#" GenPrimOp
   ForeignObj# -> Int# -> Word#

primop IndexOffForeignObjOp_Word32 "indexWord32OffForeignObj#" GenPrimOp
   ForeignObj# -> Int# -> Word#

#ifdef SUPPORT_LONG_LONGS
primop IndexOffForeignObjOp_Word64 "indexWord64OffForeignObj#" GenPrimOp
   ForeignObj# -> Int# -> Word64#
#endif

primop ReadOffAddrOp_Char "readCharOffAddr#" GenPrimOp
   Addr# -> Int# -> State# s -> (# State# s, Char# #)

primop ReadOffAddrOp_WideChar "readWideCharOffAddr#" GenPrimOp
   Addr# -> Int# -> State# s -> (# State# s, Char# #)

primop ReadOffAddrOp_Int "readIntOffAddr#" GenPrimOp
   Addr# -> Int# -> State# s -> (# State# s, Int# #)

primop ReadOffAddrOp_Word "readWordOffAddr#" GenPrimOp
   Addr# -> Int# -> State# s -> (# State# s, Word# #)

primop ReadOffAddrOp_Addr "readAddrOffAddr#" GenPrimOp
   Addr# -> Int# -> State# s -> (# State# s, Addr# #)

primop ReadOffAddrOp_Float "readFloatOffAddr#" GenPrimOp
   Addr# -> Int# -> State# s -> (# State# s, Float# #)

primop ReadOffAddrOp_Double "readDoubleOffAddr#" GenPrimOp
   Addr# -> Int# -> State# s -> (# State# s, Double# #)

primop ReadOffAddrOp_StablePtr "readStablePtrOffAddr#" GenPrimOp
   Addr# -> Int# -> State# s -> (# State# s, StablePtr# a #)

primop ReadOffAddrOp_Int8 "readInt8OffAddr#" GenPrimOp
   Addr# -> Int# -> State# s -> (# State# s, Int# #)

primop ReadOffAddrOp_Int16 "readInt16OffAddr#" GenPrimOp
   Addr# -> Int# -> State# s -> (# State# s, Int# #)

primop ReadOffAddrOp_Int32 "readInt32OffAddr#" GenPrimOp
   Addr# -> Int# -> State# s -> (# State# s, Int# #)

#ifdef SUPPORT_LONG_LONGS
primop ReadOffAddrOp_Int64 "readInt64OffAddr#" GenPrimOp
   Addr# -> Int# -> State# s -> (# State# s, Int64# #)
#endif

primop ReadOffAddrOp_Word8 "readWord8OffAddr#" GenPrimOp
   Addr# -> Int# -> State# s -> (# State# s, Word# #)

primop ReadOffAddrOp_Word16 "readWord16OffAddr#" GenPrimOp
   Addr# -> Int# -> State# s -> (# State# s, Word# #)

primop ReadOffAddrOp_Word32 "readWord32OffAddr#" GenPrimOp
   Addr# -> Int# -> State# s -> (# State# s, Word# #)

#ifdef SUPPORT_LONG_LONGS
primop ReadOffAddrOp_Word64 "readWord64OffAddr#" GenPrimOp
   Addr# -> Int# -> State# s -> (# State# s, Word64# #)
#endif


primop  WriteOffAddrOp_Char "writeCharOffAddr#" GenPrimOp
   Addr# -> Int# -> Char# -> State# s -> State# s
   with has_side_effects = True

primop  WriteOffAddrOp_WideChar "writeWideCharOffAddr#" GenPrimOp
   Addr# -> Int# -> Char# -> State# s -> State# s
   with has_side_effects = True

primop  WriteOffAddrOp_Int "writeIntOffAddr#" GenPrimOp
   Addr# -> Int# -> Int# -> State# s -> State# s
   with has_side_effects = True

primop  WriteOffAddrOp_Word "writeWordOffAddr#" GenPrimOp
   Addr# -> Int# -> Word# -> State# s -> State# s
   with has_side_effects = True

primop  WriteOffAddrOp_Addr "writeAddrOffAddr#" GenPrimOp
   Addr# -> Int# -> Addr# -> State# s -> State# s
   with has_side_effects = True

primop  WriteOffAddrOp_ForeignObj "writeForeignObjOffAddr#" GenPrimOp
   Addr# -> Int# -> ForeignObj# -> State# s -> State# s
   with has_side_effects = True

primop  WriteOffAddrOp_Float "writeFloatOffAddr#" GenPrimOp
   Addr# -> Int# -> Float# -> State# s -> State# s
   with has_side_effects = True

primop  WriteOffAddrOp_Double "writeDoubleOffAddr#" GenPrimOp
   Addr# -> Int# -> Double# -> State# s -> State# s
   with has_side_effects = True

primop  WriteOffAddrOp_StablePtr "writeStablePtrOffAddr#" GenPrimOp
   Addr# -> Int# -> StablePtr# a -> State# s -> State# s
   with has_side_effects = True

primop  WriteOffAddrOp_Int8 "writeInt8OffAddr#" GenPrimOp
   Addr# -> Int# -> Int# -> State# s -> State# s
   with has_side_effects = True

primop  WriteOffAddrOp_Int16 "writeInt16OffAddr#" GenPrimOp
   Addr# -> Int# -> Int# -> State# s -> State# s
   with has_side_effects = True

primop  WriteOffAddrOp_Int32 "writeInt32OffAddr#" GenPrimOp
   Addr# -> Int# -> Int# -> State# s -> State# s
   with has_side_effects = True

#ifdef SUPPORT_LONG_LONGS
primop  WriteOffAddrOp_Int64 "writeInt64OffAddr#" GenPrimOp
   Addr# -> Int# -> Int64# -> State# s -> State# s
   with has_side_effects = True
#endif

primop  WriteOffAddrOp_Word8 "writeWord8OffAddr#" GenPrimOp
   Addr# -> Int# -> Word# -> State# s -> State# s
   with has_side_effects = True

primop  WriteOffAddrOp_Word16 "writeWord16OffAddr#" GenPrimOp
   Addr# -> Int# -> Word# -> State# s -> State# s
   with has_side_effects = True

primop  WriteOffAddrOp_Word32 "writeWord32OffAddr#" GenPrimOp
   Addr# -> Int# -> Word# -> State# s -> State# s
   with has_side_effects = True

#ifdef SUPPORT_LONG_LONGS
primop  WriteOffAddrOp_Word64 "writeWord64OffAddr#" GenPrimOp
   Addr# -> Int# -> Word64# -> State# s -> State# s
   with has_side_effects = True
#endif



primop  SameMutableArrayOp "sameMutableArray#" GenPrimOp
   MutArr# s a -> MutArr# s a -> Bool
   with
   usage = { mangle SameMutableArrayOp [mkP, mkP] mkM }

primop  SameMutableByteArrayOp "sameMutableByteArray#" GenPrimOp
   MutByteArr# s -> MutByteArr# s -> Bool

primop  ReadArrayOp "readArray#" GenPrimOp
   MutArr# s a -> Int# -> State# s -> (# State# s, a #)
   with
   usage = { mangle ReadArrayOp [mkM, mkP, mkP] mkM }

primop  WriteArrayOp "writeArray#" GenPrimOp
   MutArr# s a -> Int# -> a -> State# s -> State# s
   with
   usage            = { mangle WriteArrayOp [mkM, mkP, mkM, mkP] mkR }
   strictness       = { \ arity -> StrictnessInfo [wwPrim, wwPrim, wwLazy, wwPrim] False }
   has_side_effects = True

primop  IndexArrayOp "indexArray#" GenPrimOp
   Array# a -> Int# -> (# a #)
   with
   usage = { mangle  IndexArrayOp [mkM, mkP] mkM }

primop  UnsafeFreezeArrayOp "unsafeFreezeArray#" GenPrimOp
   MutArr# s a -> State# s -> (# State# s, Array# a #)
   with
   usage            = { mangle UnsafeFreezeArrayOp [mkM, mkP] mkM }
   has_side_effects = True

primop  UnsafeFreezeByteArrayOp "unsafeFreezeByteArray#" GenPrimOp
   MutByteArr# s -> State# s -> (# State# s, ByteArr# #)
   with
   has_side_effects = True

primop  UnsafeThawArrayOp  "unsafeThawArray#" GenPrimOp
   Array# a -> State# s -> (# State# s, MutArr# s a #)
   with
   usage       = { mangle UnsafeThawArrayOp [mkM, mkP] mkM }
   out_of_line = True

primop  SizeofByteArrayOp "sizeofByteArray#" GenPrimOp  
   ByteArr# -> Int#

primop  SizeofMutableByteArrayOp "sizeofMutableByteArray#" GenPrimOp
   MutByteArr# s -> Int#

------------------------------------------------------------------------
--- Mutable variables                                                ---
------------------------------------------------------------------------

primop  NewMutVarOp "newMutVar#" GenPrimOp
   a -> State# s -> (# State# s, MutVar# s a #)
   with
   usage       = { mangle NewMutVarOp [mkM, mkP] mkM }
   strictness  = { \ arity -> StrictnessInfo [wwLazy, wwPrim] False }
   out_of_line = True

primop  ReadMutVarOp "readMutVar#" GenPrimOp
   MutVar# s a -> State# s -> (# State# s, a #)
   with
   usage = { mangle ReadMutVarOp [mkM, mkP] mkM }

primop  WriteMutVarOp "writeMutVar#"  GenPrimOp
   MutVar# s a -> a -> State# s -> State# s
   with
   strictness       = { \ arity -> StrictnessInfo [wwPrim, wwLazy, wwPrim] False }
   usage            = { mangle WriteMutVarOp [mkM, mkM, mkP] mkR }
   has_side_effects = True

primop  SameMutVarOp "sameMutVar#" GenPrimOp
   MutVar# s a -> MutVar# s a -> Bool
   with
   usage = { mangle SameMutVarOp [mkP, mkP] mkM }

------------------------------------------------------------------------
--- Exceptions                                                       ---
------------------------------------------------------------------------

primop  CatchOp "catch#" GenPrimOp
          (State# RealWorld -> (# State# RealWorld, a #) )
       -> (b -> State# RealWorld -> (# State# RealWorld, a #) ) 
       -> State# RealWorld
       -> (# State# RealWorld, a #)
   with
   strictness = { \ arity -> StrictnessInfo [wwLazy, wwLazy, wwPrim] False }
	-- Catch is actually strict in its first argument
	-- but we don't want to tell the strictness
	-- analyser about that!
   usage = { mangle CatchOp [mkM, mkM . (inFun CatchOp mkM mkM), mkP] mkM }
        --     [mkO, mkO . (inFun mkM mkO)] mkO
        -- might use caught action multiply
   out_of_line = True

primop  RaiseOp "raise#" GenPrimOp
   a -> b
   with
   strictness  = { \ arity -> StrictnessInfo [wwLazy] True }
      -- NB: True => result is bottom
   usage       = { mangle RaiseOp [mkM] mkM }
   out_of_line = True

primop  BlockAsyncExceptionsOp "blockAsyncExceptions#" GenPrimOp
        (State# RealWorld -> (# State# RealWorld, a #))
     -> (State# RealWorld -> (# State# RealWorld, a #))
   with
   strictness  = { \ arity -> StrictnessInfo [wwLazy,wwPrim] False }
   out_of_line = True

primop  UnblockAsyncExceptionsOp "unblockAsyncExceptions#" GenPrimOp
        (State# RealWorld -> (# State# RealWorld, a #))
     -> (State# RealWorld -> (# State# RealWorld, a #))
   with
   strictness  = { \ arity -> StrictnessInfo [wwLazy,wwPrim] False }
   out_of_line = True

------------------------------------------------------------------------
--- MVars (not the same as mutable variables!)                       ---
------------------------------------------------------------------------

primop  NewMVarOp "newMVar#"  GenPrimOp
   State# s -> (# State# s, MVar# s a #)
   with
   usage       = { mangle NewMVarOp [mkP] mkR }
   out_of_line = True

primop  TakeMVarOp "takeMVar#" GenPrimOp
   MVar# s a -> State# s -> (# State# s, a #)
   with
   usage            = { mangle TakeMVarOp [mkM, mkP] mkM }
   has_side_effects = True
   out_of_line      = True

primop  TryTakeMVarOp "tryTakeMVar#" GenPrimOp
   MVar# s a -> State# s -> (# State# s, Int#, a #)
   with
   usage            = { mangle TryTakeMVarOp [mkM, mkP] mkM }
   has_side_effects = True
   out_of_line      = True

primop  PutMVarOp "putMVar#" GenPrimOp
   MVar# s a -> a -> State# s -> State# s
   with
   strictness       = { \ arity -> StrictnessInfo [wwPrim, wwLazy, wwPrim] False }
   usage            = { mangle PutMVarOp [mkM, mkM, mkP] mkR }
   has_side_effects = True
   out_of_line      = True

primop  TryPutMVarOp "tryPutMVar#" GenPrimOp
   MVar# s a -> a -> State# s -> (# State# s, Int# #)
   with
   strictness       = { \ arity -> StrictnessInfo [wwPrim, wwLazy, wwPrim] False }
   usage            = { mangle TryPutMVarOp [mkM, mkM, mkP] mkR }
   has_side_effects = True
   out_of_line      = True

primop  SameMVarOp "sameMVar#" GenPrimOp
   MVar# s a -> MVar# s a -> Bool
   with
   usage = { mangle SameMVarOp [mkP, mkP] mkM }

primop  IsEmptyMVarOp "isEmptyMVar#" GenPrimOp
   MVar# s a -> State# s -> (# State# s, Int# #)
   with
   usage = { mangle IsEmptyMVarOp [mkP, mkP] mkM }


------------------------------------------------------------------------
--- delay/wait operations                                            ---
------------------------------------------------------------------------

primop  DelayOp "delay#" GenPrimOp
   Int# -> State# s -> State# s
   with
   needs_wrapper    = True
   has_side_effects = True
   out_of_line      = True

primop  WaitReadOp "waitRead#" GenPrimOp
   Int# -> State# s -> State# s
   with
   needs_wrapper    = True
   has_side_effects = True
   out_of_line      = True

primop  WaitWriteOp "waitWrite#" GenPrimOp
   Int# -> State# s -> State# s
   with
   needs_wrapper    = True
   has_side_effects = True
   out_of_line      = True

------------------------------------------------------------------------
--- concurrency primitives                                           ---
------------------------------------------------------------------------

primop  ForkOp "fork#" GenPrimOp
   a -> State# RealWorld -> (# State# RealWorld, ThreadId# #)
   with
   usage            = { mangle ForkOp [mkO, mkP] mkR }
   strictness       = { \ arity -> StrictnessInfo [wwLazy, wwPrim] False }
   has_side_effects = True
   out_of_line      = True

primop  KillThreadOp "killThread#"  GenPrimOp
   ThreadId# -> a -> State# RealWorld -> State# RealWorld
   with
   usage            = { mangle KillThreadOp [mkP, mkM, mkP] mkR }
   has_side_effects = True
   out_of_line      = True

primop  YieldOp "yield#" GenPrimOp
   State# RealWorld -> State# RealWorld
   with
   has_side_effects = True
   out_of_line      = True

primop  MyThreadIdOp "myThreadId#" GenPrimOp
    State# RealWorld -> (# State# RealWorld, ThreadId# #)

------------------------------------------------------------------------
--- foreign objects                                                  ---
------------------------------------------------------------------------

primop  MkForeignObjOp "mkForeignObj#" GenPrimOp
   Addr# -> State# RealWorld -> (# State# RealWorld, ForeignObj# #)
   with
   has_side_effects = True
   out_of_line      = True

primop  WriteForeignObjOp "writeForeignObj#" GenPrimOp
   ForeignObj# -> Addr# -> State# s -> State# s
   with
   has_side_effects = True

primop ForeignObjToAddrOp "foreignObjToAddr#" GenPrimOp
   ForeignObj# -> Addr#

primop TouchOp "touch#" GenPrimOp
   o -> State# RealWorld -> State# RealWorld
   with
   has_side_effects = True
   strictness       = { \ arity -> StrictnessInfo [wwLazy, wwPrim] False }

------------------------------------------------------------------------
--- Weak pointers                                                    ---
------------------------------------------------------------------------

-- note that tyvar "o" denotes openAlphaTyVar

primop  MkWeakOp "mkWeak#" GenPrimOp
   o -> b -> c -> State# RealWorld -> (# State# RealWorld, Weak# b #)
   with
   strictness       = { \ arity -> StrictnessInfo [wwLazy, wwLazy, wwLazy, wwPrim] False }
   usage            = { mangle MkWeakOp [mkZ, mkM, mkM, mkP] mkM }
   has_side_effects = True
   out_of_line      = True

primop  DeRefWeakOp "deRefWeak#" GenPrimOp
   Weak# a -> State# RealWorld -> (# State# RealWorld, Int#, a #)
   with
   usage            = { mangle DeRefWeakOp [mkM, mkP] mkM }
   has_side_effects = True

primop  FinalizeWeakOp "finalizeWeak#" GenPrimOp
   Weak# a -> State# RealWorld -> (# State# RealWorld, Int#, 
              (State# RealWorld -> (# State# RealWorld, Unit #)) #)
   with
   usage            = { mangle FinalizeWeakOp [mkM, mkP] 
                               (mkR . (inUB FinalizeWeakOp 
                                            [id,id,inFun FinalizeWeakOp mkR mkM])) }
   has_side_effects = True
   out_of_line      = True

------------------------------------------------------------------------
--- Stable pointers and names                                        ---
------------------------------------------------------------------------

primop  MakeStablePtrOp "makeStablePtr#" GenPrimOp
   a -> State# RealWorld -> (# State# RealWorld, StablePtr# a #)
   with
   strictness       = { \ arity -> StrictnessInfo [wwLazy, wwPrim] False }
   usage            = { mangle MakeStablePtrOp [mkM, mkP] mkM }
   has_side_effects = True

primop  DeRefStablePtrOp "deRefStablePtr#" GenPrimOp
   StablePtr# a -> State# RealWorld -> (# State# RealWorld, a #)
   with
   usage            = { mangle DeRefStablePtrOp [mkM, mkP] mkM }
   needs_wrapper    = True
   has_side_effects = True

primop  EqStablePtrOp "eqStablePtr#" GenPrimOp
   StablePtr# a -> StablePtr# a -> Int#
   with
   usage            = { mangle EqStablePtrOp [mkP, mkP] mkR }
   has_side_effects = True

primop  MakeStableNameOp "makeStableName#" GenPrimOp
   a -> State# RealWorld -> (# State# RealWorld, StableName# a #)
   with
   usage            = { mangle MakeStableNameOp [mkZ, mkP] mkR }
   strictness       = { \ arity -> StrictnessInfo [wwLazy, wwPrim] False }
   needs_wrapper    = True
   has_side_effects = True
   out_of_line      = True

primop  EqStableNameOp "eqStableName#" GenPrimOp
   StableName# a -> StableName# a -> Int#
   with
   usage = { mangle EqStableNameOp [mkP, mkP] mkR }

primop  StableNameToIntOp "stableNameToInt#" GenPrimOp
   StableName# a -> Int#
   with
   usage = { mangle StableNameToIntOp [mkP] mkR }

------------------------------------------------------------------------
--- Unsafe pointer equality (#1 Bad Guy: Alistair Reid :)            ---
------------------------------------------------------------------------

primop  ReallyUnsafePtrEqualityOp "reallyUnsafePtrEquality#" GenPrimOp
   a -> a -> Int#
   with
   usage = { mangle ReallyUnsafePtrEqualityOp [mkZ, mkZ] mkR }

------------------------------------------------------------------------
--- Parallelism                                                      ---
------------------------------------------------------------------------

primop  SeqOp "seq#" GenPrimOp
   a -> Int#
   with
   usage            = { mangle  SeqOp [mkO] mkR }
   strictness       = { \ arity -> StrictnessInfo [wwStrict] False }
      -- Seq is strict in its argument; see notes in ConFold.lhs
   has_side_effects = True

primop  ParOp "par#" GenPrimOp
   a -> Int#
   with
   usage            = { mangle ParOp [mkO] mkR }
   strictness       = { \ arity -> StrictnessInfo [wwLazy] False }
      -- Note that Par is lazy to avoid that the sparked thing
      -- gets evaluted strictly, which it should *not* be
   has_side_effects = True

-- HWL: The first 4 Int# in all par... annotations denote:
--   name, granularity info, size of result, degree of parallelism
--      Same  structure as _seq_ i.e. returns Int#
-- KSW: v, the second arg in parAt# and parAtForNow#, is used only to determine
--   `the processor containing the expression v'; it is not evaluated

primop  ParGlobalOp  "parGlobal#"  GenPrimOp
   a -> Int# -> Int# -> Int# -> Int# -> b -> Int#
   with
   usage            = { mangle ParGlobalOp [mkO, mkP, mkP, mkP, mkP, mkM] mkM }
   has_side_effects = True

primop  ParLocalOp  "parLocal#"  GenPrimOp
   a -> Int# -> Int# -> Int# -> Int# -> b -> Int#
   with
   usage            = { mangle ParLocalOp [mkO, mkP, mkP, mkP, mkP, mkM] mkM }
   has_side_effects = True

primop  ParAtOp  "parAt#"  GenPrimOp
   b -> a -> Int# -> Int# -> Int# -> Int# -> c -> Int#
   with
   usage            = { mangle ParAtOp [mkO, mkZ, mkP, mkP, mkP, mkP, mkM] mkM }
   has_side_effects = True

primop  ParAtAbsOp  "parAtAbs#"  GenPrimOp
   a -> Int# -> Int# -> Int# -> Int# -> Int# -> b -> Int#
   with
   usage            = { mangle ParAtAbsOp [mkO, mkP, mkP, mkP, mkP, mkM] mkM }
   has_side_effects = True

primop  ParAtRelOp  "parAtRel#" GenPrimOp
   a -> Int# -> Int# -> Int# -> Int# -> Int# -> b -> Int#
   with
   usage            = { mangle ParAtRelOp [mkO, mkP, mkP, mkP, mkP, mkM] mkM }
   has_side_effects = True

primop  ParAtForNowOp  "parAtForNow#" GenPrimOp
   b -> a -> Int# -> Int# -> Int# -> Int# -> c -> Int#
   with
   usage            = { mangle ParAtForNowOp [mkO, mkZ, mkP, mkP, mkP, mkP, mkM] mkM }
   has_side_effects = True

-- copyable# and noFollow# are yet to be implemented (for GpH)
--
--primop  CopyableOp  "copyable#" GenPrimOp
--   a -> Int#
--   with
--   usage            = { mangle CopyableOp [mkZ] mkR }
--   has_side_effects = True
--
--primop  NoFollowOp "noFollow#" GenPrimOp
--   a -> Int#
--   with
--   usage            = { mangle NoFollowOp [mkZ] mkR }
--   has_side_effects = True


------------------------------------------------------------------------
--- tag to enum stuff                                                ---
------------------------------------------------------------------------

primop  DataToTagOp "dataToTag#" GenPrimOp
   a -> Int#
   with
   strictness = { \ arity -> StrictnessInfo [wwLazy] False }

primop  TagToEnumOp "tagToEnum#" GenPrimOp     
   Int# -> a


thats_all_folks

------------------------------------------------------------------------
---                                                                  ---
------------------------------------------------------------------------

