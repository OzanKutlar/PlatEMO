function data = GetFromServer(ip, port, maxDelay)
    url = sprintf('http://%s:%s', ip, port);
    global finalData

    computerName = getenv('COMPUTERNAME');
    % numbers = regexp(computerName, '\d+', 'match');
	options = weboptions('HeaderFields', {'ComputerName', computerName}); % Add the computerName as a header

    minDelay = 1;

    funcHandles = {@CEC2020_F1, @CEC2020_F2, @CEC2020_F3, @CEC2020_F4, @CEC2020_F5, ...
                   @CEC2020_F6, @CEC2020_F7, @CEC2020_F8, @CEC2020_F9, @CEC2020_F10};
    


    
    
    delay = round(minDelay + (maxDelay - minDelay) * rand());
    fprintf('Delaying for %d seconds\n', delay);
    pause(delay);
    
	for i = 1:100
        finalData = {};
		data = webread(url, options);
		if isfield(data, 'message')
			fprintf('Stopping with message : %s\nI ran %d experiments.\n', data.message, i);
            %!start selfDestruct.bat
            
			return
		end
		display(data);
		delay = round(minDelay + (maxDelay - minDelay) * rand());
        fprintf("Finished Experiment. Delaying for %d seconds before asking for another.\n", delay);
        allSolutions = cell(1, data.repeat);  % Preallocate a cell array
        allFitness = cell(1, data.repeat);  % Preallocate a cell array

        for ii = 1:data.repeat
            temp = platemo('algorithm', @MiSeGA, ...
                'problem', funcHandles{data.func}, ...
                'N', 100, ...
                'maxFE', 10000, ...
                'proM', 0.4, ...
                'algoIndices', [data.algo1, data.algo2, data.algo3, data.algo4]);  % Use single quotes for string keys
            allSolutions{ii} = finalData;
            allFitness{ii} = FitnessSingle(finalData.Pop);
        end
        data.algoStack = [data.algo1, data.algo2, data.algo3, data.algo4];
        data = rmfield(data, {'algo1', 'algo2', 'algo3', 'algo4'});
        data.finalPop = allSolutions;
        data.finalFitness = allFitness;

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
    
    fprintf('The for loop ended. This shouldnt happen?\nI ran %d experiments.\n', ii);
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
