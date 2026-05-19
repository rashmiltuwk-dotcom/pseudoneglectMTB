
Screen('Preference', 'SkipSyncTests', 1); 

PsychDefaultSetup(2);
screenNumber = max(Screen('Screens')); 


[window, rect] = PsychImaging('OpenWindow', screenNumber, [0.5 0.5 0.5]);



ShowCursor('Arrow', window); 

try
    [RatingOnset, RatingOffset, RatingDuration, Rating] = pseudoneglect(...
        window, rect, screenNumber, ...
        'txt', 'Please rate your line bisection judgment:', ...
        'type', 'line');
        
    HideCursor(window); 
    
    sca; 
    
    % Print your results to the Command Window now that the screen is closed
    fprintf('\n=== Run Successful ===\n');
    fprintf('Final Rating: %.2f%%\n', Rating * 100);
    fprintf('Response Time: %.3f seconds\n', RatingDuration);

catch ME
    % This catches internal crashes and prevents a hard freeze
    sca; 
    rethrow(ME);
end
