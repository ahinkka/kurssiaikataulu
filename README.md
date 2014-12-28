Run algorithms
--------------

Run Julia implementation:
`$ julia kurssiaikataulu.jl < kurssit.txt > result-julia.txt`

Run Python implementation:
`$ python kurssiaikataulu.py < kurssit.txt > result-python.txt`

Run scoring
-----------

See what the score is:
`$ julia score.jl kurssit.txt < result.txt`


Prerequisites
-------------

For Julia you'll need DataStructures library. Run the following in a Julia
shell to get it: `julia> Pkg.add("DataStructures")`

For Python you'll need bitsets library (run `pip install -r requirements.txt`
in a proper virtualenv).
