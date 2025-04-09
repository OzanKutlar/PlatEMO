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
            [proC, disC, proM, disM, algoIndices] = Algorithm.ParameterSet(1, 20, 1, 20, randi(4, 1, 4));

            %% {@TournamentSelection, @RouletteWheelSelection, @StochasticUniversalSampling, @RankSelection, @TruncationSelection});
            selectionMap = containers.Map(...
                {1, 2, 3, 4}, ...
                {@TournamentSelection, @StochasticUniversalSampling, @RankSelection, @TruncationSelection});
            
            %% Generate random population
            Population = Problem.Initialization();
            Generation = 0;
            global finalData
            
            %% Optimization
            while Algorithm.NotTerminated(Population)
                Generation = Generation + 1;
                fitness = FitnessSingle(Population);
                
                %divide population into four quarters
                N = Problem.N;
                quarterSize = floor(N / 4);
                quarterSizes = [quarterSize, quarterSize, quarterSize, N - 3*quarterSize];%remainder
                startIdx = cumsum([1, quarterSizes(1:end-1)]);
                
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
                for algo = 1:4
                    if ~isempty(subPopulations{algo})
                        subFitness = fitness(subIndices{algo});
                        numToSelect = length(subIndices{algo});
                        selFunc = selectionMap(algo);
                        if(algo == 1)
                            selectedIndices = selFunc(2, numToSelect, subFitness);
                        else
                            selectedIndices = selFunc(numToSelect, subFitness);
                        end
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
                finalData.Pop = Population;
            end
        end

        

        

        
    end
end