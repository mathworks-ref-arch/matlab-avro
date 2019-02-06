classdef LogicalAvro < matlab.unittest.TestCase
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
        function testScalarTrue(this)
            D1 = true;
            fn = 'tmp1.avro';
            avrowrite(fn, D1);
            D2 = avroread(fn);
            assertEqual(this, D1, D2, 'The values read should be as written.');
        end

        function testScalarFalse(this)
            D1 = false;
            fn = 'tmp1.avro';
            avrowrite(fn, D1);
            D2 = avroread(fn);
            assertEqual(this, D1, D2, 'The values read should be as written.');
        end

        function testRowVector(this)
            D1 = logical([0,1,1,0,1,3,99,0]);
            fn = 'tmp1.avro';
            avrowrite(fn, D1);
            D2 = avroread(fn);
            assertEqual(this, D1, D2, 'The values read should be as written.');
        end

        function testColumnVector(this)
            D1 = logical([0,1,1,0,1,3,99,0])';
            fn = 'tmp1.avro';
            avrowrite(fn, D1);
            D2 = avroread(fn);
            assertEqual(this, D1, D2, 'The values read should be as written.');
        end

        function testMatrix(this)
            D1 = reshape(mod(1:10e3,11)==0, 1e3, 10);
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
    x = (1:N)';
    x(end) = [];
    S = struct('Time', x, ...
        'Sin', mod(x,3)==0, ...
        'Cos', mod(x,7)==0);
end
