#!bin/bash
# Caculate angle between TOF slice and anatomical surface
# Jianbao Wang

#====== Now the solution is to use human position for both whole brain and partial brain
# And scale back the whole brain data, so can keep not trick size of partial brain
# previouse version include the surface rescale back. Now move this part to an independent script.
# Sun Nov 17 12:09:28 UTC 2024
# Current version modified from ver-2_GEN. More concise and specific.
# Thu Jan 30 10:06:04 UTC 2025

#[]------ rescale back the surface (and some required anat volume) files ------

export SUBJECTS_DIR=/data/jianbao/AnalysisExpBox/009ColMonk/Subj_Anat/
SUBJECT=Erke220421_rescaleback
AnalysiDIR=/data/jianbao/AnalysisExpBox/009ColMonk/Subj_Vessel/Erke_230216/OrientationEffect_67

ANAT=../Align/Ali_To_TOF67_bc_90_am_ss_hp_5_MPRAGE_0p5iso_70V_avg2_SAG_HF_RR.nii
sANAT=`echo $(basename "$ANAT") | cut -d '.' -f 1`

TOFIMG=../hp_il_Uni_masked_67.nii.gz
sTOFIMG=`echo $(basename "$TOFIMG") | cut -d '.' -f 1`
TOFind="${sTOFIMG##*_}"
# using parameter expansion to remove everything up to and including the last underscore

Hemi=rh

#[]------ human position of TOF and partial MPRAGE ------
#mri_convert il_Uni_masked_67.nii.gz hp_il_Uni_masked_67.nii.gz --sphinx
#mri_convert 5_MPRAGE_0p5iso_70V_avg2_SAG_HF_RR.nii hp_5_MPRAGE_0p5iso_70V_avg2_SAG_HF_RR.nii --sphinx

#[]------ bias correction ------
#3dAutomask -prefix am_hp_5_MPRAGE.nii hp_5_MPRAGE_0p5iso_70V_avg2_SAG_HF_RR.nii

# 3dcalc -a -b -expr "a*b" -prefix ss_*

#b=90
#N4BiasFieldCorrection -v 1 -d 3 -s 2 -r 0         -i ss_hp_5_MPRAGE_0p5iso_70V_avg2_SAG_HF_RR.nii         -o [bc_${b}_am_ss_hp_5_MPRAGE_0p5iso_70V_avg2_SAG_HF_RR.nii, bcfield_${b}_am_ss_hp_5_MPRAGE_0p5iso_70V_avg2_SAG_HF_RR.nii]         -c '[50x50x50x50,0.0000001]'         -b "[${b}]" -x am_hp_5_MPRAGE.nii


#[]------ BBR registration ------
# mkdir OrientationEffect
# cd OrientationEffect
cd $AnalysiDIR

bbregister --s ${SUBJECT} --init-coreg --6 \
	--mov ${ANAT} \
	--reg register.dof6.dat --lta register.dof6.lta \
	--init-reg-out init.register.dof6.dat --t1

: <<'EOF'
bbregister --s ${SUBJECT} --init-coreg --6 \
	--mov ../bc_90_am_ss_hp_5_MPRAGE_0p5iso_70V_avg2_SAG_HF_RR.nii \
	--reg register.dof6.dat --lta register.dof6.lta \
	--init-reg-out init.register.dof6.dat --t1
EOF

# tkregisterfv --mov bc_90_am_ss_hp_5_MPRAGE_0p5iso_70V_avg2_SAG_HF_RR.nii --reg register.dof6.lta --surfs 
bbregister --init-reg init.register.dof6.lta \
--mov ${ANAT} \
--reg register.dof6.dat --lta register.dof6.lta --t1

: <<'EOF'
bbregister --init-reg init.register.dof6.lta \
	--mov ../bc_90_am_ss_hp_5_MPRAGE_0p5iso_70V_avg2_SAG_HF_RR.nii \
	--reg register.dof6.dat --lta register.dof6.lta --t1
EOF

#[]------ transform lta needed for angle calculation ------
lta_convert --inlta register.dof6.lta \
	--outlta register.dof6_src_orig.lta \
	--src $SUBJECTS_DIR/$SUBJECT/mri/orig.mgz
# write in header info from orig
# See Olivia FS Wiki

#[]------ Align surface to partial anatomy space ------
mri_surf2surf --s $SUBJECT --reg register.dof6_src_orig.lta \
	--sval-xyz pial \
	--tval-xyz ${ANAT} \
	--hemi ${Hemi} --surfreg pial --tval ./${Hemi}.pial2TOFlta

# QA:
freeview $ANAT -f ${Hemi}.pial2TOFlta

: <<'EOF'
mri_surf2surf --s $SUBJECT --reg register.dof6_src_orig.lta \
	--sval-xyz pial \
	--tval-xyz ../bc_90_am_ss_hp_5_MPRAGE_0p5iso_70V_avg2_SAG_HF_RR.nii \
	--hemi rh --surfreg pial --tval ./rh.pial2TOFlta
EOF
#Output in SUBJECT surface folder
#Q: why don't need invert?

#[]------ calculate angle ------
# mris_convert --angle rh.white2TOFlta01 angle_rh.white2TOFlta01.mgz
# mris_convert --angle rh.pial2TOFlta angle_rh.pial2TOFlta.mgz
mris_convert --angle ${Hemi}.pial2TOFlta angle_${Hemi}.pial2TOFlta.mgz

# QA:
freeview -f ${Hemi}.pial2TOFlta:overlay=angle_${Hemi}.pial2TOFlta.mgz

#[]------ angle file (surface overlay) to volume ------

# Updated trouble shooting
mri_vol2vol --mov $SUBJECTS_DIR/$SUBJECT/mri/orig.mgz \
	--targ $SUBJECTS_DIR/$SUBJECT/mri/ribbon.mgz \
	--lta register.dof6_src_orig.lta \
	--o ribbon_to_TOF.mgz --inv --nearest

# QA:
freeview ribbon_to_TOF.mgz ${TOFIMG}

mri_surf2vol --o vol_angle_transformed_${Hemi}.pial2TOF.mgz \
	--ribbon ribbon_to_TOF.mgz \
	--so ./${Hemi}.pial2TOFlta \
       	./angle_${Hemi}.pial2TOFlta.mgz

#[]------ transform lta to TOF space ------
# required for resampling using Jacobox_Vertex2VolumeTOF_resample_short_67.m
lta_convert --inlta register.dof6_src_orig.lta \
--outreg register.dof6_src_orig_2_src_tof.dat \
--src ${TOFIMG}

# Then run 
# Jacobox_Vertex2VolumeTOF_resample_short_67.m
# Jacobox_Calc_OrientationImage_67.m
# To calculate orientation of single slice image
# 48.3339
# /data/jianbao/AnalysisExpBox/009ColMonk/Subj_Vessel/Erke_230216/OrientationEffect_67
OrientSlice=48.3339
3dcalc -a Angle_NearDisResample_${TOFind}.nii \
-b ../mask_${TOFind}_RmLargeVessel.nii \
-expr "abs(a-${OrientSlice})*b" \
-prefix RELz_abs_Angle_NearDisResample_${TOFind}.nii

# Then run
# Jacobox_VesselInSliceAngle.sh
# Jacobox_Plot_Surf_Angle_67.m


#============================================================================================