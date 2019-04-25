classdef ParPoolAvro < matlab.unittest.TestCase
%
% Copyright (c) 2017, The MathWorks, Inc.
    properties
        pathToAvroPackage
    end
    methods(TestMethodSetup)        
        function addHelpers(testCase)
            import matlab.unittest.fixtures.TemporaryFolderFixture;
            import matlab.unittest.fixtures.CurrentFolderFixture;
            %Set path to Avropackage for parallel workers.
            currentFilePath = fileparts(fileparts(mfilename('fullpath')));
            testCase.pathToAvroPackage = fullfile(fileparts(currentFilePath),'lib','jar','matlab-avro-sdk-0.2.jar')
            % Create a temporary folder and make it the current working
            % folder.
            tempFolder = testCase.applyFixture(TemporaryFolderFixture);
            testCase.applyFixture(CurrentFolderFixture(tempFolder.Folder));

        end
    end
    methods(TestMethodTeardown)
         %delete(gcp('nocreate'))
    end

    methods(Test)

        function meanParallelTall(this)
            %Check if PCT licensed and installed, otherwise skip test.
            if(license('checkout','Distrib_Computing_Toolbox') ==1)
                S = ver('distcomp');
                if(~isempty(S))                
                    N = 20;
                    %Set the path for avro package for each parallel worker.
                    spmd                
                        javaaddpath(this.pathToAvroPackage);                
                    end            
                    parfor k=1:N
                        fn = sprintf('tmp%02d.avro', k);                
                        avrowrite(fn, randn(1e6,2));
                    end         
                else
                    disp('Parallel Computing Toolbox not installed. Test not run.');
                end
            else
                disp('Could not verify Parallel Computing Toolbox license. Test not run.');
            end                
        end
    end
end
