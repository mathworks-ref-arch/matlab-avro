classdef testDynamicSchema_Enum < matlab.unittest.TestCase
    %
    % Copyright (c) 2020, The MathWorks, Inc.
    properties
        schema
        dfr
        dfw
        fn = 'test.avro'
    end
    properties(TestParameter)
        DType = { ...
            'double', ...
            'logical', ...
            'int32', ...
            'int64' ...
            }
        Compression = {...
            matlabavro.CompressionType.SNAPPY, ...
            matlabavro.CompressionType.BZIP2, ...
            matlabavro.CompressionType.NULL, ...
            matlabavro.CompressionType.DEFLATE
            }
    end
    properties(MethodSetupParameter)
        %          Compression = {...
        %             'snappy', ...
        %             'none', ...
        %             'deflate'
        %             };
    end
    methods(TestMethodSetup)
        function addHelpers(testCase)
            import matlab.unittest.fixtures.TemporaryFolderFixture;
            import matlab.unittest.fixtures.CurrentFolderFixture;
            
            % Create a temporary folder and make it the current working
            % folder.
            tempFolder = testCase.applyFixture(TemporaryFolderFixture);
            testCase.applyFixture(CurrentFolderFixture(tempFolder.Folder));
            testCase.schema = matlabavro.Schema();
            testCase.dfw = matlabavro.DataFileWriter();
        end
    end
    methods(TestMethodTeardown)
        function closeAvroHandles(testCase)
            testCase.dfw.close();
            testCase.dfr.close();
        end
    end
    
    methods(Test)
       
        function testEnumeration(testCase,Compression)                         
            D1 = Weekdays.Friday;
            tmpSchema = matlabavro.Schema.createSchemaForData(D1);
            testCase.dfw.compressionType = Compression;
            testCase.dfw.createAvroFile(tmpSchema,testCase.fn);
            testCase.dfw.append(D1);
            testCase.dfr = matlabavro.DataFileReader(testCase.fn);
            D2 = testCase.dfr.next();
            testCase.verifyEqual(string(D1), string(D2), 'The values read should be as written.');
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
function S = getStructName(N)
x = linspace(0,10,N+1)';
x(end) = [];
xs = arrayfun(@(x) string(sprintf('Name_%05d', x)), (1:N)');
S = struct('Time', x, ...
    'Sin', sin(x), ...
    'Cos', cos(x), ...
    'Name', {xs});
end
function S = getStructTyped(N, DType)
x = linspace(0,10,N+1)';
x(end) = [];
S = struct('Time', feval(DType, x), ...
    'Sin', feval(DType, sin(x)), ...
    'Cos', feval(DType, cos(x)));
end

