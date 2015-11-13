DMD     = dmd
LIB     = funcy.lib
DFLAGS  = -O -release -inline -boundscheck=off -w -Isrc
UTFLAGS = -w -g -debug -unittest
SRCS    = src\package.d src\maybe.d src\either.d
TEST    = test\test.d

# DDoc
DOCS    = *.html
DDOCFLAGS = -Dd. -c -o- -Isrc

target: $(LIB)

$(LIB):
        $(DMD) $(DFLAGS) -lib -of$(LIB) $(SRCS)

doc:
        $(DMD) $(DDOCFLAGS) $(SRCS)

MAIN_FILE = empty_funcy_unittest.d

unittest:
        $(DMD) $(UTFLAGS) -of$(LIB) $(SRCS) -run $(TEST)

clean:
        del $(DOCS) $(LIB)