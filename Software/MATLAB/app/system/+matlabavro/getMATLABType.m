function [outputTypeStr] = getMATLABType(inputTypeStr) 
% GETMATLABTYPE Helper function to map the Avro types to MATLAB types
% Given the type of an Avro variable / object, this function will return
% the appropriate MATLAB type.
% 
% The following types are supported
% 
%      Avro Type     MATLAB Type
%      =========     ===========
%      'boolean'    'logical' 
%      'int'        'int32' 
%      'long'       'int64' 
%      'float'      'single' 
%      'double'     'double' 
%      'bytes'      'int8' 
%      'string'     'string'
% 
%  Everything else is unsupported
% 
% Define the mapping here - please see >> help datatypes

% Copyright (c) 2022 MathWorks, Inc.

inputTypeStr = convertStringsToChars(inputTypeStr);

tMap = containers.Map();
tMap('double') = 'double';
tMap('boolean') = 'logical';
tMap('int') = 'int32';
tMap('long') = 'int64';
tMap('float') = 'single';
tMap('double') = 'double';
tMap('bytes') = 'int8';
tMap('string') = 'string';

% NOT CURRENTLY SUPPORTED
% tMap('records') = 'null';
% tMap('enums') = 'null';
% tMap('arrays') = 'null'; 
% tMap('maps') = 'null';
% tMap('union') = 'null';
% tMap('fixed') = 'null';

outputTypeStr = tMap(inputTypeStr);


end %function