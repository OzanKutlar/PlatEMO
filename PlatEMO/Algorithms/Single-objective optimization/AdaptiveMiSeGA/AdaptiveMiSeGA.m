classdef AdaptiveMiSeGA < ALGORITHM
% <1992> <single> <real/integer/label/binary/permutation> <large/none> <constrained/none>
% Adaptive Multiple Selection genetic algorithm
% proC ---  1 --- Probability of crossover
% disC --- 20 --- Distribution index of simulated binary crossover
% proM ---  1 --- Expectation of the number of mutated variables
% disM --- 20 --- Distribution index of polynomial mutation


    methods
        function main(Algorithm, Problem)
            %% Parameter setting
            [proC, disC, proM, disM, initialAlgoPercentages] = Algorithm.ParameterSet(1, 20, 1, 20, [0.25, 0.25, 0.25, 0.25]);
            algoIndices = [1, 2, 3, 4];
            % {@TournamentSelection, @StochasticUniversalSampling, @RankSelection, @TruncationSelection}
            selectionMap = containers.Map(...
                {1, 2, 3, 4}, ...
                {@TournamentSelection, @StochasticUniversalSampling, @RankSelection, @TruncationSelection});
            algoNames = {'Tournament', 'SUS', 'Rank', 'Truncation'};
            algoPercentages = initialAlgoPercentages;
            algoContributions = zeros(1, 4);
            %% Generate random population
            Population = Problem.Initialization();
            Generation = 0;
            global finalData
            parentSelectionTracker = struct();
            %% Optimization
            while Algorithm.NotTerminated(Population)
                Generation = Generation + 1;
                prevPopulation = Population;
                fitness = FitnessSingle(Population);
                
                N = Problem.N;
                % >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
                % INSERT START: RANDOM RESHUFFLING + ADAPTIVE SUBPOP ASSIGNMENT
                % 1. Shuffle all individuals randomly
                shuffledIndices = randperm(N);
                
                % 2. Calculate subpopulation sizes from current algoPercentages
                subpopSizes = round(algoPercentages * N);
                subpopSizes(end) = N - sum(subpopSizes(1:end-1)); % Ensure sum = N
                
                % 3. Assign individuals to subpopulations
                subPopulations = cell(1, 4);
                subIndices = cell(1, 4);
                startIdx = 1;
                for i = 1:4
                    endIdx = startIdx + subpopSizes(i) - 1;
                    subIndices{i} = shuffledIndices(startIdx:endIdx);
                    subPopulations{i} = Population(subIndices{i});
                    startIdx = endIdx + 1;
                end
                % INSERT END
                % <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<

                MatingPool = zeros(1, N);
                parentSelectionInfo = zeros(N, 2);
                currIdx = 1;
                for algo = 1:4
                    if ~isempty(subPopulations{algo}) && ~isempty(subIndices{algo})
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
                        parentSelectionInfo(currIdx:(currIdx + numToSelect - 1), :) = repmat([algo, 0], numToSelect, 1);
                        currIdx = currIdx + numToSelect;
                    end
                end
                shuffledParentIndices = randperm(N);
                
                % Create pairs by taking consecutive indices from the shuffled array
                for i = 1:floor(N/2)
                    parent1Idx = shuffledParentIndices(i*2-1);
                    parent2Idx = shuffledParentIndices(i*2);
                    
                    % Record which algorithm the other parent came from
                    parentSelectionInfo(parent1Idx, 2) = parentSelectionInfo(parent2Idx, 1);
                    parentSelectionInfo(parent2Idx, 2) = parentSelectionInfo(parent1Idx, 1);
                end
                
                % Handle the case when N is odd
                if mod(N, 2) == 1
                    lastIdx = N;
                    randomIdx = randi(N-1);
                    parentSelectionInfo(lastIdx, 2) = parentSelectionInfo(randomIdx, 1);
                end
                Offspring = OperatorGA(Problem, Population(MatingPool), {proC, disC, proM, disM});
                for i = 1:length(Offspring)
                    pairIndex = mod(i-1, floor(N/2)) + 1;
                    parentSelectionTracker.(['offspring_', num2str(i)]) = parentSelectionInfo(pairIndex, :);
                end
                combinedPopulation = [Population, Offspring];
                combinedFitness = FitnessSingle(combinedPopulation);
                [sortedFitness, sortIndices] = sort(combinedFitness);
                isMinimization = true;
                if isMinimization
                    Population = combinedPopulation(sortIndices(1:N));
                    survivingOffspringIndices = sortIndices(sortIndices > N & sortIndices <= 2*N) - N;
                else
                    Population = combinedPopulation(sortIndices(end-N+1:end));
                    survivingOffspringIndices = sortIndices(sortIndices > N & sortIndices <= 2*N & ...
                        sortIndices >= (length(sortIndices) - N + 1)) - N;
                end
                newContributions = zeros(1, 4);
                for i = 1:length(survivingOffspringIndices)
                    offspringIdx = survivingOffspringIndices(i);
                    parentMethods = parentSelectionTracker.(['offspring_', num2str(offspringIdx)]);
                    offspringFitness = combinedFitness(N + offspringIdx);
                    if isMinimization
                        contribution = max(0, mean(fitness) - offspringFitness);
                    else
                        contribution = max(0, offspringFitness - mean(fitness));
                    end
                    newContributions(parentMethods(1)) = newContributions(parentMethods(1)) + contribution/2;
                    newContributions(parentMethods(2)) = newContributions(parentMethods(2)) + contribution/2;
                end
                algoContributions = newContributions;
                if sum(algoContributions) > 0
                    newPercentages = algoContributions / sum(algoContributions);
                    minPercentage = 0.01;
                    for i = 1:length(newPercentages)
                        if newPercentages(i) < minPercentage
                            deficit = minPercentage - newPercentages(i);
                            newPercentages(i) = minPercentage;
                            othersSum = sum(newPercentages) - minPercentage;
                            if othersSum > 0
                                otherIndices = setdiff(1:length(newPercentages), i);
                                for j = otherIndices
                                    newPercentages(j) = newPercentages(j) - deficit * (newPercentages(j) / othersSum);
                                end
                            end
                        end
                    end
                    
                    algoPercentages = newPercentages / sum(newPercentages);
                end
                
                if mod(Generation, 1) == 0
                    fprintf('Generation %d - Selection Method Percentages:\n', Generation);
                    for i = 1:length(algoNames)
                        fprintf('  %s: %.2f%%\n', algoNames{i}, algoPercentages(i)*100);
                    end
                end
                
                finalData.Pop = Population;
                finalData.AlgoPercentages = algoPercentages;
                finalData.AlgoContributions = algoContributions;
            end
        end
    end
end