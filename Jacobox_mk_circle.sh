#!/bin/bash
# make circle mask surrounding the input vessels
# Jianbao

InImg=$1

3dmask_tool -dilate_input 2 \
	-inputs ${InImg} \
	-prefix di2_${InImg}

3dmask_tool -dilate_input 1 \
	-inputs ${InImg} \
	-prefix di1_${InImg}

3dcalc -a di2_${InImg} -b di1_${InImg} -expr "a-b" -prefix tiss_${InImg}
