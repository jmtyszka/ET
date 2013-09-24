% PUPILOMETRY
%
% Files

%   ET_FindPupilInFrame     - Find best candidate for pupil within frame
%   ET_FindRemoveGlints     - Find and remove glints in frame
%   ET_FitEllipse_RANSAC    - Ellipse fit using Random Sample Consensus (RANSAC)
%   ET_FitEllipse_Region    - Ellipse fit using regional segmentation
%   ET_FitPupil             - Identify pupil within eye ROI
%   ET_HaarPupilCorrelation - Create correlation image for given pupil diameter
%   ET_IdentifyMainGlint    - Select best candidate for main glint from glints list
%   ET_IIRectSum            - Calculate rectangle sum from integral image
%   ET_NewPupil             - Create a new pupil structure
%   ET_OverlayPupil         - Draw pupil and glint overlayed on video frame
%   ET_RefinePupil          - Find regions, identify pupil and fit ellipse to boundary
%   ET_SegmentPupil         - Segment pupil within image
%   ET_Video_Pupilometry    - Perform pupilometry on all frames of a video
%   ET_SpikeDriftCorrect    - Remove spike artifacts and baseline drift from gaze centroid timeseries
