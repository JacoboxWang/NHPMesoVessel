% Sample Angles from vertex of surface of voxel of volume
% Author: Jianbao Wang
% Credit: Initial script from Dr. Jonathan R. Polimeni
% to use mris tools for calculating coordinate transformations 

clear; clc;

SUBJECTS_DIR = getenv('SUBJECTS_DIR');
SUBJECT = 'Erke220421_rescaleback';
RECON_DIR = fullfile(SUBJECTS_DIR, SUBJECT);

% read in the whole brain volume
[vol, M0_anat_vox2ras, M0_anat_vox2tkr] = mris_read_mgh(fullfile(RECON_DIR, 'mri', 'orig.mgz'));

% read in the TOF volume
% epifile = mrir_sysutil__wildfile('./il_Zp5_hp_il_Uni_masked_67.nii.gz');
toffile = mrir_sysutil__wildfile('../hp_il_Uni_masked_77.nii.gz');

% read in the TOF mask volume
maskfile = mrir_sysutil__wildfile('../mask_77_RmLargeVessel.nii');

% read in the surface overlay (angle file)
surfoverlay = mrir_sysutil__wildfile('./angle_rh.pial2TOFlta.mgz');
rh_angle = mris_read_mgh(surfoverlay);
anglef2=rh_angle(:,:,:,2);
% overlay in freeview is 0-based
% Check: freeview -f rh.pial2TOFlta:overlay=./angle_rh.pial2TOFlta.mgz


% read in the registration file
% need .dat
% so transform .dat from .lta
% Note using source as tof
% lta_convert --inlta register.dof6_src_orig.lta --outreg register.dof6_src_orig_2_src_tof.dat --src ../hp_il_Uni_masked_67.nii.gz

%regdatfile = mrir_sysutil__wildfile(sprintf('./register.dof6_src_orig_2_src_tof.dat'));
regdatfile = mrir_sysutil__wildfile(sprintf('./register.dof6_src_orig_2_src_tof77V1deep.dat'));


% what has been tried
%regdatfile = mrir_sysutil__wildfile(sprintf('./register.dof6_src_orig.dat'));
%regdatfile = mrir_sysutil__wildfile(sprintf('./register.dof6_dummy.dat'));

% read in the surface file
%rh_pial = mris_read_surface('./rh.pial2TOFlta');
rh_pial = mris_read_surface((fullfile(RECON_DIR, 'surf', 'rh.pial')));


% registration from the TOF to the surfaces/MPRAGE
reg = fmri_readreg(regdatfile);

[tof, M0_func_vox2ras, M0_func_vox2tkr, hdr] = mris_read_nii(toffile);

[mask, M0_mask_vox2ras, M0_mask_vox2tkr, maskhdr] = mris_read_nii(maskfile);
nonzeronTOFind=find(mask==1);

% registration from functional voxel indices (0-based) to anatomical voxel indices (0-based)
R0_func2anat_vox = inv(M0_anat_vox2tkr) * inv(reg) * M0_func_vox2tkr;

R1_func2anat_vox = vox2ras_0to1(R0_func2anat_vox);

% sanity check: visualize EPI volume over surface to make sure registration
% matrix and coordinates were read in properly.

% registration from functional voxel indices (0-based) to scanner RAS coordinates
R0_funcvox2ras = M0_anat_vox2ras * R0_func2anat_vox;

% registration from functional voxel indices (1-based) to scanner RAS coordinates
R1_funcvox2ras = vox2ras_0to1(R0_funcvox2ras);


[r,c,s] = ndgrid(1:size(tof,1), 1:size(tof,2),  1:size(tof,3));
[X, Y, Z] = mris_transform_coordinates(r, c, s, R1_funcvox2ras);

figure;
mris_display_faces(rh_pial);
mris_view_LAT('rh'); camlight;
ph = mris_display_volumebox(X, Y, Z);
set(ph, 'LineStyle', 'none');
title('EPI volume -- confirming registration')
drawnow;


%%
% ==================== begin finder ====================
X_col=reshape(X, [], 1);
Y_col=reshape(Y, [], 1);
Z_col=reshape(Z, [], 1);

TOF_voxel=[X_col, Y_col, Z_col];

% numPixelsT = length(TOF_voxel); 
numPixelsT = length(TOF_voxel(nonzeronTOFind)); 
numPixelsV = length(rh_pial.vertices);
%numPixelsV = length(surf_subset_outer.vertices);

% Initialize an array to store the closest indices 
% closestIndices = zeros(length(TOF_voxel), 1); 
closestIndices = zeros(length(nonzeronTOFind), 1); 


% Loop through each pixel in TOF

time1=clock;
for i = 1:numPixelsT 
    % Get the coordinates of the current pixel in T 
    coordT = TOF_voxel(nonzeronTOFind(i),:); 
    % Initialize the minimum distance and index 
    minDist = inf; 
    minIndex = 0; 
    % Loop through each pixel in V 
    for j = 1:numPixelsV 
        % Get the coordinates of the current pixel in V 
        coordV = rh_pial.vertices(j,:); 
        
        % Calculate the Euclidean distance 
        dist = norm(coordT - coordV); 
        % Update the minimum distance and index if necessary 
        if dist < minDist 
            minDist = dist; 
            minIndex = j; 
        end
    end
    % Store the closest index 
    closestIndices(i) = minIndex; 
end

time2=clock;
etime(time2, time1)

% closestAngleInd = anglef2(closestIndices);
% overlay in freeview is 0-based
% closestAngleVal = anglef2(closestIndices + 1);

closestAngleVal = anglef2(closestIndices);

AngleOnTOF = zeros(length(TOF_voxel), 1);
for j = 1:numPixelsT
    
AngleOnTOF(nonzeronTOFind(j)) = closestAngleVal(j);

end

AngleOnTOFfinal = reshape(AngleOnTOF, size(tof,1), size(tof,2));

% mris_save_nii('testAngle_matresample.nii', AngleOnTOFfinal, hdr)
% mris_save_nii('Angle_NearDisResample0.nii', AngleOnTOFfinal, hdr)
mris_save_nii('Angle_NearDisResample_77.nii', AngleOnTOFfinal, hdr)
