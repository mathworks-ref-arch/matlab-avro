classdef (Abstract = true) Core < handle
    % Core class from which other classes in this project can inherit
    %
    % This provides useful re-useable methods for classes, thus minimizing
    % the amount of boilerplate level code each class needs.
    %
    % - locating the resource and root source path for a project
    % - adding and removing dynamic jars
    % - constructor method for parsing inputs and setting up loggers
    % - parsing of property/value pairs for constructors
    % - adding PostSet listeners for properties
    % - passing on property changes to equivalent Java setter methods
    
    % Copyright (c) 2017, The MathWorks, Inc.
    
    properties(Hidden)
        % Indicate whether to display JAR loaded messages
        ShowJarLoadedMsg = false;
    end
    
    methods
        function [res,srcroot] = getResourcesFolder(obj,varargin)
            % Get the path to the resources folder
            %
            % RES = GETRESOURCESFOLDER(VARARGIN) Returns the fullfile path
            % using the inputs as path components
            %
            % [RES,SRCROOT] = GETRESOURCESFOLDER(...)
            %
            % SRCROOT Returns the root matlab source folder which is:
            %
            % ..\main\matlab for classes under main
            % ..\test\matlab for classes under test
            %
            % GETRESOURCESFOLDER
            
            mclass   = metaclass(obj);
            fullpath = which(mclass.Name);
            
            % Folder for current class including up to the root package
            srcroot = [filesep,'+',regexprep(mclass.Name,'\.',['\',filesep,'+'])];
            ind = strfind(srcroot,'+');
            srcroot(ind(end)) = [];
            
            src      = strfind(fullpath,srcroot);
            srcroot  = fullpath(1 : src - 1);
            res      = fullfile(srcroot,'lib');
            if nargin > 1
                res = fullfile(res,varargin{:});
            end
        end
        
        function out = getSourceFolder(obj,varargin)
            % Return the Source folder path
            %
            % Optional arguments create fullpath with respect to source
            % folder.
            %
            % Example: Return the full path to Source\Java\target\*.jar
            %
            %    obj.getSourceFolder('Java','target','myjar.jar')
            %
            %    PROJECT_ROOT\Software\Source\Java\target\myjar.jar
            %
            % GETSOURCEFOLDER
            
            out = fullfile(fileparts(fileparts(fileparts(...
                obj.getResourcesFolder))),varargin{:});
        end
        
        function addJars(obj, varargin)
            % Dynamically add JAR's from the lib/jar folder
            %
            % ADDJARS
            
            if nargin == 1
                % Find all the JAR's in the resources folder recursively
                d = dir(obj.getResourcesFolder('jar','**/*.jar'));
                if isempty(d)
                    fprintf('%s\n\n','No jars to add to dynamic classpath')
                    return
                end
                
                s = cellstr(javaclasspath('-all'));
                arrayfun(@(x) addNewJar(fullfile(x.folder,x.name)),d)
            else
                s = '';
                arrayfun(@(x) addNewJar(x),varargin(1))
            end
            
            function addNewJar(f)
                % Only add JAR if not on dynamic classpath
                if ~ any(strcmp(f,s))
                    if obj.ShowJarLoadedMsg
                        fprintf('%s\n%s\n','Adding to dynamic javaclasspath:',f)
                    end
                    javaaddpath(f)
                elseif obj.ShowJarLoadedMsg
                    fprintf('%s\n%s\n','Already on dynamic javaclasspath:',f)
                end
            end
        end
        
        function clearJars(obj)
            % Clear dynamic JAR's from the resourcs/jar folder
            %
            % CLEARJARS
            
            s = cellstr(javaclasspath('-dynamic'));
            d = dir(obj.getResourcesFolder('jar','*.jar'));
            arrayfun(@(x) removeJar(fullfile(x.folder,x.name)),d)
            
            function removeJar(f)
                if any(strcmp(f,s))
                    fprintf('%s\n%s\n','Removing from dynamic javaclasspath:',f)
                    javarmpath(f)
                end
            end
        end
        
        function setter(obj,src,~,jObj)
            % Callback for property PostSet listener
            %
            % SETTER
            
            if ~ isempty(jObj)
                try
                    % Try setter method on java object
                    v = obj.(src.Name);
                    if isenum(v)
                        % NOTE The enum type should be cast to a type that Java
                        % will understand. In most cases enum values are chars
                        % but in case they have been subclassed from a numeric or
                        % logical, then do not cast to a char.
                        
                        % Cast enums to char if not logical or numeric
                        if ~ islogical(v) && ~ isnumeric(v)
                            v = char(v);
                        elseif islogical(v)
                            v = logical(v);
                        elseif isnumeric(v)
                            % TODO ensure this is the correct numeric type
                            % No enums inherited from numeric
                            % types
                            v = double(v);
                        end
                    end
                    jObj.(['set',src.Name])(v);
                catch ME %#ok<NASGU>
                    % Ignore the warning, method does not exist
                end
            end
        end
        
        function parseInputs(obj,varargin)
            % Parse property values as property/value pairs
            %
            % Any valid Java setters are applied automatically
            %
            % PARSEINPUTS
            
            for j = 1 : 2 : length(varargin)
                obj.(varargin{j}) = varargin{j + 1};
            end
        end
        
        function addListeners(obj,jObj)
            % Add our PostSet listeners for properties
            %
            % ADDLISTENERS
            
            mco = metaclass(obj);
            p = {mco.PropertyList.Name};
            p = p([mco.PropertyList.SetObservable]);
            cellfun(@(x) addlistener(obj,x,'PostSet',...
                @(src,evt)obj.setter(src,evt,jObj)), p);
        end
        
        function construct(obj,varargin)
            % Construct the object using default initialization steps
            %
            % CONSTRUCT
            
            if isprop(obj,'JavaHnd')
                obj.addListeners(obj.JavaHnd)
            end
            obj.parseInputs(varargin{:})
            if isprop(obj,'JavaHnd')
                logfile = obj.getResourcesFolder('jar','log4j.properties');
                try
                    obj.JavaHnd.initLogger(logfile)
                catch
                end
            end
        end
    end
end
