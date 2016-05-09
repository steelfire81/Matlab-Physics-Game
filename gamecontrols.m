clear;

% CONSTANTS
XMIN = 0;
XMAX = 100;
YMIN = 0;
YMAX = 100;
GOALWIDTH = 5;
GOALHEIGHT = 5;
PLAYERWIDTH = 2;
PLAYERHEIGHT = 2;
FRAMETIME = (1/15);
GRAVITY = 9.8; % gravity on the moon
MOVESPEED = 5; % units per second
JUMPV = 10;
LEVELS = cellstr(['level0.csv';'level1.csv']);

% MAIN FUNCTION
% Initialize everything
figure();
axis([XMIN XMAX YMIN YMAX]);
set(gca, 'visible', 'off');
drawnow;

isGameOver = false;
level = 1;
filename = '';
while ~isGameOver
    % load next level
    if level > length(LEVELS)
        break; % quit if done with all levels
    else
        filename = char(LEVELS(level));
    end
    
    % Clear old level
    rectangle('Position', [XMIN YMIN (XMAX - XMIN) (YMAX - YMIN)], 'FaceColor', 'white', 'EdgeColor', 'white');
    
    % Load new level
    lines = csvread(filename);
    startx = lines(1, 1);
    starty = lines(1, 2);
    goalx = lines(1, 3);
    goaly = lines(1, 4);
    dimensions = size(lines);
    linemax = dimensions(1);
    curr = 2;
    while curr <= linemax
        line([lines(curr, 1) lines(curr, 3)], [lines(curr, 2) lines(curr, 4)]);
        curr = curr + 1;
    end
    rectangle('Position', [(goalx - (GOALWIDTH / 2)) (goaly - (GOALHEIGHT / 2)) GOALWIDTH GOALHEIGHT], 'FaceColor', 'green', 'EdgeColor', 'green');
    
    % Complete level
    isLevelOver = false;
    xPosition = startx;
    yPosition = starty;
    xPositionLast = xPosition;
    yPositionLast = yPosition;
    xVelocity = 0;
    yVelocity = 0;
    xAcceleration = 0;
    yAcceleration = 0;
    while ~isLevelOver
        % Redraw background
        curr = 2;
        while curr <= linemax
            line([lines(curr, 1) lines(curr, 3)], [lines(curr, 2) lines(curr, 4)]);
            curr = curr + 1;
        end
        rectangle('Position', [(goalx - (GOALWIDTH / 2)) (goaly - (GOALHEIGHT / 2)) GOALWIDTH GOALHEIGHT], 'FaceColor', 'green', 'EdgeColor', 'green');
        
        % Check if on ground (for now always true)
        onGround = false;
        foundGround = false;
        curr = 2;
        ground = YMIN;
        while (curr <= linemax) && ~foundGround
            lineXStart = lines(curr, 1);
            lineXEnd = lines(curr, 3);
            if (xPosition >= lineXStart) && (xPosition <= lineXEnd) && (lineXStart ~= lineXEnd) % No vertical lines
                foundGround = true;
                lineYStart = lines(curr, 2);
                lineYEnd = lines(curr, 4);
                slope = (lineYEnd - lineYStart) / (lineXEnd - lineXStart);
                distance = xPosition - lineXStart;
                ground = (slope * distance) + lineYStart;
                onGround = (yPosition <= ground);
            end
            curr = curr + 1;
        end
        
        % Check for input
        goingLeft = false;
        goingRight = false;
        jumping = false;
        key = get(gcf, 'CurrentKey');
        if(strcmp(key, 'leftarrow'))
            goingLeft = true;
        elseif(strcmp(key, 'rightarrow'))
            goingRight = true;
        elseif(strcmp(key, 'uparrow'))
            jumping = true;
        end
        
        % Update velocities
        if onGround
            yVelocity = 0;
            if goingLeft && goingRight
                xVelocity = 0;
            elseif goingLeft
                xVelocity = -MOVESPEED;
            elseif goingRight
                xVelocity = MOVESPEED;
            end
            if jumping
                yVelocity = JUMPV;
            end
        else
            % For now, only y velocity will update
            yVelocity = yVelocity - (GRAVITY * FRAMETIME);
        end
        
        % Update position
        xPosition = xPosition + (FRAMETIME * xVelocity);
        yPosition = yPosition + (FRAMETIME * yVelocity);
        
        % Ensure boundaries
        if xPosition < XMIN
            xPosition = XMIN;
        elseif xPosition > XMAX
            xPosition = XMAX;
        end
        if yPosition < ground
            yPosition = ground;
        elseif yPosition > YMAX
            yPosition = YMAX;
        end
        
        % Redraw
        rectangle('Position', [xPositionLast yPositionLast PLAYERWIDTH PLAYERHEIGHT], 'FaceColor', 'white', 'EdgeColor', 'white');
        rectangle('Position', [xPosition yPosition PLAYERWIDTH PLAYERHEIGHT], 'FaceColor', 'red', 'EdgeColor', 'red');
        drawnow;
        pause(FRAMETIME);
        
        % Check if at goal
        if (xPosition >= (goalx - (GOALWIDTH / 2))) && (xPosition <= (goalx + (GOALWIDTH / 2))) && (yPosition >= (goaly - (GOALHEIGHT / 2))) && (yPosition <= (goaly + (GOALHEIGHT / 2)))
            isLevelOver = true;
        end
        
        xPositionLast = xPosition;
        yPositionLast = yPosition;
    end
    
    % Increment information
    level = level + 1;
end