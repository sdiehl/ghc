{-# LANGUAGE CPP #-}

module GHC.Platform.NoRegs where

import GhcPrelude

#define MACHREGS_NO_REGS 1
#include "../../../includes/CodeGen.Platform.hs"

