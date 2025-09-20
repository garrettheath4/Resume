.PHONY: all clean public private phone force

all: Resume.pdf Resume_private.pdf Resume_phone.pdf

Resume.pdf: Resume.tex
	$(MAKE) public
	/Library/TeX/texbin/pdflatex -jobname=Resume Resume.tex
	$(MAKE) clean-secrets

Resume_private.pdf: Resume.tex
	$(MAKE) private
	/Library/TeX/texbin/pdflatex -jobname=Resume_private Resume.tex
	$(MAKE) clean-secrets

Resume_phone.pdf: Resume.tex
	$(MAKE) phone
	/Library/TeX/texbin/pdflatex -jobname=Resume_phone Resume.tex
	$(MAKE) clean-secrets

clean:
	rm -f Resume.pdf Resume_private.pdf Resume_phone.pdf *.aux *.log *.out

# Reset secret files back to "safe" state after a build
clean-secrets:
	$(MAKE) public

open:
	open Resume.pdf

edit:
	open Resume.tex

public: force
	for f in email phone street; do \
		if [ -f "secret_$$f.txt" ]; then \
			mv "secret_$$f.txt" "secret_$$f.txt.off" ; \
		fi ; \
	done

private: force
	for f in email phone street; do \
		if [ -f "secret_$$f.txt.off" ]; then \
			mv "secret_$$f.txt.off" "secret_$$f.txt" ; \
		fi ; \
	done

phone: force
	for f in email; do \
		if [ -f "secret_$$f.txt" ]; then \
			mv "secret_$$f.txt" "secret_$$f.txt.off" ; \
		fi ; \
	done
	for f in phone street; do \
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

force:
	touch Resume.tex

