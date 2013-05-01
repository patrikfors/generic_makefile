NAME:=foo

UNAME := $(shell uname)
ifeq ($(UNAME), Darwin)
	CXXFLAGS+=-Wall -stdlib=libc++
	CFLAGS+=-ggdb -std=c99
	LDFLAGS+=-g -stdlib=libc++
else
	CFLAGS+=-ggdb -std=c99
	CXXFLAGS+=-ggdb -std=c++0x -Wall
	LDFLAGS+=-g
endif

SOURCES:=$(wildcard *.cpp *.c)
OBJS=$(addsuffix .o, $(basename $(SOURCES)))

# generate dependency targets
DEPS:=$(OBJS:%.o=%.depends)

.PHONY: clean all tags show_gcc_implicit_defines

all: $(NAME)

watch:
	while true ; do inotifywait -qe close_write $(SOURCES); $(MAKE) ; done

$(NAME): $(OBJS)
	$(CXX) -o $@ $(LDFLAGS) $^

clean:
	rm -rf $(OBJS) *.elf *.gdb *~ $(DEPS) $(NAME) *.orig

tags:
	ctags -R --c++-kinds=+p --fields=+iaS --extra=+q .

show_gcc_implicit_defines:
	gcc -dM -E - < /dev/null

# pattern rules for generating dependency files
%.depends: %.cpp
	$(CXX) -MM $(CXXFLAGS) $< > $@

%.depends: %.c
	$(CC) -MM $(CFLAGS) $< > $@

#include dependency rules.
-include $(DEPS)

