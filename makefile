NAME:=foo

UNAME := $(shell uname)
INCLUDEPATH := 
LIBPATH := 

ifeq ($(UNAME), Darwin)
	CXXFLAGS+=-Wall -stdlib=libc++ $(INCLUDEPATH)
	CFLAGS+=-ggdb -std=c99 $(INCLUDEPATH)
	LDFLAGS+=-g -stdlib=libc++ $(LIBPATH)
else
	ifeq ($(UNAME), FreeBSD)
		CXX := clang++
		CC := clang
		CFLAGS += -g -Wall $(INCLUDEPATH)
		CXXFLAGS += -g -Wall $(INCLUDEPATH)
		LDFLAGS += -g $(LIBPATH)
	else
		CFLAGS += -ggdb -std=c99 -Wall $(INCLUDEPATH)
		CXXFLAGS += -ggdb -std=c++0x -Wall $(INCLUDEPATH)
		LDFLAGS += -g $(LIBPATH)
	endif
endif

HEADERS:=$(wildcard *.h)
SOURCES:=$(wildcard *.cpp *.c)
OBJS=$(addsuffix .o, $(basename $(SOURCES)))

# generate dependency targets
DEPS:=$(OBJS:%.o=%.depends)

.PHONY: clean all tags show_gcc_implicit_defines

all: $(NAME)

#require inotify-tools (ubuntu)
linux-watch:
	while true ; do inotifywait -qe close_write $(SOURCES) $(HEADERS) makefile; $(MAKE) ; done

#requires /usr/ports/sysutils/wait_on
freebsd-watch:
	while true ; do wait_on $(SOURCES) $(HEADERS) makefile; $(MAKE) ; done

#requires https://github.com/alandipert/fswatch
osx-watch:
	while true ; do fswatch . $(MAKE) ; done

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

