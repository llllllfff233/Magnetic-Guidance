function medial_axis = LoadMedialAxis(left_or_right_side, medial_axis_filepath)
% LoadMedialAxis - Retrieves medial axis points from .txt file
%
%   LoadFiducialMarkerLocations(side) asks the user to select a 
%   tool definition file and returns the points as a [3xN] array.
%   
%   ------
%   NOTE:
%   ------
%   Outputs points in the same coordinate frame (e.g. DOES NOT transform
%   from the Xoran's LPI to LPS)!!
%
%
%   left_or_right_side => either 'L' or 'R'
%   medial_axis_filepath => path to the medial axis .txt file generated by IMPROVISE
%
% Examples:
%   >> medial_axis = LoadMedialAxis();
%   >> medial_axis = LoadMedialAxis('C:\path\to\medial_axis.txt');
%
% Trevor Bruns
% June 2019

if nargin == 0
    error('must specify which side (''L'' or ''R'')')
elseif nargin == 1
    [filename, pathname] = uigetfile('.txt','Select Medial Axis File');
    medial_axis_filepath = fullfile(pathname, filename);
elseif nargin > 2
    error('too many inputs')
end

% open file
fileID = fopen(medial_axis_filepath,'r');

% parse file and store points
pts = textscan(fileID, '%f%f%f%[^\n\r]', 'Delimiter', '', 'WhiteSpace', '', 'ReturnOnError', false);

if strcmpi(left_or_right_side, 'L')
    medial_axis = flip([pts{:, 1}, pts{:, 2}, pts{:, 3}]', 2);
elseif strcmp(left_or_right_side, 'R')
    medial_axis = [pts{:, 1}, pts{:, 2}, pts{:, 3}]';
else
    error('left_or_right_side can only be ''L'' or ''R''')
end

% check that side was correct (fit circle to both ends, compare radii)
[~, ~, radius_basal]  = CircFit3D(medial_axis(:,1:10)');
[~, ~, radius_apical] = CircFit3D(medial_axis(:,end-10:end)');

if radius_apical > radius_basal
    warning('Side specified appears to be wrong ... reversing path direction')
    medial_axis = fliplr(medial_axis);
end

% close file
fclose(fileID);

end