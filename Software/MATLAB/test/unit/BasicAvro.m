classdef BasicAvro < matlab.unittest.TestCase
%
% Copyright (c) 2017, The MathWorks, Inc.

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
        function testScalar(this)
            D1 = 42;
            fn = 'tmp1.avro';
            avrowrite(fn, D1);
            D2 = avroread(fn);
            assertEqual(this, D1, D2, 'The values read should be as written.');
        end

        function testRowVector(this)
            D1 = [1,2,3];
            fn = 'tmp1.avro';
            avrowrite(fn, D1);
            D2 = avroread(fn);
            assertEqual(this, D1, D2, 'The values read should be as written.');
        end

        function testColumnVector(this)
            D1.x = linspace(0,6)';
            D1.y = sin(D1.x);
            fn = 'tmp1.avro';
            avrowrite(fn, D1);
            D2 = avroread(fn);
            assertEqual(this, D1, D2, 'The values read should be as written.');
        end
        
        function testLinearSpacedVector(this)
            D1 = [1,2,3]';
            fn = 'tmp1.avro';
            avrowrite(fn, D1);
            D2 = avroread(fn);
            assertEqual(this, D1, D2, 'The values read should be as written.');
        end

        function testMatrix(this)
            D1 = reshape(1:10e3, 1e3, 10);
            fn = 'tmp1.avro';
            avrowrite(fn, D1);
            D2 = avroread(fn);
            assertEqual(this, D1, D2, 'The values read should be as written.');
        end

        function testStruct(this)
            D1 = getStruct(5e3);
            fn = 'tmpStruct.avro';
            avrowrite(fn, D1);
            D2 = avroread(fn);
            assertEqual(this, D1, D2, 'The values read should be as written.');
        end

        function testTable(this)
            D1 = struct2table(getStruct(6e3));
            fn = 'tmpTable.avro';
            avrowrite(fn, D1);
            D2 = avroread(fn);
            assertEqual(this, D1, D2, 'The values read should be as written.');
        end

    end
end

function S = getStruct(N)
    x = linspace(0,10,N+1)';
    x(end) = [];
    S = struct('Time', x, ...
        'Sin', sin(x), ...
        'Cos', cos(x));
end
