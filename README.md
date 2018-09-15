# K2 GraphSearch
---

[*Structure Learning*], [*Julia*], [*K2 Graph Search*]

**Note:** This code now supports Julia 1.0!

Project for Aero E 504: Decision Making under Uncertainty. Course taught by Professor Peng Wei.
This project implements the K2 Algorithm inspired by Cooper's Algorithm proposed in 1992. This code was also inspired by the Mathworks implementation written by Guangdi Li.

Included are the 3 datasets that the K2 Alogorithm had to run on.
* titanic.csv - least number of variables
* whitewine.csv - medium number of varibles
* schoolgrades.csv - largest number of variables

K2 algorithm was able to find a graph structure that fit the data well. In the julia notebook, I include the number of trials that it took to obtain the graph structure.

## Getting Started
---

1. Install Julia 1.0
2. Go to the Julia command prompt and add the following packages:

```julia
>> using Pkg
>> Pkg.add(“BayesNets”)
>> Pkg.add(“IJulia”)
>> Pkg.add(“DataFrames”)
>> Pkg.add(“Discretizers”)
>> Pkg.add(“LightGraphs”)
>> Pkg.add(“Printf”)
>> Pkg.add(“CSV”)
>> Pkg.add(“Random”)
>> Pkg.add(“SpecialFunctions”)
```

3. Download this repository
4. Now open jupyter and navigate to the repository
5. Open the .ipynb file and make sure that it says julia 1.0.0 in the top right. If not, then you can change the kernel to 1.0 from the kernel tab

