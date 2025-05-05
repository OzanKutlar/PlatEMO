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
                {@StochasticUniversalSampling, @RankSelection, @TruncationSelection, @TournamentSelection});
            algoNames = {'SUS', 'Rank', 'Truncation', 'Tournament'};
            algoPercentages = initialAlgoPercentages;
            algoContributions = zeros(1, 4);
            %% Generate random population
            Population = Problem.Initialization();
            Generation = 0;
            global finalData
            finalData.AlgoPercentages = cell(1,1);
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
                        if(algo == 4)
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
                
                % FIXED SECTION: Completely random parent pairing across all algorithms
                % Randomly shuffle the parent indices to create random pairs
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
                
                % Create a mating pairs array to keep track of which individuals are mated
                matingPairs = zeros(N, 2);
                pairCount = 1;
                for i = 1:2:N-1
                    if i+1 <= N  % Ensure we have a pair
                        matingPairs(pairCount, :) = [shuffledParentIndices(i), shuffledParentIndices(i+1)];
                        pairCount = pairCount + 1;
                    end
                end
                
                % Generate offspring using the mating pool
                Offspring = OperatorGA(Problem, Population(MatingPool), {proC, disC, proM, disM});
                
                % Store parent information for each offspring
                % Each pair of parents produces two offspring
                for i = 1:length(Offspring)
                    pairIndex = ceil(i/2);  % Each pair produces 2 offspring
                    if pairIndex <= size(matingPairs, 1)
                        parent1Idx = matingPairs(pairIndex, 1);
                        parent2Idx = matingPairs(pairIndex, 2);
                        % Store the algorithms that selected these parents
                        parentSelectionTracker.(['offspring_', num2str(i)]) = [
                            parentSelectionInfo(parent1Idx, 1), 
                            parentSelectionInfo(parent2Idx, 1)
                        ];
                    else
                        % Handle odd number case or any boundary cases
                        parentSelectionTracker.(['offspring_', num2str(i)]) = [
                            parentSelectionInfo(1, 1),  % Default to first parent's algorithm 
                            parentSelectionInfo(2, 1)   % Default to second parent's algorithm
                        ];
                    end
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
                % Debugging output to track contributions
                if mod(Generation, 10) == 0
                    fprintf('Generation %d - Raw Contributions:\n', Generation);
                    for i = 1:length(algoNames)
                        fprintf('  %s: %.4f\n', algoNames{i}, newContributions(i));
                    end
                end
                
                % Apply smoothing to prevent sudden dramatic changes in algorithm percentages
                % Either exponential moving average or weighted sum with previous contributions
                if Generation == 1
                    algoContributions = newContributions;
                else
                    % Apply smoothing with alpha=0.3 (70% previous, 30% new)
                    alpha = 0.3;
                    algoContributions = (1-alpha) * algoContributions + alpha * newContributions;
                end
                
                if sum(algoContributions) > 0
                    newPercentages = algoContributions / sum(algoContributions);
                    
                    % Ensure minimum representation for each algorithm
                    minPercentage = 0.1; % Increased from 0.01 to ensure meaningful participation
                    
                    % Ensure no algorithm gets below minPercentage
                    for i = 1:length(newPercentages)
                        if newPercentages(i) < minPercentage
                            deficit = minPercentage - newPercentages(i);
                            newPercentages(i) = minPercentage;
                            
                            % Calculate total of other percentages to distribute deficit proportionally
                            otherIndices = setdiff(1:length(newPercentages), i);
                            othersSum = sum(newPercentages(otherIndices));
                            
                            if othersSum > 0
                                for j = otherIndices
                                    newPercentages(j) = newPercentages(j) - deficit * (newPercentages(j) / othersSum);
                                end
                            end
                        end
                    end
                    
                    % Normalize to ensure sum is exactly 1.0
                    algoPercentages = newPercentages / sum(newPercentages);
                    
                    % Debugging to verify normalization
                    if abs(sum(algoPercentages) - 1.0) > 1e-10
                        fprintf('Warning: Algorithm percentages sum to %f instead of 1.0\n', sum(algoPercentages));
                    end
                end
                
                if mod(Generation, 10) == 0
                    fprintf('Generation %d - Selection Method Percentages:\n', Generation);
                    for i = 1:length(algoNames)
                        fprintf('  %s: %.2f%%\n', algoNames{i}, algoPercentages(i)*100);
                    end
                end
                
                finalData.Pop = Population;
                finalData.AlgoPercentages{Generation} = algoPercentages;
                finalData.AlgoContributions = algoContributions;
            end
        end
    end
end