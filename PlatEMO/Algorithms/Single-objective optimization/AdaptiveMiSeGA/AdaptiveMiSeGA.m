classdef AdaptiveMiSeGA < ALGORITHM
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
                quarterSizes = round(algoPercentages * N);
                while sum(quarterSizes) > N
                    [~, idx] = max(quarterSizes);
                    quarterSizes(idx) = quarterSizes(idx) - 1;
                end
                while sum(quarterSizes) < N
                    [~, idx] = min(quarterSizes);
                    quarterSizes(idx) = quarterSizes(idx) + 1;
                end
                startIdx = cumsum([1, quarterSizes(1:end-1)]);
                subPopulations = cell(1, 4);
                subIndices = cell(1, 4);
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
                for i = 1:floor(N/2)
                    parent1Idx = MatingPool(i);
                    parent2Idx = MatingPool(i + floor(N/2));
                    parentSelectionInfo(i, 2) = parentSelectionInfo(i + floor(N/2), 1);
                    parentSelectionInfo(i + floor(N/2), 2) = parentSelectionInfo(i, 1);
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
                decayFactor = 0.7;
                algoContributions = decayFactor * algoContributions + newContributions;
                if sum(algoContributions) > 0
                    newPercentages = algoContributions / sum(algoContributions);
                    minPercentage = 0.05;
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
                
                if mod(Generation, 10) == 0
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