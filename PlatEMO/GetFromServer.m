function data = GetFromServer(ip, port, maxDelay)
    url = sprintf('http://%s:%s', ip, port);
    global finalData

    if ~isfolder('experiments')
        mkdir('experiments');
    end

    addpath(genpath(pwd));
    

    computerName = getenv('COMPUTERNAME');
    % numbers = regexp(computerName, '\d+', 'match');
	options = weboptions('HeaderFields', {'ComputerName', computerName}); % Add the computerName as a header

    minDelay = 1;

    
    
    delay = round(minDelay + (maxDelay - minDelay) * rand());
    fprintf('Delaying for %d seconds\n', delay);
    pause(delay);
    
	for i = 1:1000
        finalData = {};
		data = webread(url, options);
		if isfield(data, 'message')
			fprintf('Stopping with message : %s\nI ran %d experiments.\n', data.message, i);
            % !start selfDestruct.bat
            
			return
        end
        funcHandle = eval(strcat("@CEC", data.year, "_F", num2str(data.func)));
        funcInfo = eval(strcat("CEC", data.year, "_F", num2str(data.func)));
		display(data);
		delay = round(minDelay + (maxDelay - minDelay) * rand());
        fprintf("Finished Experiment. Delaying for %d seconds before asking for another.\n", delay);
        allSolutions = cell(1, data.repeat);  % Preallocate a cell array
        allFitness = cell(1, data.repeat);  % Preallocate a cell array
        algoVector = [data.tournamentPer, data.stocPer, data.rankPer, data.truncPer];
        algoVector = algoVector ./ norm(algoVector);
		
        for ii = 1:data.repeat
            temp = platemo('algorithm', @MiSeGA, ...
                'problem', funcHandle, ...
                'N', 100, ...
                'maxFE', 10000, ...
                'D', data.D, ...
                'proM', 0.4, ...
                'algoPercentages', algoVector);
            allSolutions{ii} = finalData;
            allFitness{ii} = FitnessSingle(finalData.Pop);
        end
        data.selectionMethods = algoVector;
        data = rmfield(data, {'tournamentPer', 'stocPer', 'rankPer', 'truncPer'});
        data.finalPop = allSolutions;
        data.finalFitness = allFitness;
        data.funcInfo = funcInfo;

        nameOfFile = strcat("exp-testing", string(data.id));
		nameOfFile = strcat('experiments/', nameOfFile, '.mat');


        save(nameOfFile, "data");

		uploadFileToServerAsJSON(nameOfFile, url, computerName, data.id)
		options = weboptions(...
			'HeaderFields', {...
				'ComputerName', computerName; ...
				'ID', num2str(data.id) ...
			}...
		);
		pause(delay);
    end
    
    fprintf('The for loop ended. This shouldnt happen?\nI ran %d experiments.\n', i);
    % !taskkill /F /im "matlab.exe"
    return
    
end

function fileName = runExperiment(data)
    disp("Test");
    pause(1);
    fileName = "check.sh";
end

function uploadFileToServerAsJSON(fileName, serverUrl, computerName, dataId)
    % Check if the file exists
    filePath = fullfile(pwd, fileName);
    if ~isfile(filePath)
        error('File "%s" does not exist at the specified path.', fileName);
    end

    % Read the binary content of the file
    try
        fid = fopen(filePath, 'rb'); % Open the file in binary mode
        fileData = fread(fid, '*uint8'); % Read as uint8 binary data
        fclose(fid); % Close the file
    catch ME
        if exist('fid', 'var') && fid > 0
            fclose(fid); % Ensure file is closed on error
        end
        error('Error reading the file: %s', ME.message);
    end

    % Encode binary data in Base64
    base64FileData = matlab.net.base64encode(fileData);

    % Prepare JSON data
    jsonData = struct();
    jsonData.file_name = sprintf('exp-%d.mat', dataId);
    jsonData.file = base64FileData;

    % Convert the structure to a JSON string
    jsonString = jsonencode(jsonData);

    % Set up the headers
    options = weboptions(...
        'MediaType', 'application/json', ...
        'HeaderFields', {...
            'Content-Type', 'application/json'; ...
            'ComputerName', computerName; ...
            'ID', num2str(dataId) ...
        }...
    );

    % Send the POST request
    try
        response = webwrite(serverUrl, jsonString, options);
        % Display the server response
        disp('Server Response:');
        disp(response);
    catch ME
        error('Error during POST request: %s', ME.message);
    end
end
