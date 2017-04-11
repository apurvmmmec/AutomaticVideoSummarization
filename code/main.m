% The code can be used to summarise such videos which contain considerable
% durations of no or very less activity and then some moments in between of
% activity.
% We present an algorith to create a time lapse video of such videos.

% Our algorithm is based on detecting activities in the video and play that
% part of video at normal framerate. The parts of video with no activity
% are identifed and played in a timelapse manner at faster framerate.

close all;

rootDir = 'test/';
timelapseVideoName = 'timelapse.avi';

datasetPath= [rootDir];

fprintf('Loading images\n');

numFrames=1200;

outFrames =[];

seekBarHt =30;

%Read all the frames of video

frames = load_sequence_color(datasetPath,'',1,numFrames,4,'jpg');
% frames = load_sequence_color(datasetPath,'',1,numFrames,4,'jpg');

%Get the size of each frame
img1=frames(:,:,:,1);
[rows, cols,ch]=size(img1);

% Difference of current frame is calculated average of previous numAverage
% frames
numAverage =10;

%Array to save difference value of each frame with average of previous n
%frames
dArr= zeros(numFrames-1,1);

% Temp matrix to save average of previous n frames
temp = zeros(rows,cols,3);

count=1;

%Seekbar to show when the video is moving fast and when it is moving slow
progressBar=zeros(seekBarHt,numFrames,3);

%Conter to keep a count of no. of frames that have to be skipped when there
%is no motion in scene
fastCount=0;


% Main Loop
% We read each frame and then compare it with previous numAverage=10 frames
% to see if the contents of current frame change. If the difference is
% above a certain threshold, then we decide that considerable motion has
% happenned in that frame with respect to previous frames. We add such
% frame to output video. For other frames where diff is less than
% threshold, we skip every 4 frames for such frames of inactivity. We
% therefore are able to see the important parts of video at normal speed
% and rest at time lapse. 

% The current video shows the scenario of a parking lot where cars enter and 
% leave and pedestrians also walk. We have adjusted the threshold such that
% difference in images caused due to walking of pedestrians can be ignored
% whereas the motion of car or multile cars that cause larger differences
% in frame are caught and played normally in output video.

for i=11:numFrames-1
    
    % Calculate average of previous numAverage frames
    for j=i-numAverage:i-1
        temp=temp+frames(:,:,:,j);
    end
    temp=temp./numAverage;
    
    % Read current frame
    img1=frames(:,:,:,i);
    
    %Calculate difference of current frame with average of previous frames
    diff= sqrt((temp-img1).^2);
    diff = sum(sum(sum(diff)))/(rows*cols);
    dArr(i)=diff;
    
    
    %If diff is above threshhold , motion is happenning, keep the frame in
    %output video and play at normal speed
    if(diff>0.16)
        
        %For the frames played at normal speed, green color is shown in
        %progress bar. green is (0,1,0). So setting 2nd channel to 1
        progressBar(:,i,2)=1;
        outFrames(size(outFrames,1)+1,1)=i;
        count=count+1;
    
        
    %Else if diff is below threshhold , scene is still, discard every 4th frame
    % in output video to play at faster speed
    else
        %For the frames played at fast speed, red color is shown in
        %progress bar. red is (1,0,0). So setting 1st channel to 1
        progressBar(:,i,1)=1;
        
        % We only add every 4th frame and discard rest of them
        if(mod(fastCount,4)==0)
            outFrames(size(outFrames,1)+1,1)=i;
            count=count+1;
        end
        fastCount=fastCount+1;
    end
end


% Resise the progress bar to image frame width for overlaying it in video
pbResized= imresize(progressBar,[seekBarHt,cols],'nearest');


% Write the output video
v = VideoWriter(timelapseVideoName);
open(v);


% For every frame that has to be written to output video, overlay
% progressbar in bottom of frame with an indicator showing current frame position in video 
numOutput = size(outFrames,1);
for i=1:numOutput
    % Modify the resized progressbar to add indicator of current frame on progressbar 
    modPb = pbResized(:,:,:);
    
    currFrame = outFrames(i,1);
    
    seekBarLoc = round((currFrame/numFrames)*cols);
    
    modPb(:,seekBarLoc,:)=0;
    
    writeVideo(v,[frames(:,:,:,currFrame);modPb(:,:,:)]);
end

close(v);

% Plot the difference values that help in deciding the threshold
plot(dArr);
title('Image Intensity Variation between current frame and Avg of previous N frames');
xlabel('Frames');
ylabel('Difference between current frame and Avg of previous N frames')
disp('done');