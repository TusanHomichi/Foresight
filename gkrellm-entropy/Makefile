DESTDIR = 
LIBDIR = 

.PHONY: clean uninstall

all: gkrellm-entropy.so

clean:
	rm -rf *.o *.so *~

install: all
	install -D gkrellm-entropy.so $(DESTDIR)/$(LIBDIR)/gkrellm2/plugins/gkrellm-entropy.so

uninstall:
	rm $(LIBDIR)/gkrellm2/plugins/gkrellm-entropy.so

gkrellm-entropy.so: gkrellm-entropy.o
	gcc -shared -Wl -o gkrellm-entropy.so gkrellm-entropy.o

gkrellm-entropy.o:
	gcc -fPIC `pkg-config gtk+-2.0 --cflags` -c gkrellm-entropy.c
