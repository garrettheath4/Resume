.PHONY: all clean

all: Resume.pdf

%.pdf: %.tex
	pdflatex $<

clean:
	rm Resume.pdf

public:
	for f in email phone street; do if [ -f "secret_$f.txt" ]; then mv "secret_$f.txt" "secret_$f.txt.off" ; fi ; done

private:
	for f in email phone street; do if [ -f "secret_$f.txt.off" ]; then mv "secret_$f.txt.off" "secret_$f.txt" ; fi ; done

