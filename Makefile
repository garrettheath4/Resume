.PHONY: all clean

all: Resume.pdf

%.pdf: %.tex
	pdflatex $<

clean:
	rm Resume.pdf

public:
	for f in email phone street; do \
		if [ -f "secret_$$f.txt" ]; then \
			mv "secret_$$f.txt" "secret_$$f.txt.off" ; \
		fi ; \
	done

private:
	for f in email phone street; do \
		if [ -f "secret_$$f.txt.off" ]; then \
			mv "secret_$$f.txt.off" "secret_$$f.txt" ; \
		fi ; \
	done

links:
	exit_code=0 ; \
	for url in $$(ggrep --perl-regexp --only-matching '(?<=\\href{)[^}]+(?=})' Resume.tex); do \
		http_code="$$(curl -I --silent --output /dev/null --write-out '%{http_code}\n' "$$url")" ; \
		if [ "$$http_code" -ne 200 ]; then \
			echo "Warning: URL responded with an HTTP $$http_code error code: $$url" ; \
			exit_code=1 ; \
		fi ; \
	done ; \
	if [ "$$exit_code" -ne 0 ]; then false; fi

