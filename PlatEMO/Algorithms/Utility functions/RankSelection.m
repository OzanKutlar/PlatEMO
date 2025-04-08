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