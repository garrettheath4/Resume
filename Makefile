.PHONY: all clean public private phone force check-files

SHARED_TEX = resume_preamble.tex resume_toggle_defaults.tex resume_content.tex
COVERLETTER_SHARED_TEX = coverletter_preamble.tex

# Company-specific resume variants: <Company>/Resume_<Company>.tex -> <Company>/Resume_<Company>.pdf
# Add a new company here (and to CV_COMPANIES/COVERLETTER_COMPANIES too, if it also has those variants) -- no other
# targets need editing, and do NOT add a per-company row to README.md either (see the agent note there).
COMPANIES = Mews Airwallex agap2 Cboe DataSnipper JetBrains Swap Teero Picnic Syntho

# Company-specific CV variants: <Company>/CV_<Company>.tex -> <Company>/CV_<Company>.pdf
CV_COMPANIES = Picnic Syntho

# Company-specific cover letters: <Company>/CoverLetter_<Company>.tex -> <Company>/CoverLetter_<Company>.pdf
COVERLETTER_COMPANIES = Syntho

# Contact-info mode for each company resume; defaults to "public" unless overridden here (see % pattern rule below)
PRIVACY_Mews = private

RESUME_PDFS = $(foreach c,$(COMPANIES),$(c)/Resume_$(c).pdf)
CV_COMPANY_PDFS = $(foreach c,$(CV_COMPANIES),$(c)/CV_$(c).pdf)
COVERLETTER_PDFS = $(foreach c,$(COVERLETTER_COMPANIES),$(c)/CoverLetter_$(c).pdf)

all: Resume.pdf Resume_private.pdf Resume_phone.pdf $(RESUME_PDFS) CV/CV.pdf CV/CV_private.pdf CV/CV_phone.pdf $(CV_COMPANY_PDFS) $(COVERLETTER_PDFS)

Resume.pdf: Resume.tex $(SHARED_TEX)
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

CV/CV.pdf: CV/CV.tex $(SHARED_TEX)
	$(MAKE) public
	/Library/TeX/texbin/pdflatex -output-directory=CV -jobname=CV CV/CV.tex
	$(MAKE) clean-secrets

CV/CV_private.pdf: CV/CV.tex $(SHARED_TEX)
	$(MAKE) private
	/Library/TeX/texbin/pdflatex -output-directory=CV -jobname=CV_private CV/CV.tex
	$(MAKE) clean-secrets

CV/CV_phone.pdf: CV/CV.tex $(SHARED_TEX)
	$(MAKE) phone
	/Library/TeX/texbin/pdflatex -output-directory=CV -jobname=CV_phone CV/CV.tex
	$(MAKE) clean-secrets

# GNU Make pattern rules only support a single '%' per target, so a shared "%/Resume_%.pdf"-style pattern can't
# express "directory name == company name". Instead, generate one real rule per company via eval+call.
define RESUME_RULE
$(1)/Resume_$(1).pdf: $(1)/Resume_$(1).tex $$(SHARED_TEX)
	$$(MAKE) $$(or $$(PRIVACY_$(1)),public)
	/Library/TeX/texbin/pdflatex -output-directory=$(1) -jobname=Resume_$(1) $(1)/Resume_$(1).tex
	$$(MAKE) clean-secrets
endef
$(foreach c,$(COMPANIES),$(eval $(call RESUME_RULE,$(c))))

define CV_RULE
$(1)/CV_$(1).pdf: $(1)/CV_$(1).tex $$(SHARED_TEX)
	$$(MAKE) public
	/Library/TeX/texbin/pdflatex -output-directory=$(1) -jobname=CV_$(1) $(1)/CV_$(1).tex
	$$(MAKE) clean-secrets
endef
$(foreach c,$(CV_COMPANIES),$(eval $(call CV_RULE,$(c))))

# Cover letters use XeLaTeX (not pdflatex) so fontspec can load named macOS system fonts (Avenir Next, Publico) --
# see coverletter_preamble.tex.
define COVERLETTER_RULE
$(1)/CoverLetter_$(1).pdf: $(1)/CoverLetter_$(1).tex $$(COVERLETTER_SHARED_TEX)
	$$(MAKE) public
	/Library/TeX/texbin/xelatex -output-directory=$(1) -jobname=CoverLetter_$(1) $(1)/CoverLetter_$(1).tex
	$$(MAKE) clean-secrets
endef
$(foreach c,$(COVERLETTER_COMPANIES),$(eval $(call COVERLETTER_RULE,$(c))))

clean:
	rm -f Resume.pdf Resume_private.pdf Resume_phone.pdf *.aux *.log *.out
	rm -f $(foreach c,$(COMPANIES),$(c)/Resume_$(c).pdf $(c)/Resume_$(c).aux $(c)/Resume_$(c).log $(c)/Resume_$(c).out)
	rm -f CV/CV.pdf CV/CV_private.pdf CV/CV_phone.pdf CV/CV.aux CV/CV_private.aux CV/CV_phone.aux CV/CV.log CV/CV_private.log CV/CV_phone.log CV/CV.out CV/CV_private.out CV/CV_phone.out
	rm -f $(foreach c,$(CV_COMPANIES),$(c)/CV_$(c).pdf $(c)/CV_$(c).aux $(c)/CV_$(c).log $(c)/CV_$(c).out)
	rm -f $(foreach c,$(COVERLETTER_COMPANIES),$(c)/CoverLetter_$(c).pdf $(c)/CoverLetter_$(c).aux $(c)/CoverLetter_$(c).log $(c)/CoverLetter_$(c).out)

# Reset secret files back to "safe" state after a build
clean-secrets:
	$(MAKE) public

open:
	open Resume.pdf

edit:
	open Resume.tex

check-files:
	@test -f public_email.txt || { echo "Error: public_email.txt not found — create it containing your public email address" >&2; exit 1; }

public: force check-files
	for f in email phone street; do \
		if [ -f "secret_$$f.txt" ]; then \
			mv "secret_$$f.txt" "secret_$$f.txt.off" ; \
		fi ; \
	done

private: force check-files
	for f in email phone street; do \
		if [ -f "secret_$$f.txt.off" ]; then \
			mv "secret_$$f.txt.off" "secret_$$f.txt" ; \
		fi ; \
	done

phone: force check-files
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
