classdef TypedAvro < matlab.unittest.TestCase
%
% Copyright (c) 2017, The MathWorks, Inc.
    
    properties(TestParameter)
        DType = { ...
            'double', ...
            'logical', ...
            'int32', ...
            'int64' ...
            }
        Compression = {...
            'snappy', ...
            'none', ...
            'deflate'            
            }
    end

    methods(TestMethodSetup)
        function addHelpers(testCase)
            import matlab.unittest.fixtures.TemporaryFolderFixture;
            import matlab.unittest.fixtures.CurrentFolderFixture;

            % Create a temporary folder and make it the current working
            % folder.
            tempFolder = testCase.applyFixture(TemporaryFolderFixture);
            testCase.applyFixture(CurrentFolderFixture(tempFolder.Folder));
        end
    end
    methods(TestMethodTeardown)
    end

    methods(Test)
        function testScalar(this, DType, Compression)
            D1 = feval(DType, 42);
            fn = 'tmp1.avro';
            avrowrite(fn, D1, 'Compression', Compression);
            D2 = avroread(fn);
            assertEqual(this, D1, D2, 'The values read should be as written.');
        end

        function testRowVector(this, DType, Compression)
            D1 = feval(DType, [1,2,3]);
            fn = 'tmp1.avro';
            avrowrite(fn, D1, 'Compression', Compression);
            D2 = avroread(fn);
            assertEqual(this, D1, D2, 'The values read should be as written.');
        end
% 
        function testColumnVector(this, DType, Compression)
            D1 = feval(DType, [1,2,3]');
            fn = 'tmp1.avro';
            avrowrite(fn, D1, 'Compression', Compression);
            D2 = avroread(fn);
            assertEqual(this, D1, D2, 'The values read should be as written.');
        end
% 
        function testMatrix(this, DType, Compression)
            D1 = feval(DType, reshape(1:10e3, 1e3, 10));
            fn = 'tmp2.avro';
            avrowrite(fn, D1, 'Compression', Compression);
            D2 = avroread(fn);
            assertEqual(this, D1, D2, 'The values read should be as written.');
        end
%   
        function testStruct(this, DType, Compression)
            D1 = getStruct(5e3, DType);
            fn = 'tmpStruct.avro';
            avrowrite(fn, D1, 'Compression', Compression);
            D2 = avroread(fn);
            assertEqual(this, D1, D2, 'The values read should be as written.');
        end

        function testTable(this, DType, Compression)
            D1 = struct2table(getStruct(6e3, DType));
            fn = 'tmpTable.avro';
            avrowrite(fn, D1, 'Compression', Compression);
            D2 = avroread(fn);
            assertEqual(this, D1, D2, 'The values read should be as written.');
        end

        function testTimeTable(this, DType, Compression)
            D1 = getTimeTable(10e3, DType);
            fn = 'tmpTable.avro';
            avrowrite(fn, D1, 'Compression', Compression);
            D2 = avroread(fn);
            assertEqual(this, D1, D2, 'The values read should be as written.');
        end

        function testMixedTimeTable(this, Compression)
            D1 = getTimeTable(10e3, 'double');
            D1.Cos = single(D1.Cos);
            D1.R = int32(D1.R);
            fn = 'tmpTable.avro';
            avrowrite(fn, D1, 'Compression', Compression);
            D2 = avroread(fn);
            assertEqual(this, D1, D2, 'The values read should be as written.');
        end

    end
end

function S = getTimeTable(N, DType)
    t0 = datetime('2016-06-01 08:23:55');
    secVec = (0:(N-1))';
    Time = t0 + seconds(secVec);
    x = linspace(0,10,N+1)';
    x(end) = [];
    Sin = feval(DType, sin(x));
    Cos = feval(DType, cos(x));
    R = (rand(size(Sin))-.5)*2000;
    S = timetable(Time, Sin, Cos, R);
end

function S = getStruct(N, DType)
    x = linspace(0,10,N+1)';
    x(end) = [];
    S = struct('Time', feval(DType, x), ...
        'Sin', feval(DType, sin(x)), ...
        'Cos', feval(DType, cos(x)));
end
