% Calculate Orientation of a slice relative to B0 direction
% Jianbao

clc; clear

% read orientation from .jason file
% vim 67_GRETOF14_2D_p06xp06x1_55V_TR60_TE9_FA60_ave20_V24_RR.json
% ImageOrientationPatientDICOM

orientation=[
0.896882,
0.27217,
0.348605,
-4.20124e-09,
0.78822,
-0.615394  ];

% calculate the normal vector to the image plane
% using the cross product of the row and column direction cosines.
row_cosine=orientation(1:3);
col_cosine=orientation(4:6);
normal_vector=cross(row_cosine, col_cosine);

% set the B0 magnetic field direction vector
B0=[0, 1, 0];

% calculate dot product of the normal vector and the B0 direction vector
% output cosine of the angle between them
dot_product = dot(normal_vector, B0);

% calculate the magnitude of the normal_vector and B0 direction vector
magnitude_normal = norm(normal_vector);
magnitude_B0 = norm(B0);

% calculate the cosine of the angle using dot product and magnitudes
cos_theta = dot_product / (magnitude_normal * magnitude_B0);

% calculate the angle in radians
% and convert ot degree
theta_radius = acos(cos_theta);
theta_degrees = rad2deg(theta_radius);

theta_degrees 

%% Note of interests
% the third column of the "voxel to ras transform" is the rotation part of
% the matrix that represents the norm vector to the image plane
% I checked the "voxel to ras transform" using mri_info and the
% "Normal_vector" from this code, exactly!