classdef HDFSAvro < matlab.unittest.TestCase
    %
    % Copyright (c) 2019, The MathWorks, Inc.
  
    properties
        % Change the hdfsURL value to correct location before running this test.
        hdfsURL = "hdfs://172.30.123.23:54310/user/vveerapp/";
        hdfsFileName = "tmpTable.avro";
    end
    
    methods(TestMethodSetup)
    end
    
    methods(TestMethodTeardown)    
    end
    
    methods ( Test )
        function testArrayWithinTable(this)            
                D1 = table( [1;2], {rand(10,1);rand(5,1)} );
                fn = this.hdfsURL + this.hdfsFileName;
                avrowrite(fn, D1);
                D2 = avroread(fn);               
                assertEqual(this, D1, D2, 'The values read should be as written.');            
        end
    end
    
end