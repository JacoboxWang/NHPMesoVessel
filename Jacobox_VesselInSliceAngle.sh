#!/bin/bash

#AngImg=RELz_abs_Angle_NearDisResample_77.nii
#VesMsk=../mask_Thre2std_hp_il_Uni_masked_77.nii.gz
#MskImg=../mask_77_RmLargeVessel.nii
AngImg=RELz_abs_Angle_NearDisResample_67.nii
VesMsk=Ves_LabelFig4_thre_2std_hp_il_Uni_masked_67_mask_67_RmLargeVessel.nii.gz
MskImg=../mask_67_RmLargeVessel.nii


StrinThre=`echo $VesMsk | awk -F'_' '{print $2}'`

3dcalc -a ${AngImg} -b ${VesMsk} -c ${MskImg} -exp 'abs(a*b*c)' -prefix Distri_${StrinThre}_${AngImg}
