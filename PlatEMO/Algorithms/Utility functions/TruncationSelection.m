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