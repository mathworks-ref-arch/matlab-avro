function [avroStr] = getAvroType(inputStr) 
% GETAVROTYPE Helper function to map the Avro types
% Given the type of a MATLAB variable / object, this function will return
% the appropriate Avro type.
% 
% The following types are supported
% 
%      MATLAB Type   Avro Type
%      ===========   =========
%      'double'     'double' 
%      'single'     'float' 
%      'logical'    'boolean' 
%      'int8'       'bytes' 
%      'int16'      'int' 
%      'int32'      'int' 
%      'int64'      'long' 
%      'uint8'      'int' 
%      'uint16'     'int' 
%      'uint32'     'int' 
%      'uint64'     'long' 
%      'char'       'string'
%      'string'     'string'
%      'cellstr'    'string'
%      'cell'       'union'  *Note: limited to union of supported types
%      'struct'     'map' 
%      'timetable'  'long'
% 
%  Everything else is unsupported
% 
% Define the mapping here - please see >> help datatypes

% Copyright (c) 2020 MathWorks, Inc.

inputStr = convertStringsToChars(inputStr);

tMap = containers.Map();
tMap('double') = 'double';
tMap('single') = 'float';
tMap('logical') = 'boolean';
tMap('int8') = 'bytes';
tMap('int16') = 'int';
tMap('int32') = 'int';
tMap('int64') = 'long';
tMap('uint8') = 'int';
tMap('uint16') = 'int';
tMap('uint32') = 'int';
tMap('uint64') = 'long';
tMap('char') = 'string';
tMap('string') = 'string';
tMap('cellstr') = 'string';
tMap('cell') = 'union';
tMap('struct') = 'map';
tMap('timetable') = 'long';

% NOT CURRENTLY SUPPORTED
% tMap('cell') = 'null';
% tMap('table') = 'null';
% tMap('categorical') = 'null';
% tMap('inline') = 'null';
% tMap('function_handle') = 'null';
% tMap('javaArray') = 'null';
% tMap('javaMethod') = 'null';

avroStr = tMap(inputStr);


end %function
