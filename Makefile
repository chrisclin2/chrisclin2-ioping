CFLAGS+=-std=gnu99 -g -Wall -Wextra -pedantic -D_GNU_SOURCE -D_FILE_OFFSET_BITS=64
LDFLAGS=-lm
PREFIX=/usr/local
BINDIR=$(PREFIX)/bin
MAN1DIR=$(PREFIX)/share/man/man1

SRCS=ioping.c
OBJS=$(SRCS:.c=.o)
BINS=ioping
MANS=ioping.1
SPEC=ioping.spec

PACKAGE=ioping
VERSION=$(shell cat version)
DISTDIR=$(PACKAGE)-$(VERSION)
DISTFILES=$(SRCS) $(MANS) $(SPEC) Makefile

STRIP=strip
TARGET=$(shell ${CC} -dumpmachine | cut -d- -f 2)

ifdef MINGW
CC=i686-w64-mingw32-gcc
STRIP=i686-w64-mingw32-strip
TARGET=win32
BINS:=$(BINS:=.exe)
endif

all: version $(BINS)

version: $(DISTFILES)
	test ! -d .git || git describe --tags --dirty=+ | sed 's/^v//;s/-/./g' > $@

clean:
	$(RM) -f $(OBJS) $(BINS)

install: $(BINS) $(MANS)
	mkdir -p $(DESTDIR)$(BINDIR)
	install -m 0755 $(BINS) $(DESTDIR)$(BINDIR)
	mkdir -p $(DESTDIR)$(MAN1DIR)
	install -m 644 $(MANS) $(DESTDIR)$(MAN1DIR)

%.o: %.c
	$(CC) $(CFLAGS) -DVERSION=\"${VERSION}\" -c -o $@ $^

$(BINS): $(OBJS)
	$(CC) -o $@ $^ $(CFLAGS) $(LDFLAGS)

dist: version $(DISTFILES)
	tar -cz --transform='s,^,$(DISTDIR)/,S' $^ -f $(DISTDIR).tar.gz

binary-tar: clean all
	${STRIP} ${BINS}
	tar czf ${PACKAGE}-${VERSION}-${TARGET}.tgz ${BINS} ${MANS}

binary-zip: clean all ${MANS}
	${STRIP} ${BINS}
	MANWIDTH=80 man ./${MANS} | col -b > ioping.txt
	zip ${PACKAGE}-${VERSION}-${TARGET}.zip ${BINS} ioping.txt

.PHONY: all clean install dist
