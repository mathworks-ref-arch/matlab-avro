function varargout = avrowrite(file, data, varargin)
% Write data to an Apache Avro file
%
% AVROWRITE(FILE, DATA) writes DATA to an Avro FILE
%
% WRITER = ... return the Writer object.
%
% AVROWRITE(FILE, DATA, Property, Value,...) optional Property, Value pairs
% for the Writer.
%
% Properties
%
% Valid Properties for the Writer
%
%   'Compression' - 'snappy','none','deflate'
%
%   'CompressionLevel' - a value from 1 to 9 , only applies to deflate
%
%   'AppendToFile' - true to append to existing file (logical)
%
%   'AddSyncMarker' - true to add sync markers after each record (logical)
%
% Example: Create an array and write to tmp.avro
%
%   avrowrite('tmp.avro',randn(10))
%
% See also bigdata.avro.Writer, avroread

% Copyright (c) 2017, The MathWorks, Inc.

if verLessThan('matlab','9.3') % R2017b
    error('MATLAB Release 2017b or newer is required');
end

if ~ nargin || isempty(data) || isempty(file)
    if nargout
        varargout{1} = bigdata.avro.Writer;
    end
    return
end

writer = bigdata.avro.Writer(varargin{:});
writer.FileName = file;
writer.write(data);

if nargout == 1
    varargout{1} = writer;
end
