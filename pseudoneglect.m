function [RatingOnset, RatingOffset, RatingDuration, Rating] = pseudoneglect(window, rect, screenNumber, varargin)

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Pseudoneglect Continuous Rating Scale Task
% [RatingOnset RatingOffset RatingDuration Rating] = pseudoneglect(window, rect, screenNumber, [varargin])
% from https://github.com/ljchang/CosanlabToolbox/blob/master/Matlab/Psychtoolbox/SupportFunctions/GetRating.m
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Defaults
show_text = 0;

% Parse Inputs
ip = inputParser;
ip.CaseSensitive = false;
ip.addRequired('window', @isnumeric);
ip.addRequired('rect', @isnumeric);
ip.addRequired('screenNumber', @isnumeric);
ip.addParameter('txt', '');
checkType = @(t) any(strcmpi(t, {'line', 'linear', 'log'}));
ip.addParameter('type', 'line', checkType);
ip.addParameter('txtSize', [], @isnumeric);     

% FIXED: Added the missing position parameter definition so inputParser recognizes it
checkPosition = @(p) any(strcmpi(p, {'center', 'left', 'right'}));
ip.addParameter('position', 'center', checkPosition); 

ip.parse(window, rect, screenNumber, varargin{:});

window       = ip.Results.window;
rect         = ip.Results.rect;
screenNumber = ip.Results.screenNumber;
img_type     = ip.Results.type;
trialPos     = ip.Results.position; 

if ~isempty(ip.Results.txt)
    show_text = 1;
    txt = ip.Results.txt;
end
if ~isempty(ip.Results.txtSize)
    txtSize = ip.Results.txtSize;
else
    txtSize = 32;
end

% Image mapping logic
switch lower(img_type)
    case 'log'
    otherwise
        img_name = 'line_scale.jpg';
end

img_file = which(img_name);
if isempty(img_file)
    error('pseudoneglect:ImageNotFound', ...
          ['Could not find "%s".\n' ...
           'Make sure this image file is saved in your current MATLAB folder.'], img_name);
end

% Configure screen geometries
disp.screenWidth = rect(3);
disp.screenHeight = rect(4);

% Shift horizontally across the X-axis using screenWidth multipliers
switch lower(trialPos)
    case 'left'
        disp.xcenter = disp.screenWidth * 0.35;    % Left side (35% across width)
    case 'right'
        disp.xcenter = disp.screenWidth * 0.65;    % Right side (55% across width)
    otherwise
        disp.xcenter = disp.screenWidth * 0.50;       % Dead center (50% across width)
end

% ycenter remains perfectly locked to the vertical middle of the screen
disp.ycenter = disp.screenHeight / 2; 

disp.scale.width = 964;
disp.scale.height = 252;
disp.scale.w = Screen('OpenOffscreenWindow', screenNumber);

disp.scale.imagefile = img_file;
image = imread(disp.scale.imagefile);
disp.scale.texture = Screen('MakeTexture', window, image);

% Shifting coordinates dynamically wrap around the dynamic xcenter and fixed ycenter
disp.scale.rect = [[disp.xcenter disp.ycenter]-[0.5*disp.scale.width 0.5*disp.scale.height] [disp.xcenter disp.ycenter]+[0.5*disp.scale.width 0.5*disp.scale.height]];
Screen('DrawTexture', disp.scale.w, disp.scale.texture, [], disp.scale.rect);

% Scale and cursor boundaries
cursor.xmin = disp.scale.rect(1) + 123;
cursor.width = 709;
cursor.xmax = cursor.xmin + cursor.width;
cursor.size = 8;
cursor.center = cursor.xmin + ceil(cursor.width/2);
cursor.y = disp.scale.rect(4) - 41;
cursor.x = cursor.center;

RatingOnset = GetSecs;
getRating = 1;

while getRating
    [x, y, buttons] = GetMouse(window);
    if buttons(1)
        getRating = 0;
        RatingOffset = GetSecs;
        break;
    end
    cursor.x = x;
    
    if cursor.x > cursor.xmax
        cursor.x = cursor.xmax;
    elseif cursor.x < cursor.xmin
        cursor.x = cursor.xmin;
    end
    
    % Draw frame updates dynamically
    Screen('FillRect', window, [0 0 0]); 
    Screen('DrawTexture', window, disp.scale.texture, [], disp.scale.rect);
    
    if show_text
        Screen('TextSize', window, txtSize);
        DrawFormattedText(window, txt, 'center', disp.scale.height, 255);
    end

    Screen('Flip', window);
end

RatingDuration = RatingOffset - RatingOnset;
Rating = (cursor.x - cursor.xmin) / (cursor.xmax - cursor.xmin);
WaitSecs(0.25);

end
