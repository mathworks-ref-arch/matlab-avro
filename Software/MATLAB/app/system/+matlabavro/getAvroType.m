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
%      'logical'    'boolean' 
%      'struct'     'map' 
%      'single'     'float' 
%      'int8'       'byte' 
%      'uint8'      'byte' 
%      'uint16'     'int' 
%      'uint32'     'int' 
%      'uint64'     'long' 
%      'char'       'string'
%      'timetable'  'long'
%  Everything else is unsupported
% Define the mapping here - please see >> help datatype

% (c) 2020 MathWorks, Inc.

tMap = containers.Map();
tMap('double') = 'double';
tMap('logical') = 'boolean';
tMap('struct') = 'map';
tMap('single') = 'float';
tMap('uint8') = 'bytes';
tMap('uint16') = 'int';
tMap('uint32') = 'int';
tMap('int8') = 'bytes';
tMap('int32') = 'int';
tMap('int64') = 'long';
tMap('uint64') = 'long';
tMap('char') = 'string';
tMap('string') = 'string';
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