function k2(DataObj,Order,u)

    # implementation of the K2 algoithm.
    # input is the DataObj which is the julia version of a Object. Contains all the information of the dataset
    # Order is the given topological sort for network
    # u is the max number of parents for a given node


    # copying the object to a new variable

    LG = DataObj;

    #number of variables in the dataset
    Dim = LG.VarNumber;

    # initial graph structure. We assume fully unconnected graph
    DAG = zeros(Dim,Dim);

    # initialize the K2Score this is dependant on the G-function and provides the search strategy for
    # finding the network structure
    K2Score = zeros(1,Dim);

    for p = 2:Dim

        # initialize a parent vector for a given node. The for loop means we are going to try a
        # a different number of parents for the node

        parent = zeros(Dim,1);

        # Ok is a helper function so that when we do not find a better score we break out of the loop and move on

        Ok = 1;
        P_old = -Inf; #the initiate state

        # sum of parents must be less than or equal to u since u is our max number of parents for a given node

        while Ok == 1 && sum(parent) <= u

            #initial local max
            LocalMax = -Inf;

            # our initial node
            LocalNode = 0;

            # q is going to be a node from the topological sort to adjust
            for q = (p-1):(-1):1

                if parent[Order[q]] == 0

                    # Don't forget that Order is our topological sort so when we index order we are
                    # selecting a node. Now by indexing parent, we are seeing if there is a parent for this node.

                    # greedily add a parent to this node
                    parent[Order[q]] = 1;

                    # finder finds (shocker haha) the indicies of parent which correspond to the children

                    temp_parent = reshape(parent,length(parent),)



                    finder = reshape(findall(x -> x==1,temp_parent),1,length(findall(x -> x==1,temp_parent)));

                    # calculate the G-function on this neighborhood operation to see if it improves our score
                    LocalScore = GFunction(DataObj, Order[p],finder);

                    # conditional statement to say which neighborhood option to choose
                    if LocalScore > LocalMax
                        LocalMax = LocalScore;
                        LocalNode = Order[q]
                    end
                    parent[Order[q]] = 0;
                end
            end

            # update our state to the new value
            P_new = LocalMax;
            if P_new > P_old
                P_old = P_new;

                # if the score is better then update our parent to now have the child
                parent[LocalNode] = 1;
            else

                # if it is not then break out of the loop and move on
                Ok = 0;
            end
        end
        K2Score[Order[p]] = P_old;
        DAG[:,Order[p]] = parent;
    end

    # how you return values in julia
    DAG ,K2Score
end




function DimensionRangeValue(OriginalData,Vec)

    #finds the range of values for each variable
    #input is the original data as well as a vector corresponding to the number of variables

    # very much a pain in julia
    # you have to define a local variable if it is initialized in a for-loop because everything in the
    # loop can not be used outside of the loop
    # local variable
    local Dim

    CountNumber = 0;
    D = size(Vec,1);
    if size(Vec,2) > 1
        Vec = Vec';
    end
    DimLength = zeros(D);

    # CountNumber stores the maximun value of the column of the Dim matrix, keep in mind that it may increase

    t = 0;

    # D is our number of variables
    for q = 1:D

        # finds all of the unique values in each variable
        TempVector = reshape(sort(unique(OriginalData[:,Vec[q]]')),1,length(unique(OriginalData[:,Vec[q]]')));
        if TempVector[1] == -1
            TempVector[1]=[];
        end

        # number of unique values
        RangeNumber = size(TempVector,2);
        DimLength[q] = RangeNumber;
        t = t + 1;
        if CountNumber == 0
            CountNumber = RangeNumber;

            # create a dimension helper variable to get the dimension of each variable in the dataset.
            # dimension is the different possible values for the variable

            Dim = zeros(D,CountNumber);
            Dim[t,:] = TempVector;
            elseif CountNumber >= RangeNumber
                Dim[t,:] = [TempVector zeros(1,CountNumber - RangeNumber)];
            elseif CountNumber < RangeNumber
                Dim = [Dim zeros(D,RangeNumber - CountNumber )];
                CountNumber = RangeNumber;
                Dim[t,:] = TempVector;

        end
    end
    Dim, DimLength
end





function CreateDataObj(OriginalSample, DataObj_type)

    # create the DataObj to store everything together
    # input is the original sample == Originaldata and also the DataObj type
    # julia does not have object oriented so you have to create a type to hold the variables you need


    varNumber = size(OriginalSample,2);
    CaseLength = size(OriginalSample,1);

    varSample = OriginalSample;

    VarRange, VarRangeLength = DimensionRangeValue(OriginalSample,1:varNumber);

    DataObj = DataObj_type(varNumber, CaseLength, varSample, VarRange, VarRangeLength);

    DataObj
end






function GFunction( DataObj, X, PAX )
    # calulates the g-function for a given node and the parents of the node
    # this is the main metric for the K2 score performance

    #Input: X is the given variable, and PAX is the parents of X
    #Output: value of the g-function


    # here we have to create a global variable
    # global variable works different than local because now we want to define it before a loop
    # then use/ update in a loop, then use it in more loops.

    global UsedSample

    # intial value
    GFunValue = 0;
    LG = DataObj;

    # CaseLength is the number of observations for a given variable
    N  = LG.CaseLength;
    UsedSample = DiscardNoneExist(LG.VarSample,[X PAX]);

    DimX =  Int(LG.VarRangeLength[X]);
    RangeX = LG.VarRange[X,:]';

    # number of instantiations of child node
    ri = DimX;
    OriginalData = LG.VarSample;

    # The location of the first unprocessed sample, it accelerates the
    # searching.

    d = 1 ;


    while  d <= N
        Frequency = zeros(1,Integer(DimX));
        while d <= N && UsedSample[d] == 1
            d = d + 1;
        end
        if d > N
            break
        end

        # have to create another global variable to use in and out of the loop
        global t1
        for new_t1 = 1:Int(DimX)
            t1 = new_t1
            if RangeX[new_t1] == OriginalData[d,X]
                break
            end
        end
        Frequency[t1]  =  1;
        UsedSample[d]=1;
        ParentValue = OriginalData[d, PAX];
        d = d + 1;
        if d > N
          break
        end

      # test whether the class value in Sample[t] is the same as ClassValue or not.
        for k = d : N
            if UsedSample[k]==0
                if ParentValue == OriginalData[k, PAX]
                    t1 = 1;
                    while RangeX[t1] != OriginalData[k,X]
                        t1 = t1 + 1;
                    end
                    Frequency[t1] = Frequency[t1] + 1;
                    UsedSample[k] = 1;

                end
            end
        end

        # calculates the G-function score using the logarithmic gamma function. Used as a criterion for
        # determining if the new parent or parents improve the score or not. That is what frequency is doing is
        # finding the impact of the different parents for a node.
        Sum = sum(Frequency);
        for k = 1:Integer(ri)
            if Frequency[k]!= 0
                GFunValue = GFunValue + logabsgamma(Frequency[k]+1)[1]; # Nijk is equal to Frequency[k]
            end
        end
        GFunValue = GFunValue + logabsgamma(ri)[1] - logabsgamma(Sum + ri)[1];
    end

    #GFunValue
    GFunValue
end





function DiscardNoneExist( OriginalData,TestVector )
    # This function return a matrix indicating the useful rows in OriginalData.
    # Input:  Original Data is the matrix containing all the rows and columns for the dataset
    #         TestVector is the set of variables in Original Data.
    # Output: Discard is a tag matrix showing which rows in OriginalData are used

    # number of observations
    N = size(OriginalData,1);
    Discard = zeros(1,N);
    TotalNumber = 0;

    for p=1:N
        d = 1;

        # for q = each variable
        for q = 1:size(TestVector,2)

            # if not a useful observation
            if OriginalData[p,TestVector[q]] == -1   # Here we assume U =-1
                d = 0;
                break;
            end
        end
        if d==0

            # get rid of it
            Discard[p] = 1;
            TotalNumber = TotalNumber + 1;
        end
    end
    [Discard TotalNumber]
end



function findOptimalGraph(DataObj,trials,data)
    # finds the optimal graph structure for a certain amount of trials
    # this function implements the random restarting as well as the incremental window methof
    # for the max number of parents

    # define the global variable that will be used throughout the function
    global masterDAG, masterGraph, masterNames, masterBayesScore,largest_so_far

    # copy over our trial function to prevent any global variable definitions
    trials = trials

    # create a variable to keep track of our best structure. Initialize to a arbitrary small number
    largest_so_far = -50000
    for i = 1:trials

        # this is the incremental method. We can see the conditional statements for the number of trials
        # that the K2 algorithm is on.

        if i < Integer(trials/4)
            u = 2;
        end

        if i >= Integer(trials/4) && i < Integer(2*trials/4)
            u = 3;
        end

        if i >= Integer(2*trials/4) && i < Integer(3*trials/4)
            u = 4;
        end

        if i >= Integer(3*trials/4) && i <= trials
            u = 5;
        end


        # topological sort definition. Initialoze the topological sort randomly for every trial
        # this is the random restarting method
        # it looks like a nasty line of code but is just shuffling a vector from
        # 1 -> # of variables and then reformatting it into this shape: [1, 5, 3, 7, ...]
        Order = reshape(shuffle(1:DataObj.VarNumber),1,length(shuffle(1:DataObj.VarNumber)));

        # retrieve our graph structure and our K2 score metric
        # currently DAG is a matrix corresponding to graph structure so we convert it to a graph structure
        # to calculate the bayesian score
        DAG,K2Score = k2(DataObj,Order,u);

        graph = CreateGraph(DAG);

        # gets the variable names
        Names = getNames(data);

        # calculates the bayesian score
        bayesScore = BayesScore(graph,Names,data);
        if bayesScore > largest_so_far

            # store the best configuration we have seen so far
            masterDAG = DAG;
            masterGraph = graph;
            masterNames = Names;
            masterBayesScore = bayesScore;
            largest_so_far = bayesScore;

        end
    end

    # return the best configuration we say during the trials
    return masterDAG, masterGraph, masterNames, masterBayesScore
end



function CreateGraph(DAG)

    # creates the graph structure for calculating the bayes score and plotting

    # initialize an empty Directed Acyclic graph structure
    graph = BayesNets.DAG(length(DAG[:,1]));

    # loop through our DAG matric and add edges from each parent to the child
    for i = 1:length(DAG[:,1])
        for j = 1:length(DAG[:,1])
            if DAG[j,i] == 1
                child = i
                parent = j
                add_edge!(graph,parent,child)
            else
                continue
            end
        end
    end
    graph
end


function BayesScore(graph, names, data)
    # calulates the bayesian score for the graph Bayesian network structure
    bayesScore = BayesNets.bayesian_score(graph,names,data);

    bayesScore
end



function getNames(data)

    #gets all the names of the variables and refomats them as an python-like array
    newNames = reshape(names(data),size(data,2));

    newNames
end



function convertNames2string(Names)

    # converts the names from type: Symbol to type: String for plotting
    newNames = Array{String,1}()
    for i = 1:length(Names)
        push!(newNames,string(Names[i]))
    end
    newNames
end


function output(BayesNet, filename, Names)

    # output function to write out the bayesnet structure to the appropriate file
    f = open(filename, "w")

    for edge in LightGraphs.edges(BayesNet)
    @printf(f,"%s,%s\n",Names[LightGraphs.src(edge)], Names[LightGraphs.dst(edge)])
    end

    close(f)

end



function main(inputFile, trials=100, returnVar = false)

    # main function to wrap everything together and simplify code execution
    # 100 trials is the minimum number that can be executed

    s = inputFile

    if s[end-4] == 'e'

        NameOfData = "whitewine";

    end

    if s[end-4] == 'c'

        NameOfData = "titanic";
    end


    if s[end-4] == 's'

        NameOfData = "schoolgrades";

    end


    data = CSV.read(inputFile);
    matrix = Matrix(data);
    DataObj = CreateDataObj(matrix, DataObj_type);

    # tic and toc is a timer for seeing how long the code takes to run

    #tic()

    DAG, graph, Names, BS = findOptimalGraph(DataObj,trials,data);

    #toc()


    output(graph,NameOfData*".gph",Names)

    if returnVar == true

        return DAG, graph, Names, BS

    end

end
