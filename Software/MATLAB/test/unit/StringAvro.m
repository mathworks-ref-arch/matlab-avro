classdef StringAvro < matlab.unittest.TestCase
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
        function simpleStringStruct(this)
            D1 = getStruct(500);
            fn = 'tmpStruct.avro';
            avrowrite(fn, D1);
            D2 = avroread(fn);
            assertEqual(this, D1, D2, 'The values read should be as written.');
        end

        function testTable(this)
            D1 = struct2table(getStruct(500));
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
    xs = arrayfun(@(x) string(sprintf('Name_%05d', x)), (1:N)');
    S = struct('Time', x, ...
        'Sin', sin(x), ...
        'Cos', cos(x), ...
        'Name', {xs});
end

