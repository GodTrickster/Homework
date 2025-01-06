%Homework
Screen('Preference', 'SkipSyncTests', 1);
% Screen Setup
myScreen = 0;
[myWindow, rect] = Screen('OpenWindow', myScreen, [128 128 128]);
Screen('TextSize', myWindow, 32);

% Load Images
famousFaces = {'famous1.jpg', 'famous2.jpg', 'famous3.jpg', 'famous4.jpg', 'famous5.jpg', 'famous6.jpg'}; % image paths
nonFamousFaces = {'nonfamous1.jpg', 'nonfamous2.jpg', 'nonfamous3.jpg', 'nonfamous4.jpg', 'nonfamous5.jpg', 'nonfamous6.jpg'}; % image paths

% Create Textures
textures = [];
for i = 1:length(famousFaces)
    img = imread(famousFaces{i});
    textures.famous{i} = Screen('MakeTexture', myWindow, img);
end
for i = 1:length(nonFamousFaces)
    img = imread(nonFamousFaces{i});
    textures.nonFamous{i} = Screen('MakeTexture', myWindow, img);
end

% Parameters
nTrials = 50;
fixationDuration = 1; % 1 second
maskDuration = 0.5; % 500 ms
faceDuration = 0.1; % 100 ms
responseTimes = zeros(1, nTrials);

% Main Experiment Loop
for trial = 1:nTrials
    % Fixation Cross
    DrawFormattedText(myWindow, '+', 'center', 'center', [0 0 0]);
    Screen('Flip', myWindow);
    WaitSecs(fixationDuration);

    % Mask
    noisySquare = rand(rect(4), rect(3)) * 255; % Random noise
    maskTexture = Screen('MakeTexture', myWindow, noisySquare);
    Screen('DrawTexture', myWindow, maskTexture);
    Screen('Flip', myWindow);
    WaitSecs(maskDuration);

    % Randomly Select and Show Face
    if rand > 0.5
        faceTexture = textures.famous{randi(length(textures.famous))};
        correctResponse = 'RightArrow'; % Famous faces correspond to right arrow key
    else
        faceTexture = textures.nonFamous{randi(length(textures.nonFamous))};
        correctResponse = 'LeftArrow'; % Non-famous faces correspond to left arrow key
    end
    Screen('DrawTexture', myWindow, faceTexture);
    Screen('Flip', myWindow);
    faceOnset = GetSecs; % Record face onset time
    WaitSecs(faceDuration);

    % Collect Response
    Screen('Flip', myWindow); % Clear screen
    [secs, keyCode] = KbWait([], 2); % Wait for a key press
    responseTimes(trial) = secs - faceOnset;

    % Check if the response was correct
    responseKey = KbName(find(keyCode));
    if strcmp(responseKey, correctResponse)
        disp(['Trial ', num2str(trial), ': Correct']);
    else
        disp(['Trial ', num2str(trial), ': Incorrect']);
    end
end

% Display Average Reaction Time
avgRT = mean(responseTimes);
disp(['Average Reaction Time: ', num2str(avgRT), ' seconds']);

% Close Screen
Screen('CloseAll');
