CC=pdflatex
PAPER=documentation

all: $(PAPER)
	
$(PAPER): 
	$(CC) $@  &&  $(CC) $@ && $(CC) $@

clean:
	rm -f *~ *.aux *.bbl *.blg *.dvi *.idx *.ilg *.ind *.loa *.lof *.log *.lot 
	rm -f *.nlo *.out *.thm *.toc texput.log x.log *.bak *.ps
