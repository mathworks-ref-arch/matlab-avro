classdef GenericData < handle
    %% GENERICDATA Utilities for generic Java data.
   
   % Copyright (c) 2020 MathWorks, Inc.
   
    properties(Hidden)
        jGenericData
    end
    methods
        %% Constructor
        function obj = GenericData()
            import org.apache.avro.generic.*;
        end
    end
    methods(Static)
        function obj = get()
            obj = matlabavro.GenericData();
            obj.jGenericData = javaObject('org.apache.avro.generic.GenericData');
        end
    end
end %class
