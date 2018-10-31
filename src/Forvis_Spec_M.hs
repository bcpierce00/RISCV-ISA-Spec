-- Copyright (c) 2018 Rishiyur S. Nikhil
-- See LICENSE for license details

module Forvis_Spec_M where

-- ================================================================
-- Part of: specification of all RISC-V instructions.

-- This module is the specification of the RISC-V 'M' Extension
-- i.e., Integer Multiply/Divide

-- ================================================================
-- Haskell lib imports

-- None

-- Local imports

import Bit_Utils
import ALU
import Arch_Defs
import Machine_State

import Forvis_Spec_Finish_Instr     -- Canonical ways for finish an instruction

-- ================================================================
-- OP: 'M' Extension: MUL, MULH, MULHSU, MULHU, DIV, DIVU, REM, REMU

-- ----------------
-- OP: MUL, MULH, MULHSU, MULHU

funct3_MUL    = 0x0 :: InstrField     -- 3'b_000
funct7_MUL    = 0x01 :: InstrField    -- 7'b_000_0001

funct3_MULH   = 0x1 :: InstrField     -- 3'b_001
funct7_MULH   = 0x01 :: InstrField    -- 7'b_000_0001

funct3_MULHSU = 0x2 :: InstrField     -- 3'b_010
funct7_MULHSU = 0x01 :: InstrField    -- 7'b_000_0001

funct3_MULHU  = 0x3 :: InstrField     -- 3'b_011
funct7_MULHU  = 0x01 :: InstrField    -- 7'b_000_0001

spec_OP_MUL :: Machine_State -> Instr -> Bool -> (Bool, Machine_State)
spec_OP_MUL    mstate           instr    is_C =
  let
    -- Instr fields: R-type
    (funct7, rs2, rs1, funct3, rd, opcode) = ifields_R_type  instr

    -- Decode check
    is_legal =
      ((opcode == opcode_OP)
       && ((   (funct3 == funct3_MUL)     && (funct7 == funct7_MUL))
           || ((funct3 == funct3_MULH)    && (funct7 == funct7_MULH))
           || ((funct3 == funct3_MULHSU)  && (funct7 == funct7_MULHSU))
           || ((funct3 == funct3_MULHU)   && (funct7 == funct7_MULHU))
          ))

    -- Semantics
    rv      = mstate_rv_read    mstate
    xlen    = mstate_xlen_read  mstate
    rs1_val = mstate_gpr_read  mstate  rs1
    rs2_val = mstate_gpr_read  mstate  rs2

    rd_val | (funct3 == funct3_MUL)    = alu_mul     xlen  rs1_val  rs2_val
           | (funct3 == funct3_MULH)   = alu_mulh    xlen  rs1_val  rs2_val
           | (funct3 == funct3_MULHU)  = alu_mulhu   xlen  rs1_val  rs2_val
           | (funct3 == funct3_MULHSU) = alu_mulhsu  xlen  rs1_val  rs2_val

    mstate1 = finish_rd_and_pc_incr  mstate  rd  rd_val  is_C
  in
    (is_legal, mstate1)

-- ----------------
-- OP: DIV, DIVU

funct3_DIV    = 0x4 :: InstrField     -- 3'b_100
funct7_DIV    = 0x01 :: InstrField    -- 7'b_000_0001

funct3_DIVU   = 0x5 :: InstrField     -- 3'b_101
funct7_DIVU   = 0x01 :: InstrField    -- 7'b_000_0001

spec_OP_DIV :: Machine_State -> Instr -> Bool -> (Bool, Machine_State)
spec_OP_DIV    mstate           instr    is_C =
  let
    -- Instr fields: R-type
    (funct7, rs2, rs1, funct3, rd, opcode) = ifields_R_type  instr

    -- Decode check
    is_legal =
      ((opcode == opcode_OP)
       && ((   (funct3 == funct3_DIV)  && (funct7 == funct7_DIV))
           || ((funct3 == funct3_DIVU) && (funct7 == funct7_DIVU))
          ))

    -- Semantics
    xlen    = mstate_xlen_read  mstate
    rs1_val = mstate_gpr_read   mstate  rs1
    rs2_val = mstate_gpr_read   mstate  rs2

    rd_val | (funct3 == funct3_DIV)  = alu_div   xlen  rs1_val  rs2_val
           | (funct3 == funct3_DIVU) = alu_divu  xlen  rs1_val  rs2_val

    mstate1 = finish_rd_and_pc_incr  mstate  rd  rd_val  is_C
  in
    (is_legal, mstate1)

-- ----------------
-- OP: REM, REMU

funct3_REM    = 0x6 :: InstrField     -- 3'b_110
funct7_REM    = 0x01 :: InstrField    -- 7'b_000_0001

funct3_REMU   = 0x7 :: InstrField     -- 3'b_111
funct7_REMU   = 0x01 :: InstrField    -- 7'b_000_0001

spec_OP_REM :: Machine_State -> Instr -> Bool -> (Bool, Machine_State)
spec_OP_REM    mstate           instr    is_C =
  let
    -- Instr fields: R-type
    (funct7, rs2, rs1, funct3, rd, opcode) = ifields_R_type  instr

    -- Decode check
    is_legal =
      ((opcode == opcode_OP)
       && ((   (funct3 == funct3_REM)     && (funct7 == funct7_REM))
           || ((funct3 == funct3_REMU)    && (funct7 == funct7_REMU))
          ))

    -- Semantics
    xlen    = mstate_xlen_read  mstate
    rs1_val = mstate_gpr_read   mstate  rs1
    rs2_val = mstate_gpr_read   mstate  rs2

    rd_val | (funct3 == funct3_REM)  = alu_rem   xlen  rs1_val  rs2_val
           | (funct3 == funct3_REMU) = alu_remu  xlen  rs1_val  rs2_val

    mstate1 = finish_rd_and_pc_incr  mstate  rd  rd_val  is_C
  in
    (is_legal, mstate1)

-- ================================================================
-- OP-32: 'M' Extension for RV64: MULW, DIVW, DIVUW, REMW, REMUW

funct3_MULW  = 0x0  :: InstrField    --- 3'b_000
funct7_MULW  = 0x01 :: InstrField    --- 7'b_000_0001

funct3_DIVW  = 0x4  :: InstrField    --- 3'b_100
funct7_DIVW  = 0x01 :: InstrField    --- 7'b_000_0001

funct3_DIVUW = 0x5  :: InstrField    --- 3'b_101
funct7_DIVUW = 0x01 :: InstrField    --- 7'b_000_0001

funct3_REMW  = 0x6  :: InstrField    --- 3'b_110
funct7_REMW  = 0x01 :: InstrField    --- 7'b_000_0001

funct3_REMUW = 0x7  :: InstrField    --- 3'b_111
funct7_REMUW = 0x01 :: InstrField    --- 7'b_000_0001

spec_OP_32_M :: Machine_State -> Instr -> Bool -> (Bool, Machine_State)
spec_OP_32_M    mstate           instr    is_C =
  let
    -- Instr fields: R-type
    (funct7, rs2, rs1, funct3, rd, opcode) = ifields_R_type  instr

    -- Decode check
    rv       = mstate_rv_read  mstate
    is_MULW  = ((funct3 == funct3_MULW)   && (funct7 == funct7_MULW))
    is_DIVW  = ((funct3 == funct3_DIVW)   && (funct7 == funct7_DIVW))
    is_DIVUW = ((funct3 == funct3_DIVUW)  && (funct7 == funct7_DIVUW))
    is_REMW  = ((funct3 == funct3_REMW)   && (funct7 == funct7_REMW))
    is_REMUW = ((funct3 == funct3_REMUW)  && (funct7 == funct7_REMUW))
    is_legal = ((rv == RV64)
                && (opcode == opcode_OP_32)
                && (is_MULW
                    || is_DIVW
                    || is_DIVUW
                    || is_REMW
                    || is_REMUW))

    -- Semantics
    rs1_val = mstate_gpr_read  mstate  rs1
    rs2_val = mstate_gpr_read  mstate  rs2

    rd_val | is_MULW  = alu_mulw   rs1_val  rs2_val
           | is_DIVW  = alu_divw   rs1_val  rs2_val
           | is_DIVUW = alu_divuw  rs1_val  rs2_val
           | is_REMW  = alu_remw   rs1_val  rs2_val
           | is_REMUW = alu_remuw  rs1_val  rs2_val

    mstate1 = finish_rd_and_pc_incr  mstate  rd  rd_val  is_C
  in
    (is_legal, mstate1)

-- ================================================================
