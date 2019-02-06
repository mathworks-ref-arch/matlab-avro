function varargout = avroread(file,varargin)
% Read an Apache Avro file
%
% DATA = AVROREAD(FILE) Read the Avro FILE and return DATA.
%
% [DATA, READER] = ... second output returns the Reader class.
%
% DATA = AVROREAD(FILE, Property, Value,...) optional Property, Value pairs
% for the READER.
%
% Properties
%
% Valid Properties for the Reader
%
%   'SeekPosition'  - position at which to open or seek or sync
%       to a file. <  0 are ignored and file will not seek (double)
%
%   'NumRecords'    -  number of records to return, Inf is the default
%       value and will read all records (double)
%
%   'UseSyncToSeek' - If the sync marker positions are known, set this to
%       false, otherwise true.
%
% Example: Read in an Avro file and return the reader object as well
%
%   [data, reader] = avroread('tmp.avro');
%
% Example: Return just the Reader object
%
%   reader = avroread;
%
% See also bigdata.avro.Reader, avrowrite

% Copyright (c) 2017, The MathWorks, Inc.

if verLessThan('matlab','9.3') % R2017b
    error('MATLAB Release 2017b or newer is required');
end

if ~ nargin || isempty(file)
    if nargout == 1
        varargout{1} = bigdata.avro.Reader;
    end
    return
end

% Check if file exists
if isempty(dir(file))
    error(['avroread:FileNotFound ', file])
end

reader = bigdata.avro.Reader('FileName', file, varargin{:});

if nargout >= 1
    varargout{1} = reader.read;
end
if nargout == 2
    varargout{2} = reader;
end
