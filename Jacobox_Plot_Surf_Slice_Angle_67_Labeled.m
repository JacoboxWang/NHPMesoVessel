% Plot Orientations for each voxel in vessels
% Jianbao

% read in the Angle distribution volume
% Distrifile = mrir_sysutil__wildfile('Distri_thre_2.5std__RELz_Angle_NearDisResample0.nii');
% Distrifile = mrir_sysutil__wildfile('Distri_Thre2std_RELz_abs_Angle_NearDisResample_77.nii');
Distrifile = mrir_sysutil__wildfile('Distri_Ves_LabelFig4_thre_2std_hp_il_Uni_masked_67_mask_67_RmLargeVessel_RELz_abs_Angle_NearDisResample_67.nii');

% read in the thresholded mask volume
% Distrimaskfile = mrir_sysutil__wildfile('../mask_Thre2std_hp_il_Uni_masked_77.nii.gz');
Distrimaskfile = mrir_sysutil__wildfile('Ves_LabelFig4_thre_2std_hp_il_Uni_masked_67_mask_67_RmLargeVessel.nii.gz');

[Distri, M0_Distri_vox2ras, M0_Distri_vox2tkr, Distrihdr] = mris_read_nii(Distrifile);

[Distrimask, M0_Distrimask_vox2ras, M0_Distrimask_vox2tkr, Distrimaskhdr] = mris_read_nii(Distrimaskfile);
nonzeronTOFind=find(Distrimask==1);

h0=figure('InvertHardcopy','off');
h0.Position = [200 200 500 560];
h1=histogram(Distri(nonzeronTOFind),11);
h1.FaceColor = [0.8 0.8 0.8];
h1.LineWidth = 2;
h1.EdgeColor = [0.85 0.85 0.85];

%set(gca,'XTick', [0:30:90]);
maxBinCount = max(h1.Values);
set(gca,'TickLength',[0 0],'Color', 'k', 'XColor', 'w','YColor', 'w');
set(gca,'FontSize',23);
ylim([0, maxBinCount + 20]);
%ylabel('number of voxel');
xt=xticks;
a1x=gca;
a1x.Box='off';
% 
% subplot(2,1,2);
% pos2 = get(gca, 'Position');
% pos2(4) = pos2(4)/2; % decrease the height of the plot
% pos2(2) = pos2(2) + 0.25; % Move the second subplot up
% set(gca, 'Position', pos2);
% h2=boxplot(Distri(nonzeronTOFind),'Orientation', 'horizontal', 'Colors', 'w', 'Symbol', '.', 'Widths', 0.36);
% set(h2 ,{'linew'}, {2});
% a2x=gca;
% a2x.Box='off';
% a2x.YColor='none';
% linkaxes(findall(gcf, 'Type', 'axes'), 'x');
% set(gca,'FontSize',23);
% xticks(xt);
% xlabel('{angle difference (degrees)}');
% 
 set(gca, 'Color', 'k', 'XColor', 'w');
 set(gcf, 'Color', 'k')
 
%% calculate median, max
 finalDist=(Distri(nonzeronTOFind));
 me=median(finalDist);
 ma=max(finalDist);
 
 finalDist(finalDist == ma) = [];
 me_demax=median(finalDist);
 ma_demax=max(finalDist);
 
 disp(['median is: ', num2str(me)]);
 disp(['max is: ', num2str(ma)]);
 disp(['max after remove outlier is: ', num2str(ma_demax)]);
 
%% calculate the values
% val.medianValue = median(Distri(nonzeronTOFind));
% val.Q1 = quantile(Distri(nonzeronTOFind), 0.25);
% val.Q3 = quantile(Distri(nonzeronTOFind), 0.75);
% val.IQR = val.Q3 - val.Q1;
% val.lowerWhisker = max(min(Distri(nonzeronTOFind)), val.Q1 - 1.5 * val.IQR);
% val.upperWhisker = min(max(Distri(nonzeronTOFind)), val.Q3 + 1.5 * val.IQR);
% 

%% estimate FWHM
% [counts, binCenters]=hist(Distri(nonzeronTOFind),11);
% 
% 
% % Find the peak value of the histogram 
% [maxCount, maxIndex] = max(counts); 
% % Determine the half maximum value 
% halfMax = maxCount / 2; 
% % Find the bins where the histogram crosses the half maximum value 
% leftIndex = find(counts >= halfMax, 1, 'first'); 
% rightIndex = find(counts >= halfMax, 1, 'last'); 
% % Calculate the FWHM 
% fwhm = binCenters(rightIndex) - binCenters(leftIndex); 
% % Display the result 
% disp(['FWHM: ',num2str(fwhm)]);
% 
% hold on;
% plot([binCenters(leftIndex), binCenters(rightIndex)], [halfMax, halfMax], 'b-', 'LineWidth', 5);
