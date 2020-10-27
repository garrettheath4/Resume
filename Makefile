.PHONY: all clean

all: Resume.pdf

%.pdf: %.tex
	pdflatex $<

clean:
	rm Resume.pdf

