## 
## Simple makefile for CS143 programming projects
##

.PHONY: clean strip

# Set the default target. When you make with no arguments,
# this will be the target built.
COMPILER = dcc
PRODUCTS = $(COMPILER) 
default: $(PRODUCTS)

# Set up the list of source and object files
SRCS = ast.cc ast_decl.cc ast_expr.cc ast_stmt.cc ast_type.cc codegen.cc tac.cc mips.cc errors.cc utility.cc main.cc

# OBJS can deal with either .cc or .c files listed in SRCS
OBJS = y.tab.o lex.yy.o $(patsubst %.cc, %.o, $(filter %.cc,$(SRCS))) $(patsubst %.c, %.o, $(filter %.c, $(SRCS)))

JUNK =  *.o lex.yy.c dpp.yy.c y.tab.c y.tab.h *.core core *~

# Define the tools we are going to use
CC= g++
LD = g++
LEX = flex
YACC = bison

# Set up the necessary flags for the tools

# We want debugging and most warnings, but lex/yacc generate some
# static symbols we don't use, so turn off unused warnings to avoid clutter
# Also STL has some signed/unsigned comparisons we want to suppress
CFLAGS = -g -Wall -Wno-unused -Wno-sign-compare

# The -d flag tells lex to set up for debugging. Can turn on/off by
# setting value of global yy_flex_debug inside the scanner itself
LEXFLAGS = -d

# The -d flag tells yacc to generate header with token types
# The -v flag writes out a verbose description of the states and conflicts
# The -t flag turns on debugging capability
# The -y flag means imitate yacc's output file naming conventions
YACCFLAGS = -dvty

# Link with standard C library, math library, and lex library
LIBS = -lc -lm -ll

# Rules for various parts of the target

.yy.o: $*.yy.c
	$(CC) $(CFLAGS) -c -o $@ $*.cc

lex.yy.c: scanner.l  parser.y y.tab.h 
	$(LEX) $(LEXFLAGS) scanner.l

y.tab.o: y.tab.c
	$(CC) $(CFLAGS) -c -o y.tab.o y.tab.c

y.tab.h y.tab.c: parser.y
	$(YACC) $(YACCFLAGS) parser.y
.cc.o: $*.cc
	$(CC) $(CFLAGS) -c -o $@ $*.cc

# rules to build compiler (dcc)

$(COMPILER) :  $(OBJS)
	$(LD) -o $@ $(OBJS) $(LIBS)


# This target is to build small for testing (no debugging info), removes
# all intermediate products, too
strip : $(PRODUCTS)
	strip $(PRODUCTS)
	rm -rf $(JUNK)


# make depend will set up the header file dependencies for the 
# assignment.  You should make depend whenever you add a new header
# file to the project or move the project between machines
#
depend:
	makedepend -- $(CFLAGS) -- $(SRCS)

clean:
	rm -f $(JUNK) y.output $(PRODUCTS)

# DO NOT DELETE

ast.o: /usr/include/stdio.h /usr/include/features.h
ast.o: /usr/include/bits/predefs.h /usr/include/sys/cdefs.h
ast.o: /usr/include/bits/wordsize.h /usr/include/gnu/stubs.h
ast.o: /usr/include/gnu/stubs-32.h /usr/include/bits/types.h
ast.o: /usr/include/bits/typesizes.h /usr/include/libio.h
ast.o: /usr/include/_G_config.h /usr/include/wchar.h
ast.o: /usr/include/bits/stdio_lim.h /usr/include/bits/sys_errlist.h
ast.o: /usr/include/string.h /usr/include/xlocale.h ast.h
ast.o: /usr/include/stdlib.h /usr/include/bits/waitflags.h
ast.o: /usr/include/bits/waitstatus.h /usr/include/endian.h
ast.o: /usr/include/bits/endian.h /usr/include/bits/byteswap.h
ast.o: /usr/include/sys/types.h /usr/include/time.h /usr/include/sys/select.h
ast.o: /usr/include/bits/select.h /usr/include/bits/sigset.h
ast.o: /usr/include/bits/time.h /usr/include/sys/sysmacros.h
ast.o: /usr/include/bits/pthreadtypes.h /usr/include/alloca.h errors.h
ast.o: location.h hashtable.h hashtable.cc list.h utility.h ast_decl.h
ast.o: ast_type.h ast_stmt.h
ast_decl.o: /usr/include/stdio.h /usr/include/features.h
ast_decl.o: /usr/include/bits/predefs.h /usr/include/sys/cdefs.h
ast_decl.o: /usr/include/bits/wordsize.h /usr/include/gnu/stubs.h
ast_decl.o: /usr/include/gnu/stubs-32.h /usr/include/bits/types.h
ast_decl.o: /usr/include/bits/typesizes.h /usr/include/libio.h
ast_decl.o: /usr/include/_G_config.h /usr/include/wchar.h
ast_decl.o: /usr/include/bits/stdio_lim.h /usr/include/bits/sys_errlist.h
ast_decl.o: /usr/include/string.h /usr/include/xlocale.h ast_decl.h ast.h
ast_decl.o: /usr/include/stdlib.h /usr/include/bits/waitflags.h
ast_decl.o: /usr/include/bits/waitstatus.h /usr/include/endian.h
ast_decl.o: /usr/include/bits/endian.h /usr/include/bits/byteswap.h
ast_decl.o: /usr/include/sys/types.h /usr/include/time.h
ast_decl.o: /usr/include/sys/select.h /usr/include/bits/select.h
ast_decl.o: /usr/include/bits/sigset.h /usr/include/bits/time.h
ast_decl.o: /usr/include/sys/sysmacros.h /usr/include/bits/pthreadtypes.h
ast_decl.o: /usr/include/alloca.h errors.h location.h hashtable.h
ast_decl.o: hashtable.cc list.h utility.h ast_type.h ast_stmt.h codegen.h
ast_decl.o: tac.h
ast_expr.o: /usr/include/string.h /usr/include/features.h
ast_expr.o: /usr/include/bits/predefs.h /usr/include/sys/cdefs.h
ast_expr.o: /usr/include/bits/wordsize.h /usr/include/gnu/stubs.h
ast_expr.o: /usr/include/gnu/stubs-32.h /usr/include/xlocale.h ast_expr.h
ast_expr.o: ast.h /usr/include/stdlib.h /usr/include/bits/waitflags.h
ast_expr.o: /usr/include/bits/waitstatus.h /usr/include/endian.h
ast_expr.o: /usr/include/bits/endian.h /usr/include/bits/byteswap.h
ast_expr.o: /usr/include/sys/types.h /usr/include/bits/types.h
ast_expr.o: /usr/include/bits/typesizes.h /usr/include/time.h
ast_expr.o: /usr/include/sys/select.h /usr/include/bits/select.h
ast_expr.o: /usr/include/bits/sigset.h /usr/include/bits/time.h
ast_expr.o: /usr/include/sys/sysmacros.h /usr/include/bits/pthreadtypes.h
ast_expr.o: /usr/include/alloca.h errors.h location.h hashtable.h
ast_expr.o: hashtable.cc list.h utility.h /usr/include/stdio.h
ast_expr.o: /usr/include/libio.h /usr/include/_G_config.h
ast_expr.o: /usr/include/wchar.h /usr/include/bits/stdio_lim.h
ast_expr.o: /usr/include/bits/sys_errlist.h ast_stmt.h ast_type.h ast_decl.h
ast_expr.o: codegen.h tac.h
ast_stmt.o: ast_stmt.h ast.h /usr/include/stdlib.h /usr/include/features.h
ast_stmt.o: /usr/include/bits/predefs.h /usr/include/sys/cdefs.h
ast_stmt.o: /usr/include/bits/wordsize.h /usr/include/gnu/stubs.h
ast_stmt.o: /usr/include/gnu/stubs-32.h /usr/include/bits/waitflags.h
ast_stmt.o: /usr/include/bits/waitstatus.h /usr/include/endian.h
ast_stmt.o: /usr/include/bits/endian.h /usr/include/bits/byteswap.h
ast_stmt.o: /usr/include/sys/types.h /usr/include/bits/types.h
ast_stmt.o: /usr/include/bits/typesizes.h /usr/include/time.h
ast_stmt.o: /usr/include/sys/select.h /usr/include/bits/select.h
ast_stmt.o: /usr/include/bits/sigset.h /usr/include/bits/time.h
ast_stmt.o: /usr/include/sys/sysmacros.h /usr/include/bits/pthreadtypes.h
ast_stmt.o: /usr/include/alloca.h errors.h location.h hashtable.h
ast_stmt.o: /usr/include/string.h /usr/include/xlocale.h hashtable.cc list.h
ast_stmt.o: utility.h /usr/include/stdio.h /usr/include/libio.h
ast_stmt.o: /usr/include/_G_config.h /usr/include/wchar.h
ast_stmt.o: /usr/include/bits/stdio_lim.h /usr/include/bits/sys_errlist.h
ast_stmt.o: ast_type.h ast_decl.h ast_expr.h codegen.h tac.h
ast_type.o: /usr/include/string.h /usr/include/features.h
ast_type.o: /usr/include/bits/predefs.h /usr/include/sys/cdefs.h
ast_type.o: /usr/include/bits/wordsize.h /usr/include/gnu/stubs.h
ast_type.o: /usr/include/gnu/stubs-32.h /usr/include/xlocale.h ast_type.h
ast_type.o: ast.h /usr/include/stdlib.h /usr/include/bits/waitflags.h
ast_type.o: /usr/include/bits/waitstatus.h /usr/include/endian.h
ast_type.o: /usr/include/bits/endian.h /usr/include/bits/byteswap.h
ast_type.o: /usr/include/sys/types.h /usr/include/bits/types.h
ast_type.o: /usr/include/bits/typesizes.h /usr/include/time.h
ast_type.o: /usr/include/sys/select.h /usr/include/bits/select.h
ast_type.o: /usr/include/bits/sigset.h /usr/include/bits/time.h
ast_type.o: /usr/include/sys/sysmacros.h /usr/include/bits/pthreadtypes.h
ast_type.o: /usr/include/alloca.h errors.h location.h hashtable.h
ast_type.o: hashtable.cc list.h utility.h /usr/include/stdio.h
ast_type.o: /usr/include/libio.h /usr/include/_G_config.h
ast_type.o: /usr/include/wchar.h /usr/include/bits/stdio_lim.h
ast_type.o: /usr/include/bits/sys_errlist.h ast_decl.h ast_stmt.h
codegen.o: codegen.h /usr/include/stdlib.h /usr/include/features.h
codegen.o: /usr/include/bits/predefs.h /usr/include/sys/cdefs.h
codegen.o: /usr/include/bits/wordsize.h /usr/include/gnu/stubs.h
codegen.o: /usr/include/gnu/stubs-32.h /usr/include/bits/waitflags.h
codegen.o: /usr/include/bits/waitstatus.h /usr/include/endian.h
codegen.o: /usr/include/bits/endian.h /usr/include/bits/byteswap.h
codegen.o: /usr/include/sys/types.h /usr/include/bits/types.h
codegen.o: /usr/include/bits/typesizes.h /usr/include/time.h
codegen.o: /usr/include/sys/select.h /usr/include/bits/select.h
codegen.o: /usr/include/bits/sigset.h /usr/include/bits/time.h
codegen.o: /usr/include/sys/sysmacros.h /usr/include/bits/pthreadtypes.h
codegen.o: /usr/include/alloca.h list.h utility.h /usr/include/stdio.h
codegen.o: /usr/include/libio.h /usr/include/_G_config.h /usr/include/wchar.h
codegen.o: /usr/include/bits/stdio_lim.h /usr/include/bits/sys_errlist.h
codegen.o: tac.h /usr/include/string.h /usr/include/xlocale.h mips.h
tac.o: tac.h list.h utility.h /usr/include/stdlib.h /usr/include/features.h
tac.o: /usr/include/bits/predefs.h /usr/include/sys/cdefs.h
tac.o: /usr/include/bits/wordsize.h /usr/include/gnu/stubs.h
tac.o: /usr/include/gnu/stubs-32.h /usr/include/bits/waitflags.h
tac.o: /usr/include/bits/waitstatus.h /usr/include/endian.h
tac.o: /usr/include/bits/endian.h /usr/include/bits/byteswap.h
tac.o: /usr/include/sys/types.h /usr/include/bits/types.h
tac.o: /usr/include/bits/typesizes.h /usr/include/time.h
tac.o: /usr/include/sys/select.h /usr/include/bits/select.h
tac.o: /usr/include/bits/sigset.h /usr/include/bits/time.h
tac.o: /usr/include/sys/sysmacros.h /usr/include/bits/pthreadtypes.h
tac.o: /usr/include/alloca.h /usr/include/stdio.h /usr/include/libio.h
tac.o: /usr/include/_G_config.h /usr/include/wchar.h
tac.o: /usr/include/bits/stdio_lim.h /usr/include/bits/sys_errlist.h mips.h
tac.o: /usr/include/string.h /usr/include/xlocale.h
mips.o: mips.h tac.h list.h utility.h /usr/include/stdlib.h
mips.o: /usr/include/features.h /usr/include/bits/predefs.h
mips.o: /usr/include/sys/cdefs.h /usr/include/bits/wordsize.h
mips.o: /usr/include/gnu/stubs.h /usr/include/gnu/stubs-32.h
mips.o: /usr/include/bits/waitflags.h /usr/include/bits/waitstatus.h
mips.o: /usr/include/endian.h /usr/include/bits/endian.h
mips.o: /usr/include/bits/byteswap.h /usr/include/sys/types.h
mips.o: /usr/include/bits/types.h /usr/include/bits/typesizes.h
mips.o: /usr/include/time.h /usr/include/sys/select.h
mips.o: /usr/include/bits/select.h /usr/include/bits/sigset.h
mips.o: /usr/include/bits/time.h /usr/include/sys/sysmacros.h
mips.o: /usr/include/bits/pthreadtypes.h /usr/include/alloca.h
mips.o: /usr/include/stdio.h /usr/include/libio.h /usr/include/_G_config.h
mips.o: /usr/include/wchar.h /usr/include/bits/stdio_lim.h
mips.o: /usr/include/bits/sys_errlist.h /usr/include/string.h
mips.o: /usr/include/xlocale.h
errors.o: errors.h location.h /usr/include/stdio.h /usr/include/features.h
errors.o: /usr/include/bits/predefs.h /usr/include/sys/cdefs.h
errors.o: /usr/include/bits/wordsize.h /usr/include/gnu/stubs.h
errors.o: /usr/include/gnu/stubs-32.h /usr/include/bits/types.h
errors.o: /usr/include/bits/typesizes.h /usr/include/libio.h
errors.o: /usr/include/_G_config.h /usr/include/wchar.h
errors.o: /usr/include/bits/stdio_lim.h /usr/include/bits/sys_errlist.h
errors.o: scanner.h ast_type.h /usr/include/string.h /usr/include/xlocale.h
errors.o: ast.h /usr/include/stdlib.h /usr/include/bits/waitflags.h
errors.o: /usr/include/bits/waitstatus.h /usr/include/endian.h
errors.o: /usr/include/bits/endian.h /usr/include/bits/byteswap.h
errors.o: /usr/include/sys/types.h /usr/include/time.h
errors.o: /usr/include/sys/select.h /usr/include/bits/select.h
errors.o: /usr/include/bits/sigset.h /usr/include/bits/time.h
errors.o: /usr/include/sys/sysmacros.h /usr/include/bits/pthreadtypes.h
errors.o: /usr/include/alloca.h hashtable.h hashtable.cc list.h utility.h
errors.o: ast_expr.h ast_stmt.h ast_decl.h
utility.o: utility.h /usr/include/stdlib.h /usr/include/features.h
utility.o: /usr/include/bits/predefs.h /usr/include/sys/cdefs.h
utility.o: /usr/include/bits/wordsize.h /usr/include/gnu/stubs.h
utility.o: /usr/include/gnu/stubs-32.h /usr/include/bits/waitflags.h
utility.o: /usr/include/bits/waitstatus.h /usr/include/endian.h
utility.o: /usr/include/bits/endian.h /usr/include/bits/byteswap.h
utility.o: /usr/include/sys/types.h /usr/include/bits/types.h
utility.o: /usr/include/bits/typesizes.h /usr/include/time.h
utility.o: /usr/include/sys/select.h /usr/include/bits/select.h
utility.o: /usr/include/bits/sigset.h /usr/include/bits/time.h
utility.o: /usr/include/sys/sysmacros.h /usr/include/bits/pthreadtypes.h
utility.o: /usr/include/alloca.h /usr/include/stdio.h /usr/include/libio.h
utility.o: /usr/include/_G_config.h /usr/include/wchar.h
utility.o: /usr/include/bits/stdio_lim.h /usr/include/bits/sys_errlist.h
utility.o: /usr/include/string.h /usr/include/xlocale.h
main.o: /usr/include/string.h /usr/include/features.h
main.o: /usr/include/bits/predefs.h /usr/include/sys/cdefs.h
main.o: /usr/include/bits/wordsize.h /usr/include/gnu/stubs.h
main.o: /usr/include/gnu/stubs-32.h /usr/include/xlocale.h
main.o: /usr/include/stdio.h /usr/include/bits/types.h
main.o: /usr/include/bits/typesizes.h /usr/include/libio.h
main.o: /usr/include/_G_config.h /usr/include/wchar.h
main.o: /usr/include/bits/stdio_lim.h /usr/include/bits/sys_errlist.h
main.o: utility.h /usr/include/stdlib.h /usr/include/bits/waitflags.h
main.o: /usr/include/bits/waitstatus.h /usr/include/endian.h
main.o: /usr/include/bits/endian.h /usr/include/bits/byteswap.h
main.o: /usr/include/sys/types.h /usr/include/time.h
main.o: /usr/include/sys/select.h /usr/include/bits/select.h
main.o: /usr/include/bits/sigset.h /usr/include/bits/time.h
main.o: /usr/include/sys/sysmacros.h /usr/include/bits/pthreadtypes.h
main.o: /usr/include/alloca.h errors.h location.h parser.h scanner.h list.h
main.o: ast.h hashtable.h hashtable.cc ast_type.h ast_decl.h ast_expr.h
main.o: ast_stmt.h y.tab.h
