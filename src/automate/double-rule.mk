# Regenerate results for "Moby Dick"
results/moby-dick.csv : data/moby-dick.txt
	python bin/countwords.py data/moby-dick.txt > results/moby-dick.csv

# Regenerate results for "Jane Eyre"
results/jane-eyre.csv : data/jane-eyre.txt
	python bin/countwords.py data/jane-eyre.txt > results/jane-eyre.csv
