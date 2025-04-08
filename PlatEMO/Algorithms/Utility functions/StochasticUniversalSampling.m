function index = StochasticUniversalSampling(N, Fitness)

            disp("Test");
            %StochasticUniversalSampling - Stochastic Universal Sampling selection.
            %
            %   index = StochasticUniversalSampling(N, Fitness) returns the indices of
            %   N solutions by Stochastic Universal Sampling (SUS) based on fitness.
            %   Smaller fitness values indicate a higher possibility of selection.
            
            Fitness = reshape(Fitness, [], 1);
            
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