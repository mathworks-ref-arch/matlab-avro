function startup(varargin)
%% STARTUP Script to add my paths to MATLAB path
% This script will add the paths below the root directory into the MATLAB
% path. It will omit the SVN and other crud.  Modify undesired path
% filter as desired.

% Copyright (c) 2017-2022, The MathWorks, Inc.

appStr = 'MATLAB Interface for Apache Avro';
avrofName = 'matlabavro-0.4.jar';
disp(appStr);
disp(repmat('-',1,numel(appStr)));

%% Set up the paths to add to the MATLAB path
% This should be the only section of the code that requires modification
% The second argument specifies whether the given directory should be
% scanned recursively
here = fileparts(mfilename('fullpath'));

% Add the appropriate architecture binaries
archDir = iGetArchSuffix(); %#ok<NASGU>

% rootDirs={fullfile(here,'app'),true;...
%     fullfile(here,'lib'),false;...    
%     };

%% Add the framework to the path
%iAddFilteredFolders(rootDirs);

%% Handle the modules for the project.
disp('Initializing all modules');
modRoot = fullfile(here,'sys','modules');

% Get a list of all modules
mList = dir(fullfile(modRoot,'*.'));
for mCount = 1:numel(mList)
	% Only add proper folders
	dName = mList(mCount).name;
	if ~strcmpi(dName(1),'.')
		% Valid Module name
		candidateStartup = fullfile(modRoot,dName,'startup.m');
		if exist(candidateStartup,'file')
			% Run the module with a startup
			run(candidateStartup);
		else
			% Create a cell and add it recursively to the path
			iAddFilteredFolders({fullfile(modRoot,dName), true});
		end
	end

end

%% Post path-setup operations
disp('Running post setup operations');

% Check and warn if it cannot find the JAR file
jarFile = fullfile(here,'lib','jar',avrofName);
%appPath = fullfile(here,'@Avro');
appPath = fullfile(here,'app','system');

if ~exist(jarFile,'file')
    % The JAR file needs to be built
    warning('matlabavro:startup:missingJavaLibrary', ...
        'Could not locate the JAR file. Please rebuild the JAR file using Maven');
end

% Static path
staticPaths = javaclasspath('-static');
if ~any(strcmpi(staticPaths, jarFile))
    % Could not locate the JAR file on the static path
    fprintf('Java class path added for %s \n',avrofName);    
    addpath(appPath);
    javaaddpath(jarFile);
end

end

%% iAddFilteredFolders Helper function to add all folders to the path
function iAddFilteredFolders(rootDirs)
% Loop through the paths and add the necessary subfolders to the MATLAB path
for pCount = 1:size(rootDirs,1)

	rootDir=rootDirs{pCount,1};
    if rootDirs{pCount,2}
        % recursively add all paths
        rawPath=genpath(rootDir);

		if ~isempty(rawPath)
			rawPathCell=textscan(rawPath,'%s','delimiter',pathsep);
		    rawPathCell=rawPathCell{1};
		end

    else
        % Add only that particular directory
        rawPath = rootDir;
        rawPathCell = {rawPath};
    end

	% remove undesired paths
	svnFilteredPath=strfind(rawPathCell,'.svn');
	gitFilteredPath=strfind(rawPathCell,'.git');
	slprjFilteredPath=strfind(rawPathCell,'slprj');
	sfprjFilteredPath=strfind(rawPathCell,'sfprj');
	rtwFilteredPath=strfind(rawPathCell,'_ert_rtw');

	% loop through path and remove all the .svn entries
	if ~isempty(svnFilteredPath)
		for pCount=1:length(svnFilteredPath) %#ok<FXSET>
			filterCheck=[svnFilteredPath{pCount},...
				gitFilteredPath{pCount},...
				slprjFilteredPath{pCount},...
				sfprjFilteredPath{pCount},...
				rtwFilteredPath{pCount}];
			if isempty(filterCheck)
				iSafeAddToPath(rawPathCell{pCount});
			else
				% ignore
			end
		end
	else
		iSafeAddToPath(rawPathCell{pCount});
	end

end

end

%% Helper function to add to MATLAB path.
function iSafeAddToPath(pathStr)

% Add to path if the file exists
if exist(pathStr,'dir')
	disp(['Adding ',pathStr]);
	addpath(pathStr); 
else
	disp(['Skipping ',pathStr]);
end

end


%% Helper function to add arch specific suffix
function binDirName = iGetArchSuffix()

switch computer
	case 'PCWIN'
		binDirName = 'win32';
	case 'PCWIN64'
		binDirName = 'win64';
	case 'GLNX86'
		binDirName = 'glnx86';
    case 'GLNXA64'
        binDirName = 'glnxa64';
    case 'MACI64'
		binDirName = 'maci64';
	otherwise
		error('matlabavro:startup:unsupportedPlatform', ...
            'The framework is not supported on this platform');
end
end
