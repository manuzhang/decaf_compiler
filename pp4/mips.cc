/* File: mips.cc
 * -------------
 * Implementation of Mips class, which is responsible for TAC->MIPS
 * translation, register allocation, etc.
 *
 * Julie Zelenski academic year 2001-02 for CS143
 * Loosely based on some earlier work by Steve Freund
 *
 * A simple final code generator to translate Tac to MIPS.
 * It uses simplistic algorithms, in particular, its register handling
 * and spilling strategy is inefficient to the point of begin mocked
 * by elementary school children.
 */

#include "mips.h"
#include <stdarg.h>
#include <string.h>

/* Method: GetRegister
 * -------------------
 * Given a location for a current var, a reason (ForRead or ForWrite)
 * and up to two registers to avoid, this method will assign
 * to a var to register trying these alternatives in order:
 *  1) if that var is already in a register ("same" is determined
 *     by matching name and same scope), we use that one
 *  2) find an empty register to use for the var
 *  3) find an in-use register that is not dirty.  We don't need
 *     to write value back to memory since it's clean, so we just
 *     replace with the new var
 *  4) spill an in-use, dirty register, by writing its contents to
 *     memory and then replace with the new var
 * For steps 3 & 4, we respect the registers given to avoid (ie the
 * other operands in this operation). The register descriptors are
 * updated to show the new state of the world. If for read, we
 * load the current value from memory into the register. If for
 * write, we mark the register as dirty (since it is getting a
 * new value).
 */
Mips::Register Mips::GetRegister(Location *var, Reason reason,
					   Register avoid1, Register avoid2)
{
  Register reg;

  if (!FindRegisterWithContents(var, reg)) {
    if (!FindRegisterWithContents(NULL, reg)) { 
	reg = SelectRegisterToSpill(avoid1, avoid2);
	SpillRegister(reg);
    }
    regs[reg].var = var;
    if (reason == ForRead) {                 // load current value
	Assert(var->GetOffset() % 4 == 0); // all variables are 4 bytes
	const char *offsetFromWhere = var->GetSegment() == fpRelative? regs[fp].name : regs[gp].name;
	Emit("lw %s, %d(%s)\t# load %s from %s%+d into %s", regs[reg].name,
	     var->GetOffset(), offsetFromWhere, var->GetName(),
	     offsetFromWhere, var->GetOffset(), regs[reg].name);
	regs[reg].isDirty = false;
    }
  }
  if (reason == ForWrite)
    regs[reg].isDirty = true;
  return reg;
}


// Two covers for the above method to make it slightly more
// convenient to call it
Mips::Register Mips::GetRegister(Location *var, Register avoid1)
{
  return GetRegister(var, ForRead, avoid1, zero);
}

Mips::Register Mips::GetRegisterForWrite(Location *var, Register avoid1,
						     Register avoid2)
{
  return GetRegister(var, ForWrite, avoid1, avoid2);
} 


// Helper to check if two variable locations are one and the same
// (same name, segment, and offset)
static bool LocationsAreSame(Location *var1, Location *var2)
{
   return (var1 == var2 ||
	     (var1 && var2
		&& !strcmp(var1->GetName(), var2->GetName())
		&& var1->GetSegment()  == var2->GetSegment()
		&& var1->GetOffset() == var2->GetOffset()));
}


/* Method: FindRegisterWithContents
 * --------------------------------
 * Searches the descriptors for one with contents var. Assigns
 * register by reference, and returns true/false on whether match found.
 */
bool Mips::FindRegisterWithContents(Location *var, Register& reg)
{
  for (reg = zero; reg < NumRegs; reg = Register(reg+1))
    if (regs[reg].isGeneralPurpose && LocationsAreSame(var, regs[reg].var))
	return true;
  return false;
}


/* Method: SelectRegisterToSpill
 * -----------------------------
 * Chooses an in-use register to replace with a new variable. We
 * prefer to replace a non-dirty once since we would not have to
 * write its contents back to memory, so the first loop searches
 * for a clean one. If none found, we take a dirty one.  In both
 * loops we deliberately won't choose either of the registers we
 * were asked to avoid.  We track the last dirty register spilled
 * and advance on each subsequent spill as a primitive means of
 * trying to not throw out things we just loaded and thus are likely
 * to need.
 */
Mips::Register Mips::SelectRegisterToSpill(Register avoid1, Register avoid2)
{
            // first hunt for a non-dirty one, since no work to spill
  for (Register i = zero; i < NumRegs; i = (Register)(i+1)) {
    if (i != avoid1 && i != avoid2 && regs[i].isGeneralPurpose &&
	  !regs[i].isDirty)
	return i;
  }
  do {      // otherwise just pick the next usuable register
    lastUsed = (Register)((lastUsed + 1) % NumRegs);
  } while (lastUsed == avoid1 || lastUsed == avoid2 ||
           !regs[lastUsed].isGeneralPurpose);
  return lastUsed;
}


/* Method: SpillRegister
 * ---------------------
 * "Empties" register.  If variable is currently slaved in this register
 * and its contents are out of synch with memory (isDirty), we write back
 * the current contents to memory. We then clear the descriptor so we
 * realize the register is empty.
 */
void Mips::SpillRegister(Register reg)
{
  Location *var = regs[reg].var;
  if (var && regs[reg].isDirty) {
    const char *offsetFromWhere = var->GetSegment() == fpRelative? regs[fp].name : regs[gp].name;
    Assert(var->GetOffset() % 4 == 0); // all variables are 4 bytes in size
    Emit("sw %s, %d(%s)\t# spill %s from %s to %s%+d", regs[reg].name,
	   var->GetOffset(), offsetFromWhere, var->GetName(), regs[reg].name,
	   offsetFromWhere,var->GetOffset());
  }
  regs[reg].var = NULL;
}       


/* Method: SpillAllDirtyRegisters
 * ------------------------------
 * Used before flow of control change (branch, label, jump, etc.) to
 * save contents of all dirty registers. This synchs the contents of
 * the registers with the memory locations for the variables.
 */
void Mips::SpillAllDirtyRegisters()
{
  Register i;
  for (i = zero; i < NumRegs; i = Register(i+1)) 
    if (regs[i].var && regs[i].isDirty) break;
  if (i != NumRegs) // none are dirty, don't print message to avoid confusion
    Emit("# (save modified registers before flow of control change)");
  for (i = zero; i < NumRegs; i = Register(i+1)) 
    SpillRegister(i);
}


/* Method: SpillForEndFunction
 * ---------------------------
 * Slight optimization on the above method used when spilling for
 * end of function (return/fall off). In such a case, we do not
 * need to save values for locals, temps, and parameters because the
 * function is about to exit and those variables are going away
 * immediately, so no need to bother with updating contents.
 */
void Mips::SpillForEndFunction()
{
  for (Register i = zero; i < NumRegs; i = Register(i+1)) {
    if (regs[i].isGeneralPurpose && regs[i].var) {
	if (regs[i].var->GetSegment() == gpRelative)
	  SpillRegister(i);
	else  // all stack variables can just be tossed at end func
	  regs[i].var = NULL;
    }
  }
}


/* Method: Emit
 * ------------
 * General purpose helper used to emit assembly instructions in
 * a reasonable tidy manner.  Takes printf-style formatting strings
 * and variable arguments.
 */
void Mips::Emit(const char *fmt, ...)
{
  va_list args;
  char buf[1024];
  
  va_start(args, fmt);
  vsprintf(buf, fmt, args);
  va_end(args);
  if (buf[strlen(buf) - 1] != ':') printf("\t"); // don't tab in labels
  if (buf[0] != '#') printf("  ");   // outdent comments a little
  printf("%s", buf);
  if (buf[strlen(buf)-1] != '\n') printf("\n"); // end with a newline
}



/* Method: EmitLoadConstant
 * ------------------------
 * Used to assign variable an integer constant value.  Slaves dst into
 * a register (using GetRegister above) and then emits an li (load
 * immediate) instruction with the constant value.
 */
void Mips::EmitLoadConstant(Location *dst, int val)
{
  Register reg = GetRegisterForWrite(dst);
  Emit("li %s, %d\t\t# load constant value %d into %s", regs[reg].name,
	 val, val, regs[reg].name);
}

/* Method: EmitLoadStringConstant
 * ------------------------------
 * Used to assign a variable a pointer to string constant. Emits
 * assembly directives to create a new null-terminated string in the
 * data segment and assigns it a unique label. Slaves dst into a register
 * and loads that label address into the register.
 */
void Mips::EmitLoadStringConstant(Location *dst, const char *str)
{
  static int strNum = 1;
  char label[16];
  sprintf(label, "_string%d", strNum++);
  Emit(".data\t\t\t# create string constant marked with label");
  Emit("%s: .asciiz %s", label, str);
  Emit(".text");
  EmitLoadLabel(dst, label);
}


/* Method: EmitLoadLabel
 * ---------------------
 * Used to load a label (ie address in text/data segment) into a variable.
 * Slaves dst into a register and emits an la (load address) instruction
 */
void Mips::EmitLoadLabel(Location *dst, const char *label)
{
  Register reg = GetRegisterForWrite(dst);
  Emit("la %s, %s\t# load label", regs[reg].name, label);
}
 

/* Method: EmitCopy
 * ----------------
 * Used to copy the value of one variable to another.  Slaves both
 * src and dst into registers and then emits a move instruction to
 * copy the contents from src to dst.
 */
void Mips::EmitCopy(Location *dst, Location *src)
{
  Register rSrc = GetRegister(src), rDst = GetRegisterForWrite(dst, rSrc);
  Emit("move %s, %s\t\t# copy value", regs[rDst].name, regs[rSrc].name);

}


/* Method: EmitLoad
 * ----------------
 * Used to assign dst the contents of memory at the address in reference,
 * potentially with some positive/negative offset (defaults to 0).
 * Slaves both ref and dst to registers, then emits a lw instruction
 * using constant-offset addressing mode y(rx) which accesses the address
 * at an offset of y bytes from the address currently contained in rx.
 */
void Mips::EmitLoad(Location *dst, Location *reference, int offset)
{
  Register rSrc = GetRegister(reference), rDst = GetRegisterForWrite(dst, rSrc);
  Emit("lw %s, %d(%s) \t# load with offset", regs[rDst].name,
	 offset, regs[rSrc].name);
}


/* Method: EmitStore
 * -----------------
 * Used to write value to  memory at the address in reference,
 * potentially with some positive/negative offset (defaults to 0).
 * Slaves both ref and dst to registers, then emits a sw instruction
 * using constant-offset addressing mode y(rx) which writes to the address
 * at an offset of y bytes from the address currently contained in rx.
 */
void Mips::EmitStore(Location *reference, Location *value, int offset)
{
  Register rVal = GetRegister(value), rRef = GetRegister(reference, rVal);
  Emit("sw %s, %d(%s) \t# store with offset",
	 regs[rVal].name, offset, regs[rRef].name);
}


/* Method: EmitBinaryOp
 * --------------------
 * Used to perform a binary operation on 2 operands and store result
 * in dst. All binary forms for arithmetic, logical, relational, equality
 * use this method. Slaves both operands and dst to registers, then
 * emits the appropriate instruction by looking up the mips name
 * for the particular op code.
 */
void Mips::EmitBinaryOp(BinaryOp::OpCode code, Location *dst, 
				 Location *op1, Location *op2)
{
  Register rLeft = GetRegister(op1), rRight = GetRegister(op2, rLeft);
  Register rDst = GetRegisterForWrite(dst, rLeft, rRight);
  Emit("%s %s, %s, %s\t", NameForTac(code), regs[rDst].name,
	 regs[rLeft].name, regs[rRight].name);

}


/* Method: EmitLabel
 * -----------------
 * Used to emit label marker. Before a label, we spill all registers since
 * we can't be sure what the situation upon arriving at this label (ie
 * starts new basic block), and rather than try to be clever, we just
 * wipe the slate clean.
 */
void Mips::EmitLabel(const char *label)
{ 
  SpillAllDirtyRegisters(); 
  Emit("%s:", label);
}


/* Method: EmitGoto
 * ----------------
 * Used for an unconditional transfer to a named label. Before a goto,
 * we spill all registers, since we don't know what the situation is
 * we are heading to (ie this ends current basic block) and rather than
 * try to be clever, we just wipe slate clean.
 */
void Mips::EmitGoto(const char *label)
{
  SpillAllDirtyRegisters(); 
  Emit("b %s\t\t# unconditional branch", label);
}


/* Method: EmitIfZ
 * ---------------
 * Used for a conditional branch based on value of test variable.
 * We slave test var to register and use in the emitted test instruction,
 * either beqz. See comments above on Goto for why we spill
 * all registers here.
 */
void Mips::EmitIfZ(Location *test, const char *label)
{ 
  Register testReg = GetRegister(test);
  SpillAllDirtyRegisters();
  Emit("beqz %s, %s\t# branch if %s is zero ", regs[testReg].name, label,
	 test->GetName());
}


/* Method: EmitParam
 * -----------------
 * Used to push a parameter on the stack in anticipation of upcoming
 * function call. Decrements the stack pointer by 4. Slaves argument into
 * register and then stores contents to location just made at end of
 * stack.
 */
void Mips::EmitParam(Location *arg)
{ 
  Emit("subu $sp, $sp, 4\t# decrement sp to make space for param");
  Register reg = GetRegister(arg);
  Emit("sw %s, 4($sp)\t# copy param value to stack", regs[reg].name);
}


/* Method: EmitCallInstr
 * ---------------------
 * Used to effect a function call. All necessary arguments should have
 * already been pushed on the stack, this is the last step that
 * transfers control from caller to callee.  See comments on Goto method
 * above for why we spill all registers before making the jump. We issue
 * jal for a label, a jalr if address in register. Both will save the
 * return address in $ra. If there is an expected result passed, we slave
 * the var to a register and copy function return value from $v0 into that
 * register.  
 */
void Mips::EmitCallInstr(Location *result, const char *fn, bool isLabel)
{
  SpillAllDirtyRegisters();
  Emit("%s %-15s\t# jump to function", isLabel? "jal": "jalr", fn);
  if (result != NULL) {
    Register r1 = GetRegisterForWrite(result);
    Emit("move %s, %s\t\t# copy function return value from $v0", regs[r1].name, regs[v0].name);
  }
}


// Two covers for the above method for specific LCall/ACall variants
void Mips::EmitLCall(Location *dst, const char *label)
{ 
  EmitCallInstr(dst, label, true);
}

void Mips::EmitACall(Location *dst, Location *fn)
{
  EmitCallInstr(dst, regs[GetRegister(fn)].name, false);
}

/*
 * We remove all parameters from the stack after a completed call
 * by adjusting the stack pointer upwards.
 */
void Mips::EmitPopParams(int bytes)
{
  if (bytes != 0)
    Emit("add $sp, $sp, %d\t# pop params off stack", bytes);
}


/* Method: EmitReturn
 * ------------------
 * Used to emit code for returning from a function (either from an
 * explicit return or falling off the end of the function body).
 * If there is an expression to return, we slave that variable into
 * a register and move its contents to $v0 (the standard register for
 * function result).  Before exiting, we spill dirty registers (to
 * commit contents of slaved registers to memory, necessary for
 * consistency, see comments at SpillForEndFunction above). We also
 * do the last part of the callee's job in function call protocol,
 * which is to remove our locals/temps from the stack, remove
 * saved registers ($fp and $ra) and restore previous values of
 * $fp and $ra so everything is returned to the state we entered.
 * We then emit jr to jump to the saved $ra.
 */
 void Mips::EmitReturn(Location *returnVal)
{ 
  if (returnVal != NULL) 
    Emit("move $v0, %s\t\t# assign return value into $v0",
	   regs[GetRegister(returnVal)].name);
  SpillForEndFunction();
  Emit("move $sp, $fp\t\t# pop callee frame off stack");
  Emit("lw $ra, -4($fp)\t# restore saved ra");
  Emit("lw $fp, 0($fp)\t# restore saved fp");
  Emit("jr $ra\t\t# return from function");
}


/* Method: EmitBeginFunction
 * -------------------------
 * Used to handle the callee's part of the function call protocol
 * upon entering a new function. We decrement the $sp to make space
 * and then save the current values of $fp and $ra (since we are
 * going to change them), then set up the $fp and bump the $sp down
 * to make space for all our locals/temps.
 */
void Mips::EmitBeginFunction(int stackFrameSize)
{
  Assert(stackFrameSize >= 0);
  Emit("subu $sp, $sp, 8\t# decrement sp to make space to save ra, fp");
  Emit("sw $fp, 8($sp)\t# save fp");
  Emit("sw $ra, 4($sp)\t# save ra");
  Emit("addiu $fp, $sp, 8\t# set up new fp");

  if (stackFrameSize != 0)
    Emit("subu $sp, $sp, %d\t# decrement sp to make space for locals/temps",
	   stackFrameSize);
}


/* Method: EmitEndFunction
 * -----------------------
 * Used to end the body of a function. Does an implicit return in fall off
 * case to clean up stack frame, return to caller etc. See comments on
 * EmitReturn above.
 */
void Mips::EmitEndFunction()
{ 
  Emit("# (below handles reaching end of fn body with no explicit return)");
  EmitReturn(NULL);
}



/* Method: EmitVTable
 * ------------------
 * Used to layout a vtable. Uses assembly directives to set up new
 * entry in data segment, emits label, and lays out the function
 * labels one after another.
 */
void Mips::EmitVTable(const char *label, List<const char*> *methodLabels)
{
  Emit(".data");
  Emit(".align 2");
  Emit("%s:\t\t# label for class %s vtable", label, label);
  for (int i = 0; i < methodLabels->NumElements(); i++)
    Emit(".word %s\n", methodLabels->Nth(i));
  Emit(".text");
}


/* Method: EmitPreamble
 * --------------------
 * Used to emit the starting sequence needed for a program. Not much
 * here, but need to indicate what follows is in text segment and
 * needs to be aligned on word boundary. main is our only global symbol.
 */
void Mips::EmitPreamble()
{
  Emit("# standard Decaf preamble ");
  Emit(".text");
  Emit(".align 2");
  Emit(".globl main");
}


/* Method: NameForTac
 * ------------------
 * Returns the appropriate MIPS instruction (add, seq, etc.) for
 * a given BinaryOp:OpCode (BinaryOp::Add, BinaryOp:Equals, etc.). 
 * Asserts if asked for name of an unset/out of bounds code.
 */
const char *Mips::NameForTac(BinaryOp::OpCode code)
{
  Assert(code >=0 && code < BinaryOp::NumOps);
  const char *name = mipsName[code];
  Assert(name != NULL);
  return name;
}

/* Constructor
 * ----------
 * Constructor sets up the mips names and register descriptors to
 * the initial starting state.
 */
Mips::Mips() {
  mipsName[BinaryOp::Add] = "add";
  mipsName[BinaryOp::Sub] = "sub";
  mipsName[BinaryOp::Mul] = "mul";
  mipsName[BinaryOp::Div] = "div";
  mipsName[BinaryOp::Mod] = "rem";
  mipsName[BinaryOp::Eq] = "seq";
  mipsName[BinaryOp::Less] = "slt";
  mipsName[BinaryOp::And] = "and";
  mipsName[BinaryOp::Or] = "or";
  regs[zero] = (RegContents){false, NULL, "$zero", false};
  regs[at] = (RegContents){false, NULL, "$at", false};
  regs[v0] = (RegContents){false, NULL, "$v0", false};
  regs[v1] = (RegContents){false, NULL, "$v1", false};
  regs[a0] = (RegContents){false, NULL, "$a0", false};
  regs[a1] = (RegContents){false, NULL, "$a1", false};
  regs[a2] = (RegContents){false, NULL, "$a2", false};
  regs[a3] = (RegContents){false, NULL, "$a3", false};
  regs[k0] = (RegContents){false, NULL, "$k0", false};
  regs[k1] = (RegContents){false, NULL, "$k1", false};
  regs[gp] = (RegContents){false, NULL, "$gp", false};
  regs[sp] = (RegContents){false, NULL, "$sp", false};
  regs[fp] = (RegContents){false, NULL, "$fp", false};
  regs[ra] = (RegContents){false, NULL, "$ra", false};
  regs[t0] = (RegContents){false, NULL, "$t0", true};
  regs[t1] = (RegContents){false, NULL, "$t1", true};
  regs[t2] = (RegContents){false, NULL, "$t2", true};
  regs[t3] = (RegContents){false, NULL, "$t3", true};
  regs[t4] = (RegContents){false, NULL, "$t4", true};
  regs[t5] = (RegContents){false, NULL, "$t5", true};
  regs[t6] = (RegContents){false, NULL, "$t6", true};
  regs[t7] = (RegContents){false, NULL, "$t7", true};
  regs[t8] = (RegContents){false, NULL, "$t8", true};
  regs[t9] = (RegContents){false, NULL, "$t9", true};
  regs[s0] = (RegContents){false, NULL, "$s0", true};
  regs[s1] = (RegContents){false, NULL, "$s1", true};
  regs[s2] = (RegContents){false, NULL, "$s2", true};
  regs[s3] = (RegContents){false, NULL, "$s3", true};
  regs[s4] = (RegContents){false, NULL, "$s4", true};
  regs[s5] = (RegContents){false, NULL, "$s5", true};
  regs[s6] = (RegContents){false, NULL, "$s6", true};
  regs[s7] = (RegContents){false, NULL, "$s7", true};
  lastUsed = zero;
}
const char *Mips::mipsName[BinaryOp::NumOps];


