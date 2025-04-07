classdef MSGA < ALGORITHM
% <1992> <single> <real/integer/label/binary/permutation> <large/none> <constrained/none>
% Multiple Selection genetic algorithm
% proC ---  1 --- Probability of crossover
% disC --- 20 --- Distribution index of simulated binary crossover
% proM ---  1 --- Expectation of the number of mutated variables
% disM --- 20 --- Distribution index of polynomial mutation

%------------------------------- Reference --------------------------------
% J. H. Holland. Adaptation in Natural and Artificial Systems. MIT Press,
% 1992.
%------------------------------- Copyright --------------------------------
% Copyright (c) 2025 BIMK Group. You are free to use the PlatEMO for
% research purposes. All publications which use this platform or any code
% in the platform should acknowledge the use of "PlatEMO" and reference "Ye
% Tian, Ran Cheng, Xingyi Zhang, and Yaochu Jin, PlatEMO: A MATLAB platform
% for evolutionary multi-objective optimization [educational forum], IEEE
% Computational Intelligence Magazine, 2017, 12(4): 73-87".
%--------------------------------------------------------------------------

    methods
        function main(Algorithm, Problem)
            %% Parameter setting
            [proC, disC, proM, disM] = Algorithm.ParameterSet(1, 20, 1, 20);
            selectionMap = containers.Map(...
                {1, 2, 3, 4, 5}, ...
                {@TournamentSelection, @RouletteWheelSelection, @StochasticUniversalSampling, @RankSelection, @TruncationSelection});
            
            %% Generate random population
            Population = Problem.Initialization();
            Generation = 0;
            
            %% Optimization
            while Algorithm.NotTerminated(Population)
                Generation = Generation + 1;
                fitness = FitnessSingle(Population);
                
                %divide population into four quarters
                N = Problem.N;
                quarterSize = floor(N / 4);
                quarterSizes = [quarterSize, quarterSize, quarterSize, N - 3*quarterSize];%remainder
                startIdx = cumsum([1, quarterSizes(1:end-1)]);
                algoIndices = randi(5, 1, 4);
                
                %subpopulation array for all selection algorithms
                subPopulations = cell(1, 5);
                subIndices = cell(1, 5);
                
                %assigning quarters to their randomly selected algorithms
                for i = 1:4
                    algo = algoIndices(i);
                    quarterIndices = startIdx(i):(startIdx(i) + quarterSizes(i) - 1);
                    if isempty(subPopulations{algo})
                        subPopulations{algo} = Population(quarterIndices);
                        subIndices{algo} = quarterIndices;
                    else
                        subPopulations{algo} = [subPopulations{algo}, Population(quarterIndices)];
                        subIndices{algo} = [subIndices{algo}, quarterIndices];
                    end
                end
                
                %theoretically correct, I do not think I am missing a step.
                MatingPool = zeros(1, N);
                currIdx = 1;
                for algo = 1:5
                    if ~isempty(subPopulations{algo})
                        subFitness = fitness(subIndices{algo});
                        numToSelect = length(subIndices{algo});
                        selFunc = selectionMap(algo);
                        selectedIndices = selFunc(numToSelect, subFitness);
                        globalSelectedIndices = subIndices{algo}(selectedIndices);
                        MatingPool(currIdx:(currIdx + numToSelect - 1)) = globalSelectedIndices;
                        currIdx = currIdx + numToSelect;
                    end
                end
                
                %create offspring using GA operators, merge the parent
                %population and offspring, sort and eliminate
                Offspring = OperatorGA(Problem, Population(MatingPool), {proC, disC, proM, disM});
                Population = [Population, Offspring];
                [~, rank] = sort(FitnessSingle(Population));
                Population = Population(rank(1:N));
            end
        end

        function index = StochasticUniversalSampling(N, Fitness)
            %StochasticUniversalSampling - Stochastic Universal Sampling selection.
            %
            %   index = StochasticUniversalSampling(N, Fitness) returns the indices of
            %   N solutions by Stochastic Universal Sampling (SUS) based on fitness.
            %   Smaller fitness values indicate a higher possibility of selection.
            
            Fitness = reshape(Fitness, 1, []);
            
            Fitness = Fitness - min(min(Fitness), 0);
            Prob = 1 ./ Fitness;
            Prob = Prob / sum(Prob);
            CDF = cumsum(Prob);
            
            startPoint = rand / N;
            pointers = startPoint + (0:N-1) / N;
            
            index = zeros(1, N);
            i = 1;
            for j = 1:N
                while pointers(j) > CDF(i)
                    i = i + 1;
                end
                index(j) = i;
            end
        end

        function index = RankSelection(N, Fitness)
            %RankSelection - Rank-based selection.
            %
            %   index = RankSelection(N, Fitness) returns the indices of N solutions
            %   selected by rank-based selection. A smaller fitness value indicates a
            %   better rank and higher possibility of being selected.
            
            Fitness = reshape(Fitness, [], 1);
            
            %assigning ranks: best = 1, worst = length(Fitness)
            [~, sortedIdx] = sort(Fitness);
            ranks = zeros(size(Fitness));
            ranks(sortedIdx) = 1:length(Fitness);
            
            %we convert ranks to selection probabilities (inverting rank, lower the more)
            %we do linear ranking here, there is also exponential ranking methods (Deb K., Multi-Objective Optimization using Evolutionary Algorithms)
            selectionProb = (length(Fitness) - ranks + 1);
            selectionProb = selectionProb / sum(selectionProb);
            CDF = cumsum(selectionProb);
            
            %we select N individuals based on rank probabilities
            randNums = rand(1, N);
            index = arrayfun(@(r) find(r <= CDF, 1, 'first'), randNums);
        end

        function index = TruncationSelection(N, Fitness)
            %TruncationSelection - Truncation selection.
            %
            %   index = TruncationSelection(N, Fitness) returns the indices of N
            %   individuals selected by truncation selection. Individuals with the best
            %   (smallest) fitness are selected deterministically or randomly if N is
            %   less than the number of top individuals.
        
            Fitness = reshape(Fitness, [], 1);
            %best first
            [~, sortedIdx] = sort(Fitness);
            
            %truncation% (e.g., top 60% of individuals can be selected from)
            truncationRate = 0.6;
            numTruncated = max(1, round(length(Fitness) * truncationRate));
            topIndices = sortedIdx(1:numTruncated);
            
            %randomly select N individuals from the top pop
            index = topIndices(randi(numTruncated, 1, N));
        end
    end
end