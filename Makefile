.PHONY: all clean public private phone force check-files

SHARED_TEX = resume_preamble.tex resume_toggle_defaults.tex resume_content.tex

all: Resume.pdf Resume_private.pdf Resume_phone.pdf Mews/Resume_Mews.pdf Airwallex/Resume_Airwallex.pdf agap2/Resume_agap2.pdf Cboe/Resume_Cboe.pdf DataSnipper/Resume_DataSnipper.pdf JetBrains/Resume_JetBrains.pdf Swap/Resume_Swap.pdf Teero/Resume_Teero.pdf CV/CV.pdf CV/CV_private.pdf CV/CV_phone.pdf

Resume.pdf: Resume.tex $(SHARED_TEX)
	$(MAKE) public
	/Library/TeX/texbin/pdflatex -jobname=Resume Resume.tex
	$(MAKE) clean-secrets

Mews/Resume_Mews.pdf: Mews/Resume_Mews.tex $(SHARED_TEX)
	$(MAKE) private
	/Library/TeX/texbin/pdflatex -output-directory=Mews -jobname=Resume_Mews Mews/Resume_Mews.tex
	$(MAKE) clean-secrets

CV/CV.pdf: CV/CV.tex $(SHARED_TEX)
	$(MAKE) public
	/Library/TeX/texbin/pdflatex -output-directory=CV -jobname=CV CV/CV.tex
	$(MAKE) clean-secrets

Airwallex/Resume_Airwallex.pdf: Airwallex/Resume_Airwallex.tex $(SHARED_TEX)
	$(MAKE) public
	/Library/TeX/texbin/pdflatex -output-directory=Airwallex -jobname=Resume_Airwallex Airwallex/Resume_Airwallex.tex
	$(MAKE) clean-secrets

agap2/Resume_agap2.pdf: agap2/Resume_agap2.tex $(SHARED_TEX)
	$(MAKE) public
	/Library/TeX/texbin/pdflatex -output-directory=agap2 -jobname=Resume_agap2 agap2/Resume_agap2.tex
	$(MAKE) clean-secrets

Cboe/Resume_Cboe.pdf: Cboe/Resume_Cboe.tex $(SHARED_TEX)
	$(MAKE) public
	/Library/TeX/texbin/pdflatex -output-directory=Cboe -jobname=Resume_Cboe Cboe/Resume_Cboe.tex
	$(MAKE) clean-secrets

DataSnipper/Resume_DataSnipper.pdf: DataSnipper/Resume_DataSnipper.tex $(SHARED_TEX)
	$(MAKE) public
	/Library/TeX/texbin/pdflatex -output-directory=DataSnipper -jobname=Resume_DataSnipper DataSnipper/Resume_DataSnipper.tex
	$(MAKE) clean-secrets

JetBrains/Resume_JetBrains.pdf: JetBrains/Resume_JetBrains.tex $(SHARED_TEX)
	$(MAKE) public
	/Library/TeX/texbin/pdflatex -output-directory=JetBrains -jobname=Resume_JetBrains JetBrains/Resume_JetBrains.tex
	$(MAKE) clean-secrets

Swap/Resume_Swap.pdf: Swap/Resume_Swap.tex $(SHARED_TEX)
	$(MAKE) public
	/Library/TeX/texbin/pdflatex -output-directory=Swap -jobname=Resume_Swap Swap/Resume_Swap.tex
	$(MAKE) clean-secrets

Teero/Resume_Teero.pdf: Teero/Resume_Teero.tex $(SHARED_TEX)
	$(MAKE) public
	/Library/TeX/texbin/pdflatex -output-directory=Teero -jobname=Resume_Teero Teero/Resume_Teero.tex
	$(MAKE) clean-secrets

Resume_private.pdf: Resume.tex
	$(MAKE) private
	/Library/TeX/texbin/pdflatex -jobname=Resume_private Resume.tex
	$(MAKE) clean-secrets

Resume_phone.pdf: Resume.tex
	$(MAKE) phone
	/Library/TeX/texbin/pdflatex -jobname=Resume_phone Resume.tex
	$(MAKE) clean-secrets

CV/CV_private.pdf: CV/CV.tex $(SHARED_TEX)
	$(MAKE) private
	/Library/TeX/texbin/pdflatex -output-directory=CV -jobname=CV_private CV/CV.tex
	$(MAKE) clean-secrets

CV/CV_phone.pdf: CV/CV.tex $(SHARED_TEX)
	$(MAKE) phone
	/Library/TeX/texbin/pdflatex -output-directory=CV -jobname=CV_phone CV/CV.tex
	$(MAKE) clean-secrets

clean:
	rm -f Resume.pdf Resume_private.pdf Resume_phone.pdf *.aux *.log *.out
	rm -f Mews/Resume_Mews.pdf Mews/Resume_Mews.aux Mews/Resume_Mews.log Mews/Resume_Mews.out
	rm -f Airwallex/Resume_Airwallex.pdf Airwallex/Resume_Airwallex.aux Airwallex/Resume_Airwallex.log Airwallex/Resume_Airwallex.out
	rm -f agap2/Resume_agap2.pdf agap2/Resume_agap2.aux agap2/Resume_agap2.log agap2/Resume_agap2.out
	rm -f Cboe/Resume_Cboe.pdf Cboe/Resume_Cboe.aux Cboe/Resume_Cboe.log Cboe/Resume_Cboe.out
	rm -f DataSnipper/Resume_DataSnipper.pdf DataSnipper/Resume_DataSnipper.aux DataSnipper/Resume_DataSnipper.log DataSnipper/Resume_DataSnipper.out
	rm -f JetBrains/Resume_JetBrains.pdf JetBrains/Resume_JetBrains.aux JetBrains/Resume_JetBrains.log JetBrains/Resume_JetBrains.out
	rm -f Swap/Resume_Swap.pdf Swap/Resume_Swap.aux Swap/Resume_Swap.log Swap/Resume_Swap.out
	rm -f Teero/Resume_Teero.pdf Teero/Resume_Teero.aux Teero/Resume_Teero.log Teero/Resume_Teero.out
	rm -f CV/CV.pdf CV/CV_private.pdf CV/CV_phone.pdf CV/CV.aux CV/CV_private.aux CV/CV_phone.aux CV/CV.log CV/CV_private.log CV/CV_phone.log CV/CV.out CV/CV_private.out CV/CV_phone.out

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

