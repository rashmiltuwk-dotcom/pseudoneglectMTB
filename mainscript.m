clear all

Screen('Preference', 'SkipSyncTests', 1); 
PsychDefaultSetup(2);
screenNumber = max(Screen('Screens')); 
 
% =========================================================================
% DEFINE THE MASTER STORAGE FILE
% =========================================================================
masterDataFile = 'CallFile.mat'; 

% Define the 3 counterbalanced order sequences
orderPool = { ...
    {'left', 'center', 'right'}, ... % Order 1
    {'right', 'left', 'center'}, ... % Order 2
    {'right', 'left', 'center'}  ... % Order 3
};

% Determine the current participant number based on existing data
if exist(masterDataFile, 'file')
    fileInfo = whos('-file', masterDataFile);
    if any(strcmp({fileInfo.name}, 'allResults'))
        load(masterDataFile, 'allResults');
        
        % Divide total rows by 3 to get the count of completed participants
        completedParticipants = height(allResults) / 3; 
        currentParticipantNum = completedParticipants + 1;
    else
        currentParticipantNum = 1;
    end
else
    currentParticipantNum = 1;
end

% Assign the counterbalanced order sequence using modulo math
orderIndex = mod(currentParticipantNum - 1, 3) + 1;
positions = orderPool{orderIndex};

% Display the assigned sequence in the Command Window for verification
fprintf('\n=== Setup ===\n');
fprintf('Participant Number: %d\n', currentParticipantNum);
fprintf('Assigned Order Index: %d\n', orderIndex);
fprintf('Trial Sequence: %s -> %s -> %s\n\n', positions{:});

% =========================================================================
% OPEN WINDOW & RUN EXPERIMENT
% =========================================================================
[window, rect] = PsychImaging('OpenWindow', screenNumber, [0 0 0]);
ShowCursor('Arrow', window); 
 
try
    numTrials = length(positions);
    
    % Loop through each of the three position trials
    for t = 1:numTrials
        
        currentPos = positions{t};
        fprintf('\n--- Running Trial %d: Position = %s ---\n', t, currentPos);
        
        % Run the pseudoneglect function
        [RatingOnset, RatingOffset, RatingDuration, Rating] = pseudoneglect(...
            window, rect, screenNumber, ...
            'type', 'line', ...
            'position', currentPos); 
            
        % Prepare the data row (Tracking Particpant ID and Order Index as well)
        newResult = table(currentParticipantNum, orderIndex, t, {currentPos}, Rating, RatingDuration, RatingOnset, RatingOffset, ...
            'VariableNames', {'ParticipantID', 'OrderIndex', 'Trial', 'Position', 'Rating', 'RatingDuration', 'RatingOnset', 'RatingOffset'});
     
        % Append data to the master file
        if exist(masterDataFile, 'file')
            load(masterDataFile, 'allResults');
            allResults = [allResults; newResult]; 
        else
            allResults = newResult;
        end
     
        % Save immediately per trial
        save(masterDataFile, 'allResults');
        
        % Short pause between trials
        WaitSecs(0.5); 
    end
    
    HideCursor(window); 
    sca; 
    fprintf('\n=== Run Successful ===\n');
 
catch ME
    sca; 
    rethrow(ME);
end
