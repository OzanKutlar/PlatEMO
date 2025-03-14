function Offspring = OperatorBBBC(Problem, Population, Parameter)
    % Check input parameters
    if nargin > 2
        [exp, Generation] = deal(Parameter{:});
    else
        [exp, Generation] = deal(1, 1);
    end
    % Process the input population
    if isa(Population(1), 'SOLUTION')
        evaluated = true;
        % Extract decision variables from each SOLUTION object (each row is one solution)
        Decs = cat(1, Population.decs);
        % Extract fitness values from each solution
        fitness = cat(1, Population.objs);
    else
        evaluated = false;
        Decs = Population;
        % Evaluate fitness if not already wrapped in SOLUTION objects
        fitness = Problem.Evaluation(Decs);
        if ~isempty(fitness)
            fitness = fitness(:,1); % Use first objective if multi-objective
        end
    end
    
    % Compute weights for center of mass based on fitness.
    % For minimization problems, lower fitness should get a higher weight.
    epsilon = 1e-6;
    minFitness = min(fitness);
    weights = 1 ./ (fitness - minFitness + epsilon);
    
    % Compute the weighted center of mass (each decision variable is averaged)
    centerOfMass = sum(Decs .* weights, 1) / sum(weights);
    
    % Generate offspring using the Big Bang-Big Crunch algorithm
    Offspring = bigBang_norm(Problem, centerOfMass, Problem.N, exp, Generation);
    
    % Evaluate offspring if needed
    if evaluated
        Offspring = Problem.Evaluation(Offspring);
    end
end

function [pop] = bigBang_norm(Problem, centerOfMass, n, exp, g)
    % Big Bang phase: generate n new solutions around the center of mass.
    
    % Problem dimensions
    D = size(centerOfMass, 2);
    
    % Preallocate population
    pop = zeros(n, D);
    
    % Get problem bounds
    lower = Problem.lower;
    upper = Problem.upper;
    range = upper - lower;
    
    % Alpha parameter controls the search radius
    % Modified to use exp as a separate parameter from g
    alpha = exp / sqrt(1 + g);
    
    % Generate new individuals around the center of mass
    for i = 1:n
        % Generate a random vector with normally distributed values
        randVector = randn(1, D);
        
        % Scale the random vector by the problem range and generation number
        scaling = alpha * range .* (1 + rand(1, D)/2);
        
        % Create new individual
        pop(i, :) = centerOfMass + scaling .* randVector;
        
        % Ensure the new solution respects the bounds
        pop(i, :) = max(min(pop(i, :), upper), lower);
        
        % Occasionally sample completely randomly for added diversity
        if rand < 0.1
            pop(i, :) = lower + rand(1, D) .* range;
        end
    end
    
    % Ensure a small percentage of solutions are generated completely at random
    numRandom = max(1, floor(0.05 * n));
    randomIndices = randperm(n, numRandom);
    pop(randomIndices, :) = repmat(lower, numRandom, 1) + rand(numRandom, D) .* repmat(range, numRandom, 1);
end