%disp("hello");
Screen('Preference', 'SkipSyncTests', 1);



LinesDemo;

%%
% Clear the workspace
close all;
clear;
sca;

% Here we call some default settings for setting up Psychtoolbox
PsychDefaultSetup(2);

% Find the screen to use for display
screenid = max(Screen('Screens'));

% Initialise OpenGL
InitializeMatlabOpenGL;

% Open the main window with multi-sampling for anti-aliasing. Multisampling
% is a brute force but effective way in which to avoid aliasing of computer
% generated objects. PTB clamps the requested number of multisamples to the
% maximum allowed by the computer if more are requested. See help AntiAliasing
numMultiSamples = 6;
[window, windowRect] = PsychImaging('OpenWindow', screenid, 0, [],...
    32, 2, [], numMultiSamples,  []);

% Set the priority of PTB to max
topPriorityLevel = MaxPriority(window);
Priority(topPriorityLevel);

% Query the frame duration
ifi = Screen('GetFlipInterval', window);

% Start the OpenGL context (you have to do this before you issue OpenGL
% commands such as we are using here)
Screen('BeginOpenGL', window);

% For this demo we will assume our screen is 30cm in height. The units are
% essentially arbitary with OpenGL as it is all about ratios. But it is
% nice to define things in normal scale numbers. You would obviously want
% to define this properly for your setup.
ar = windowRect(3) / windowRect(4);
screenHeight = 30;
screenWidth = screenHeight * ar;

% Enable lighting
glEnable(GL.LIGHTING);

% Define a local light source
glEnable(GL.LIGHT0);

% Enable proper occlusion handling via depth tests
glEnable(GL.DEPTH_TEST);

% Lets set up a projection matrix, the projection matrix defines how images
% in our 3D simulated scene are projected to the images on our 2D monitor
glMatrixMode(GL.PROJECTION);
glLoadIdentity;

% Calculate the field of view in the y direction assuming a distance to the
% objects of 100cm
dist = 100;
angle = 2 * atand(screenHeight / dist);

% Set up our perspective projection. This is defined by our field of view
% (here given by the variable "angle") and the aspect ratio of our frustum
% (our screen) and two clipping planes. These define the minimum and
% maximum distances allowable here 0.1cm and 200cm.
gluPerspective(angle, ar, 0.1, 200);

% Setup modelview matrix: This defines the position, orientation and
% looking direction of the virtual camera that will be look at our scene.
glMatrixMode(GL.MODELVIEW);
glLoadIdentity;

% Our point lightsource is at position (x,y,z) == (1,2,3)
glLightfv(GL.LIGHT0, GL.POSITION, [1 2 3 0]);

% Location of the camera is at the origin
cam = [0 0 0];

% Set our camera to be looking directly down the Z axis (depth) of our
% coordinate system. Again, all of these numbers are arbitary to some
% extent. Looking down the negative Z axis is just how I learned to
% program.
fix = [0 0 -100];

% Define "up"
up = [0 1 0];

% Here we set up the attributes of our camera using the variables we have
% defined in the last three lines of code
gluLookAt(cam(1), cam(2), cam(3), fix(1), fix(2), fix(3), up(1), up(2), up(3));

% Set background color to 'black' (the 'clear' color)
glClearColor(0, 0, 0, 0);

% Clear out the backbuffer
glClear;

% End the OpenGL context now that we have finished setting things up
Screen('EndOpenGL', window);

% Setup the positions of the spheres using the mexhgrid command
[cubeX, cubeY] = meshgrid(linspace(-25, 25, 10), linspace(-20, 20, 8));
[s1, s2] = size(cubeX);
cubeX = reshape(cubeX, 1, s1 * s2);
cubeY = reshape(cubeY, 1, s1 * s2);
numCubes = length(cubeX);

% Define the intial rotation angles of our cubes
rotaX = rand(1, numCubes) .* 360;
rotaY = rand(1, numCubes) .* 360;
rotaZ = rand(1, numCubes) .* 360;

% Randomise the colours of our cubes
cubeColours = rand(numCubes, 3);

% Now we define how many degrees our cubes will rotated per second and per
% frame. Note we use Degrees here (not Radians)
degPerSec = 180;
degPerFrame = degPerSec * ifi;

% Get a time stamp with a flip
vbl = Screen('Flip', window);

% Set the frames to wait to one
waitframes = 1;

while ~KbCheck

    % Begin the OpenGL context now we want to issue OpenGL commands again
    Screen('BeginOpenGL', window);

    % To start with we clear everything
    glClear;

    % Draw all the cubes sequentially in a loop.
    for i = 1:1:length(cubeX)

        % Push the matrix stack
        glPushMatrix;

        % Translate the cube in xyz
        glTranslatef(cubeX(i), cubeY(i), -dist);

        % Rotate the cube randomly in xyz
        glRotatef(rotaX(i), 1, 0, 0);
        glRotatef(rotaY(i), 0, 1, 0);
        glRotatef(rotaZ(i), 0, 0, 1);

        % Change the light reflection properties of the material to blue. We could
        % force a color to the cubes or do this.
        thisCubeColour = cubeColours(i, :);
        glMaterialfv(GL.FRONT_AND_BACK,GL.AMBIENT,...
            [thisCubeColour(1) thisCubeColour(2), thisCubeColour(3) 1]);
        glMaterialfv(GL.FRONT_AND_BACK,GL.DIFFUSE,...
            [thisCubeColour(1) thisCubeColour(2), thisCubeColour(3) 1]);

        % Draw the solid cube
        glutSolidCube(3);

        % Pop the matrix stack for the next cube
        glPopMatrix;

    end

    % End the OpenGL context now that we have finished doing OpenGL stuff.
    % This hands back control to PTB
    Screen('EndOpenGL', window);

    % Show rendered image at next vertical retrace
    vbl = Screen('Flip', window, vbl + (waitframes - 0.5) * ifi);

    % Rotate the cubes for the next drawing loop
    rotaX = rotaX + degPerFrame;
    rotaY = rotaY + degPerFrame;
    rotaZ = rotaZ + degPerFrame;

end

% Shut the screen down
sca;
%%
% Clear the workspace
close all;
clear;
sca;

% Setup PTB with some default values
PsychDefaultSetup(2);

% Seed the random number generator
rng('shuffle');

% Set the screen number to the external secondary monitor if there is one
% connected
screenNumber = max(Screen('Screens'));

% Define black, white and grey
white = WhiteIndex(screenNumber);
grey = white / 2;
black = BlackIndex(screenNumber);

% Open the screen
[window, windowRect] = PsychImaging('OpenWindow', screenNumber, grey, [], 32, 2,...
    [], [],  kPsychNeed32BPCFloat);

% Flip to clear
Screen('Flip', window);

% Query the frame duration
ifi = Screen('GetFlipInterval', window);

% Set the text size
Screen('TextSize', window, 40);

% Set drawing to maximum priority level
topPriorityLevel = MaxPriority(window);
Priority(topPriorityLevel);

% Get the centre coordinate of the window
[xCenter, yCenter] = RectCenter(windowRect);


%--------------------
% Gabor information
%--------------------

% Dimension of the region where will draw the Gabor in pixels
gaborDimPix = 300;

% Sigma of Gaussian
sigma = gaborDimPix / 7;

% Obvious Parameters
orientation = 90;
contrast = 0.5;
aspectRatio = 1.0;

% Spatial Frequency (Cycles Per Pixel)
% One Cycle = Grey-Black-Grey-White-Grey i.e. One Black and One White Lobe
numCycles = 8;
freq = numCycles / gaborDimPix;

% Build a procedural gabor texture
gabortex = CreateProceduralGabor(window, gaborDimPix, gaborDimPix, [],...
    [0.5 0.5 0.5 0.0], 1, 0.5);

% We will be displaying our Gabors either above or below fixation by 250
% pixels. We therefore have to determine these two locations in screen
% coordianates.
pixShift = 250;
xPos = [xCenter xCenter];
yPos = [yCenter - pixShift yCenter + pixShift];

% Count how many Gabors there are (two for this demo)
nGabors = numel(xPos);

% Make the destination rectangles for  the Gabors in the array i.e.
% rectangles the size of our Gabors cenetred above an below fixation.
baseRect = [0 0 gaborDimPix gaborDimPix];
allRects = nan(4, nGabors);
for i = 1:nGabors
    allRects(:, i) = CenterRectOnPointd(baseRect, xPos(i), yPos(i));
end

% Randomise the phase of the Gabors and make a properties matrix.
phaseLine = rand(1, nGabors) .* 360;
propertiesMat = repmat([NaN, freq, sigma, contrast,...
    aspectRatio, 0, 0, 0], nGabors, 1);
propertiesMat(:, 1) = phaseLine';

% Set the orientations for the methods of constant stimuli. We will center
% the range around zero (vertical) and give it a range of 1.8 degress, this
% will mean we test between -(1.8 / 2) and +(1.8 / 2). Finally we will test
% seven points linearly spaced between these extremes.
baseOrientation = 0;
orRange = 1.9;
numSteps = 7;
stimValues = linspace(-orRange / 2, orRange / 2, numSteps) + baseOrientation;

% Now we set the number of times we want to do each condition, then make a
% full condition vector and then shuffle it. This will randomly order the
% orientation we present our Gabor with on each trial.
numRepeats = 15;
condVector = Shuffle(repmat(stimValues, 1, numRepeats));

% Calculate the number of trials
numTrials = numel(condVector);

% Make a vector to record the response for each trial
respVector = zeros(1, numSteps);

% Make a vector to count how many times we present each stimulus. This is a
% good check to make sure we have done things right and helps us when we
% input the data to plot anf fit our psychometric function
countVector = zeros(1, numSteps);


%----------------------------------------------------------------------
%                       Timing Information
%----------------------------------------------------------------------

% Presentation Time for the Gabor in seconds and frames
presTimeSecs = 0.2;
presTimeFrames = round(presTimeSecs / ifi);

% Interstimulus interval time in seconds and frames
isiTimeSecs = 1;
isiTimeFrames = round(isiTimeSecs / ifi);

% Numer of frames to wait before re-drawing
waitframes = 1;


%----------------------------------------------------------------------
%                       Keyboard information
%----------------------------------------------------------------------

% Define the keyboard keys that are listened for. We will be using the left
% and right arrow keys as response keys for the task and the escape key as
% a exit/reset key
escapeKey = KbName('ESCAPE');
leftKey = KbName('LeftArrow');
rightKey = KbName('RightArrow');


%----------------------------------------------------------------------
%                       Experimental loop
%----------------------------------------------------------------------

% Animation loop: we loop for the total number of trials
for trial = 1:numTrials

    % Get the Gabor angle for this trial (negative values are to the right
    % and positive to the left)
    theAngle = condVector(trial);

    % Randomise the side which the Gabor is displayed on
    side = round(rand) + 1;
    thisDstRect = allRects(:, side);

    % Change the blend function to draw an antialiased fixation point
    % in the centre of the screen
    Screen('BlendFunction', window, 'GL_SRC_ALPHA', 'GL_ONE_MINUS_SRC_ALPHA');

    % If this is the first trial we present a start screen and wait for a
    % key-press
    if trial == 1
        DrawFormattedText(window, 'Press Any Key To Begin', 'center', 'center', black);
        Screen('Flip', window);
        KbStrokeWait;
    end

    % Flip again to sync us to the vertical retrace at the same time as
    % drawing our fixation point
    Screen('DrawDots', window, [xCenter; yCenter], 10, black, [], 2);
    vbl = Screen('Flip', window);

    % Now we present the isi interval with fixation point minus one frame
    % because we presented the fixation point once already when getting a
    % time stamp. We dont really need a loop here, we could use a value of
    % waitframnes greater than one. However, as we are using a loop below,
    % I have also used a loop here.
    for frame = 1:isiTimeFrames - 1

        % Draw the fixation point
        Screen('DrawDots', window, [xCenter; yCenter], 10, black, [], 2);

        % Flip to the screen
        vbl = Screen('Flip', window, vbl + (waitframes - 0.5) * ifi);
    end

    % Now we draw the Gabor and the fixation point
    for frame = 1:presTimeFrames

        % Set the right blend function for drawing the gabors
        Screen('BlendFunction', window, 'GL_ONE', 'GL_ZERO');

        % Draw the Gabor
        Screen('DrawTextures', window, gabortex, [], thisDstRect, theAngle, [], [], [], [],...
            kPsychDontDoRotation, propertiesMat');

        % Change the blend function to draw an antialiased fixation point
        % in the centre of the array
        Screen('BlendFunction', window, 'GL_SRC_ALPHA', 'GL_ONE_MINUS_SRC_ALPHA');

        % Draw the fixation point
        Screen('DrawDots', window, [xCenter; yCenter], 10, black, [], 2);

        % Flip to the screen
        vbl = Screen('Flip', window, vbl + (waitframes - 0.5) * ifi);
    end


    % Change the blend function to draw an antialiased fixation point
    Screen('BlendFunction', window, 'GL_SRC_ALPHA', 'GL_ONE_MINUS_SRC_ALPHA');

    % Draw the fixation point
    Screen('DrawDots', window, [xCenter; yCenter], 10, black, [], 2);

    % Flip to the screen
    vbl = Screen('Flip', window, vbl + (waitframes - 0.5) * ifi);

    % Now we wait for a keyboard button signaling the observers response.
    % The left arrow key signals a "left" response and the right arrow key
    % a "right" response. You can also press escape if you want to exit the
    % program
    respToBeMade = true;
    while respToBeMade
        [keyIsDown,secs, keyCode] = KbCheck;
        if keyCode(escapeKey)
            ShowCursor;
            sca;
            return
        elseif keyCode(leftKey)
            response = 1;
            respToBeMade = false;
        elseif keyCode(rightKey)
            response = 0;
            respToBeMade = false;
        end
    end

    % Record the response
    respVector(stimValues == theAngle) = respVector(stimValues == theAngle)...
        + response;

    % Add one to the counter for that stimulus
    countVector(stimValues == theAngle) = countVector(stimValues == theAngle) + 1;

end

data = [stimValues; respVector; countVector]';

figure;
plot(data(:, 1), data(:, 2) ./ data(:, 3), 'ro-', 'MarkerFaceColor', 'r');
axis([min(data(:, 1)) max(data(:, 1)) 0 1]);
xlabel('Angle of Orientation (Degrees)');
ylabel('Performance');
title('Psychometric function');

% Clean up
sca;
%%
    Screen('BlendFunction', window, 'GL_SRC_ALPHA', 'GL_ONE_MINUS_SRC_ALPHA');

    % Draw the fixation point
    Screen('DrawDots', window, [xCenter; yCenter], 10, black, [], 2);
%%

myScreen = 0;
white = WhiteIndex(myScreen);
black = BlackIndex(myScreen);

grey = white/2;
myWindow = PsychImaging('OpenWindow',myScreen,grey,[800 300 2120 1480]);

[screenXpixels, screenYpixels] = Screen('WindowSize', window);
[xCenter, yCenter] = RectCenter(windowRect);

baseRect = [0 0 200 250];

%centeredRect = CenterRectOnPointd(baseRect, xCenter, yCenter);
 
rectColor = [0 0 0];

Screen('FillRect', window, rectColor, baseRect);

Screen('Flip', window);
KbStrokeWait;
sca;
%%
myScreen = 0;
white = WhiteIndex(myScreen);
black = BlackIndex(myScreen);
grey = white/2;

myWindow = PsychImaging('OpenWindow',myScreen,grey,[800 300 2120 1480]);

baseRect = [0 0 200 250];
rectColor1 = [0 0 0];
rectColor2 = [0 5 0];

%Screen('FillRect', myWindow, rectColor, baseRect);
%Screen('Flip', myWindow);
 y=0;
    x=0;
for i=0:200
   
  %  baseRect = [y y 200 250];
    Screen('FillRect', myWindow, rectColor1, [y x 200+y 250+x]);
     y=y+15;
     x=x+3;
     %x=x+15;
    Screen('Flip', myWindow);

     WaitSecs(0.1);

end
KbStrokeWait;
sca;
%%
myScreen = 0;
white = WhiteIndex(myScreen);
black = BlackIndex(myScreen);
grey = white/2;

myWindow = PsychImaging('OpenWindow',myScreen,grey,[800 300 2120 1480]);
%[screenXpixels, screenYpixels] = Screen('WindowSize', myWindow);
%[xCenter, yCenter] = RectCenter(windowRect);

Screen('TextSize', myWindow, 32);
myText = ['This is a text'];
%DrawFormattedText(myWindow, myText, 'center', 'center');
%Screen('Flip', myWindow);
for i=0:20
   
  DrawFormattedText(myWindow, myText, 'center', 'center',[1 0 0]);
    Screen('Flip', myWindow);
     WaitSecs(0.1);
      DrawFormattedText(myWindow, myText, 'center', 'center',[1 1 1]);
    Screen('Flip', myWindow);
     WaitSecs(0.1);
    DrawFormattedText(myWindow, myText, 'center', 'center',[0 0 0]);
    Screen('Flip', myWindow);
     WaitSecs(0.1);

end
KbStrokeWait;
sca;
%%
myScreen = 0;
white = WhiteIndex(myScreen);
black = BlackIndex(myScreen);
grey = white/2;

myWindow = PsychImaging('OpenWindow',myScreen,grey,[800 300 2120 1480]);
imgdata= imread('picture.png');
myTexture = Screen('MakeTexture', myWindow, imgdata);
while ~KbCheck(-1)
Screen('DrawTexture', myWindow, myTexture);
Screen('Flip', myWindow);
WaitSecs(.1);
Screen('Flip', myWindow);
end
%KbStrokeWait;
%sca;
%%
