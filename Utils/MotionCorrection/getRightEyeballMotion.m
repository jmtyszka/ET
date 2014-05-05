function Et = getRightEyeballMotion(rawNiiFile,motionDir,nVolDel)
% once we know the camera orientation and the position on the eye center
% during calibration (fitCameraImage_calibrated), we can use the EPI motion correction parameters to
% have a continuously updated calibration model...
%   - load mid-run EPI (the template for FSL motion correction)
%   - define right eyeball center
%   - apply rotation matrices from FSL and plot [Ex,Ey,Ez] as a function of time
%   - continuously update 12-parameter calibration model 
%   - compute GAZE!
dbstop if error

if nargin<1
    rawNiiFile = 'E:\autism\preprocLBnew\Ra0082\1socialA_run1\Ra0082_1socialA_run1_raw.nii';
end
if nargin<2
    motionDir = 'E:\autism\preprocLBnew\Ra0082\1socialA_run1\prestats.feat\mc\prefiltered_func_data_mcf.mat';
end
if nargin<3
nVolDel = 2;
end
makevid = 0;


% load mid-run volume
V = spm_vol(rawNiiFile);
V = V(nVolDel+ceil((length(V)-nVolDel)/2));

% use SPM orthviews to click and find center of right eyeball
%------
% code adapted from spm_image.m
%------
global st
fg = spm_figure('GetWin','Graphics');
spm_image('Reset');
spm_orthviews('Image', V, [0.0 0.45 1 0.55]);
if isempty(st.vols{1}), return; end
spm_orthviews('MaxBB');
st.callback = 'spm_image(''shopos'');';
st.B = [0 0 0  0 0 0  1 1 1  0 0 0];
WS = spm('WinScale');
uicontrol(fg,'Style','Frame','Position',[70 250 180 90].*WS);
uicontrol(fg,'Style','Text', 'Position',[75 320 170 016].*WS,'String','Crosshair Position');
uicontrol(fg,'Style','PushButton', 'Position',[75 316 170 006].*WS,...
    'Callback','spm_orthviews(''Reposition'',[0 0 0]);','ToolTipString','move crosshairs to origin');
uicontrol(fg,'Style','Text', 'Position',[75 295 35 020].*WS,'String','mm:');
uicontrol(fg,'Style','Text', 'Position',[75 275 35 020].*WS,'String','vx:');
uicontrol(fg,'Style','Text', 'Position',[75 255 65 020].*WS,'String','Intensity:');
st.mp = uicontrol(fg,'Style','edit', 'Position',[110 295 135 020].*WS,'String','','Callback','spm_image(''setposmm'')','ToolTipString','move crosshairs to mm coordinates');
st.vp = uicontrol(fg,'Style','edit', 'Position',[110 275 135 020].*WS,'String','','Callback','spm_image(''setposvx'')','ToolTipString','move crosshairs to voxel coordinates');
st.in = uicontrol(fg,'Style','Text', 'Position',[140 255  85 020].*WS,'String','');

pause

% when use presses "return", figure disappears and coordinates of the right
% eyeball center are recorded in Eorig
Eorig = spm_orthviews('Pos');
spm_figure('Close',fg);
clear st

%----------
% simulate motion of the right eyeball center
%----------
% load transformation matrices
count = 0;
MAT = [];
while exist(fullfile(motionDir,['MAT_',stringfromnumber(count,4)]),'file'),
    MAT = cat(3,MAT,load(fullfile(motionDir,['MAT_',stringfromnumber(count,4)])));
    count = count + 1;
end


if makevid
    if ~isunix
    vidObj = VideoWriter('exampleRightEyeMovement.mp4','MPEG-4');
else
    vidObj = VideoWriter('exampleRightEyeMovement.avi','Motion JPEG AVI');
end
set(vidObj,'FrameRate',10);
open(vidObj);
end

% show motion in 3d (and plot distance to mid-run position)
Et = nan(3,size(MAT,3));

D = nan(1,size(MAT,3));

if makevid
figure; 
end

for ivol = 1:size(MAT,3)
   
    Eh = squeeze(MAT(:,:,ivol))*[Eorig;1];
    E = Eh(1:3)/Eh(4); Et(:,ivol) = E;
    D(ivol) = sqrt(sum((E - Eorig).^2));
    
    if makevid
    clf
%     subplot(121);
%     plot3(Eorig(1),Eorig(2),Eorig(3),'k+','Markersize',10)
%     Eh = squeeze(MAT(:,:,ivol))*[Eorig;1];
%     E = Eh(1:3)/Eh(4);
%     hold on;
%     plot3(E(1),E(2),E(3),'r+','Markersize',10);
%     axis([Eorig(1)-3 Eorig(1)+3 Eorig(2)-3 Eorig(2)+3 Eorig(3)-3 Eorig(3)+3]);
%     grid on;
%     title(sprintf('Volume %d/%d',nVolDel + ivol, nVolDel + size(MAT,3)));
%     xlabel('x'),ylabel('y'),zlabel('z');
    subplot(321);hold on;title(sprintf('Volume %d/%d',ivol, size(MAT,3)));
    plot(Et(1,:));line([1 size(MAT,3)],[Eorig(1) Eorig(1)]);
    axis([1 size(MAT,3) Eorig(1)-3 Eorig(1)+3]);
    xlabel('x')
    subplot(323);hold on;
    plot(Et(2,:));line([1 size(MAT,3)],[Eorig(2) Eorig(2)]);
    axis([1 size(MAT,3) Eorig(2)-3 Eorig(2)+3]);
    xlabel('y')
    subplot(325);hold on;
    plot(Et(3,:));line([1 size(MAT,3)],[Eorig(3) Eorig(3)]);
    axis([1 size(MAT,3) Eorig(3)-3 Eorig(3)+3]);
    xlabel('z')
    % compute distance
    subplot(3,2,[2 4 6]);
    plot(1:size(MAT,3),D);hold on;
    line([1 size(MAT,3)],[0 0],'LineStyle','--','Color','k');
    xlim([1 size(MAT,3)]);ylim([0 5]);
    xlabel('Volume #');
    ylabel('distance of right eye center to reference');
    drawnow
    writeVideo(vidObj,getframe(gcf));
    end
end

if makevid,close(vidObj);end






