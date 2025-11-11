classdef MiSeDE < ALGORITHM
% <2025> <single> <real/integer> <large/none> <constrained/none>
% Multiple Selection Differential Evolution
% CR --- 0.9 --- Crossover constant
% F  --- 0.5 --- Mutation factor
% algoPercentages -- [0.25, 0.25, 0.25, 0.25] -- Percentages for each selection

%------------------------------- Reference --------------------------------
% R. Storn and K. Price. Differential evolution-a simple and efficient
% heuristic for global optimization over continuous spaces. Journal of
% Global Optimization, 1997, 11(4): 341-359.
% (MiSe logic adapted from MiSeGA)
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
            [CR, F, algoPercentages] = Algorithm.ParameterSet(0.9, 0.5, [0.25, 0.25, 0.25, 0.25]);

            %% Selection Algorithm Mapping
            selectionMap = containers.Map(...
                {1, 2, 3, 4}, ...
                {@TournamentSelection, @StochasticUniversalSampling, @RankSelection, @TruncationSelection});
            
            %% Generate random population
            Population = Problem.Initialization();
            global finalData
            %% Optimization
            while Algorithm.NotTerminated(Population)
                fitness = FitnessSingle(Population);
                N = Problem.N;
                
                % The OperatorDE requires two additional populations to create the
                % offspring. We will run the multiple selection logic twice to
                % generate two independent mating pools.
                MatingPool1 = zeros(1, N);
                MatingPool2 = zeros(1, N);
                
                % Generate the first Mating Pool
                quarterSizes = floor(algoPercentages * N);
                quarterSizes(end) = N - sum(quarterSizes(1:end-1)); % Ensure sum is N
                startIdx = cumsum([1, quarterSizes(1:end-1)]);
                
                currIdx = 1;
                for i = 1:length(selectionMap)
                    numToSelect = quarterSizes(i);
                    if numToSelect > 0
                        subIndices = startIdx(i):(startIdx(i) + numToSelect - 1);
                        subFitness = fitness(subIndices);
                        selFunc = selectionMap(i);
                        
                        if(i == 1) % TournamentSelection requires a K parameter
                            selected = selFunc(2, numToSelect, subFitness);
                        else
                            selected = selFunc(numToSelect, subFitness);
                        end
                        
                        globalSelectedIndices = subIndices(selected);
                        MatingPool1(currIdx:(currIdx + numToSelect - 1)) = globalSelectedIndices;
                        currIdx = currIdx + numToSelect;
                    end
                end
                
                % Generate the second Mating Pool (using the same logic)
                currIdx = 1;
                for i = 1:length(selectionMap)
                    numToSelect = quarterSizes(i);
                    if numToSelect > 0
                        subIndices = startIdx(i):(startIdx(i) + numToSelect - 1);
                        subFitness = fitness(subIndices);
                        selFunc = selectionMap(i);
                        
                        if(i == 1) % TournamentSelection requires a K parameter
                            selected = selFunc(2, numToSelect, subFitness);
                        else
                            selected = selFunc(numToSelect, subFitness);
                        end
                        
                        globalSelectedIndices = subIndices(selected);
                        MatingPool2(currIdx:(currIdx + numToSelect - 1)) = globalSelectedIndices;
                        currIdx = currIdx + numToSelect;
                    end
                end

                %% DE Operator and Replacement
                % Use the two generated mating pools for the DE operator
                Offspring = OperatorDE(Problem, Population, Population(MatingPool1), Population(MatingPool2), {CR, F, 0, 0});
                
                % DE's one-to-one replacement strategy
                replace = FitnessSingle(Population) > FitnessSingle(Offspring);
                Population(replace) = Offspring(replace);
                finalData.Pop = Population;
            end
        end
    end
end