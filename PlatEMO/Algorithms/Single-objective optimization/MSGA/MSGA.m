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
        function main(Algorithm,Problem, pair) %pair will be like two different values 1-4/6, like [1, 3]. function nums
            %% Parameter setting
            [proC,disC,proM,disM] = Algorithm.ParameterSet(1,20,1,20);
            selectionMap = containers.Map(...
                {1, 2, 3, 4}, ...
                {@TournamentSelection, @RouletteWheelSelection, @StochasticUniversalSampling, @RankSelection});
            %% Generate random population
            Population = Problem.Initialization();
            Generation = 0;
            %% Optimization
            while Algorithm.NotTerminated(Population)
                Generation = Generation + 1;
                fitness = FitnessSingle(Population);
                halfN = floor(Problem.N / 2);
                selFunc1 = selectionMap(pair(1));
                selFunc2 = selectionMap(pair(2));
                MatingPool_T = selFunc1(2, halfN, fitness);
                MatingPool_R = selFunc2(Problem.N - halfN, fitness);
                MatingPool = zeros(1, Problem.N);
                MatingPool(1:2:end) = MatingPool_T;
                MatingPool(2:2:end) = MatingPool_R;
                Offspring  = OperatorGA(Problem,Population(MatingPool),{proC,disC,proM,disM});
                Population = [Population,Offspring];
                [~,rank]   = sort(FitnessSingle(Population));
                Population = Population(rank(1:Problem.N));
                % DisplayTopFitnesses(Population, Generation);
            end
        end

        function index = StochasticUniversalSampling(N, Fitness)
            %StochasticUniversalSampling - Stochastic Universal Sampling selection.
            %
            %   index = StochasticUniversalSampling(N, Fitness) returns the indices of
            %   N solutions by Stochastic Universal Sampling (SUS) based on fitness.
            %   Smaller fitness values indicate a higher possibility of selection.
            
            Fitness = reshape(Fitness, 1, []);
            
            Fitness = Fitness - min(min(Fitness), 0) + 1e-6;
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
    end
end