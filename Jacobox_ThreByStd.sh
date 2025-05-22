#!/bin/bash
# Thresholding TOF image by mean + $stdfactor
# Jianbao

print_usage() {
echo "Usage: $0 [options]"
echo " input image, standard deviation factor, mask"
echo " -h, --help"
}

if [[ "$1" == "-h" || "$1" == "--help" ]]; then
	print_usage
	exit 0
fi

# crop image for further convenient
#3dAutobox -prefix crop_MaskedSq_56_e1.nii MaskedSq_56_e1.nii 
#3dAutobox -prefix crop_MaskedSq_32_e1.nii MaskedSq_32_e1.nii 

#ImgIn=Uni_crop_MaskedSq_56_e1.nii
ImgIn=$1
sImgIn=`echo $(basename "$ImgIn") | cut -d '.' -f 1`
#StdF=2
StdF=$2

IMGmsk=$3
sIMGmsk=`echo $(basename "$IMGmsk") | cut -d '.' -f 1`

if [ -f "meanstd${StdF}_${sImgIm}_${sIMGmsk}.txt" ]; then
	echo "meanstd${StdF}_${sImgIm}_${sIMGmsk}.txt existes. Skipping ..."
else
	3dBrickStat -mean -stdev -mask ${IMGmsk} ${ImgIn} >> meanstd${StdF}_${sImgIn}_${sIMGmsk}.txt
fi

#cat rm_meanstd 
mean=`awk '{print $1}' meanstd${StdF}_${sImgIn}_${sIMGmsk}.txt`
std=`awk '{print $2}' meanstd${StdF}_${sImgIn}_${sIMGmsk}.txt`

# mean plus standard deviation
3dcalc -a ${ImgIn} -b ${IMGmsk} -expr "(step(a-(${mean}+${StdF}*${std})))*b" -prefix thre_${StdF}std_${sImgIn}_${sIMGmsk}.nii.gz
# mean mimus standard deviation
3dcalc -a ${ImgIn} -b ${IMGmsk} -expr "(step((${mean}-${StdF}*${std})-a))*b" -prefix thre_minus${StdF}std_${sImgIn}_${sIMGmsk}.nii.gz

#rm rm_*

3dclust -NN3 1 -savemask Ordermask_thre_${StdF}std_${sImgIn}_${sIMGmsk}.nii.gz thre_${StdF}std_${sImgIn}_${sIMGmsk}.nii.gz

3dclust -NN3 1 -savemask Ordermask_thre_minus${StdF}std_${sImgIn}_${sIMGmsk}.nii.gz thre_minus${StdF}std_${sImgIn}_${sIMGmsk}.nii.gz


#3dBrickStat -max Ordermask_thre_${StdF}std_${ImgIn}

#141
#142

# area=(107*0.064)*(75*0.064)
# density=n/area
