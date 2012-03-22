NAME:=foo

CFLAGS+=-ggdb -std=c99
CXXFLAGS+=-ggdb -std=c++0x
LDFLAGS+=-g

SOURCES:=$(wildcard *.cpp *.c)
OBJS=$(addsuffix .o, $(basename $(SOURCES)))

# generate dependency targets
DEPS:=$(OBJS:%.o=%.depends)

.PHONY: clean all tags

all: $(NAME)

$(NAME): $(OBJS)
	$(CXX) -o $@ $(LDFLAGS) $^


clean:
	rm -rf $(OBJS) *.elf *.gdb *~ $(DEPS) $(NAME) *.orig

tags:
	ctags -R --c++-kinds=+p --fields=+iaS --extra=+q .

# pattern rules for generating dependency files
%.depends: %.cpp
	$(CXX) -MM $(CXXFLAGS) $< > $@

%.depends: %.c
	$(CC) -MM $(CFLAGS) $< > $@

#include dependency rules.
-include $(DEPS)

