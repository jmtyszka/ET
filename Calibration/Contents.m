% CALIBRATION
%
% Files
%   ET_ApplyCalibration   - Apply calibrated correction to raw pupil centroids or pupil-glint vectors
%   ET_AutoCalibrate      - Calculate video to gaze calibration model
%   ET_CalibrationFit     - Biquadratic fit to grid ordered calibration fixation centroids
%   ET_FindFixations_Heat - Identify fixations in spatial domain using heatmap
%   ET_FindFixations_Time - Identify fixations in time domain (dormant thread)


%   ET_SortFixations      - Sort fixations into appropriate grid
%   ET_ShowCalibration    - Show calibration in GUI
%   ET_PickFixationsOrder - If the number of fixations is neither 4 nor 9, do a manual check; 
%   ET_ShowValidation     - Show calibration in GUI
%   ET_PickFixations      - If the number of fixations is neither 4 nor 9, do a manual check; 
%   ET_LoadCalFixations   - Load predefined calibration fixation order from file
