function [cnfg,scn] = my_read_cat_log(varargin)
% READ_CAT_LOG Function to read CAT log file.
%
% Syntax
% read_ret_log
% read_ret_log(fnm)
% read_ret_log(dnm,fnm)
%
% Input
% fnm - string containing file name or complete path name
% dnm - string containing directory name
%
% Output
% cnfg - structure containing config data
% req - structure containing request data
% rng - structure containing range data
% dat - structure containing data data
% scn - structure containing scan data
%
% Usage Notes
% If no file name is provided, READ_RET_LOG opens a dialog for the user to
% select the desired file. The single input fnm can be a file name only or
% a complete path name. The two inputs dnm and fnm are combined to make a
% complete path name.
%
% See also UIGETFILE, FULLFILE.

% Copyright © 2011 Time Domain, Huntsville, AL


% Handle input arguments.
switch nargin
  case 0
    [fnm,dnm] = uigetfile('*.csv');
  case 1
    dnm = '';
    fnm = varargin{1};
  case 2
    dnm = varargin{1};
    fnm = varargin{2};
  otherwise
    error('Too many input arguments.')
end

% Open file.
fid = fopen(fullfile(dnm,fnm),'rt');

% Create empty structures to append when number of element counters exceeds
% size of structure. This process is used to allocate memory for structures
% in blocks as needed rather than adding one element at a time. Block size
% for appending to structures is hard coded. A modified version of this
% function with a larger value would be useful when reading extremely large
% files.
N = 100;

%The CNFG line needs some correction, two column headers are missing, which we will get after talking to
%Scott
cnfg_ = repmat(struct('T',[],'OpMd',[],'AntMd',[],'CdCh',[],'TrGain',[],'PwrUpMd',[],'TxNumPckts',[],'TxPcktLngthWrds',...
    [],'TxPcktDly_msec',[],'AcqIntIndx',[],'AutoThrshld',[],'ManThrshld',[],'RxFltr',[],'AcqPri_ps',[],...
    'AcqPrmblLngth_microsecs',[],'AutoInt',[],'DataIntIndx',[],'DataType',[],'PyldPri_ps',[],'PyldLngth_microsecs',[],'ScnStrt_ps',...
    [],'ScnStp_ps',[],'ScnStep_bins',[],'ScnIntIndx',[],'Flgs',[]),1,N);
fullscn_ = struct('T',[],'msgID',[],'srcID',[],'Tstmp',[],'ChRise',[],'LEWinPk',[],'LinearSnr',[],'LEindx',[],'LckSptIndx',...
    [],'ScnStrtps',[],'ScnStpps',[],'ScnStepbins',[],'Filtr',[],'AntId',[],'OpMd',[],'NumSmpls',[],'scndata',[]);

% Initialize structures and number of element counters.
Kcnfg = 0;
Kscn = 0;

cnfg = [];
scn = [];

% Read file to end.
while ~feof(fid)
  % Get next line.
  ln = fgetl(fid);
  
  % Get first two fields. Second field is the log entry type.
  i = strfind(ln,',');
  fld = textscan(ln(1:i(2)-1),'%s %s','Delimiter',',');
  
  % Switch on log entry type. In each case, the number of elements counter
  % is incremented, the structure size is increased if necessary, fields
  % are extracted, and data are put in the associated structure fields.
  switch fld{1}{1}
    case 'Timestamp'
      % These are text lines describing the fields of each of the various
      % log entries.

    otherwise
      %fprintf('%s\n',ln)
      switch fld{2}{1}
        case 'CatConfig'
        Kcnfg = Kcnfg + 1;
          if Kcnfg > length(cnfg)
            cnfg = [cnfg cnfg_];
          end
          fld = textscan(ln,'%n %s %n %n %n %n %n %n %n %n %n %n %n %n %n %n %n %n %n %n %n %n %n %n %n %n','Delimiter',',');
          cnfg(Kcnfg) = struct('T',fld{1}(1),'OpMd',fld{3}(1),'AntMd',fld{4}(1),'CdCh',fld{5}(1),'TrGain',fld{6}(1),'PwrUpMd',fld{7}(1),...
              'TxNumPckts',fld{8}(1),'TxPcktLngthWrds',fld{9}(1),'TxPcktDly_msec',fld{10}(1),'AcqIntIndx',fld{11}(1),'AutoThrshld',...
              fld{12}(1),'ManThrshld',fld{13}(1),'RxFltr',fld{14}(1),'AcqPri_ps',fld{15}(1),'AcqPrmblLngth_microsecs',fld{16}(1),'AutoInt',fld{17}(1),...
              'DataIntIndx',fld{18}(1),'DataType',fld{19}(1),'PyldPri_ps',fld{20}(1),'PyldLngth_microsecs',fld{21}(1),'ScnStrt_ps',fld{22}(1),...
              'ScnStp_ps',fld{23}(1),'ScnStep_bins',fld{24}(1),'ScnIntIndx',fld{25}(1),'Flgs',fld{26}(1));
          
%         case 'CatMsg_GetStatsExRequest'
%           Kreq = Kreq + 1;
%           if Kreq > length(req)
%             req = [req req_];
%           end
%           fld = textscan(ln,'%n %s %n %n %n %n %s','Delimiter',',');
%           if isempty(fld{7})
%             req(Kreq)= struct('T',fld{1}(1),'msgID',fld{3}(1),'respID',fld{4}(1),'AntMd',fld{5}(1),'Ndat',fld{6}(1),'dat','','stat',nan);
%           else
%             req(Kreq)= struct('T',fld{1}(1),'msgID',fld{3}(1),'respID',fld{4}(1),'AntMd',fld{5}(1),'Ndat',fld{6}(1),'dat',fld{7}(1),'stat',nan);
%           end

        case 'CatFullScanInfo'
          Kscn = Kscn + 1;
          if Kscn > length(scn)
            scn = [scn fullscn_];
          end
          i = strfind(ln,',');
          fld = textscan(ln(1:i(17)-1),'%n %s %n %n %n %n %n %n %n %n %n %n %n %n %n %n %n','Delimiter',',');
          scn(Kscn) = struct('T',fld{1}(1),'msgID',fld{3}(1),'srcID',fld{4}(1),'Tstmp',fld{5}(1),'ChRise',fld{6}(1),'LEWinPk',fld{7}(1),'LinearSnr',fld{8}(1),'LEindx',...
              fld{9}(1),'LckSptIndx',fld{10}(1),'ScnStrtps',fld{11}(1),'ScnStpps',fld{12}(1),'ScnStepbins',fld{13}(1),'Filtr',fld{14}(1),'AntId',...
              fld{15}(1),'OpMd',fld{16}(1),'NumSmpls',fld{17}(1),'scndata',[]);
          scn(Kscn).scndata = str2num(ln(i(17)+1:end));

      end
  end
end

% Close file.
fclose(fid);

% Trim structures arrays to elements actually filled.
cnfg = cnfg(1:Kcnfg);
scn = scn(1:Kscn);
fclose all;
