% Author: Dr Adam S Wyatt
classdef (Abstract, HandleCompatible) Object
 
 
 %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
 % P R O P E R T I E S (Hidden)
 %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
 
 properties (Hidden)
  IsDeployed;
 end % properties (Hidden)
 
 
 
 %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
 % M E T H O D S
 %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

 methods
  
  % ====================================================================
  
  % Class constructor
  %  Input arguments define a list of propery name/value pairs which
  %  are stored in the properties array
  function obj = Object(varargin)
   obj.IsDeployed = isdeployed;
  end
   
  % ====================================================================

 end % methods
 
 
 %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
 % M E T H O D S   (STATIC)
 %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

 methods (Static)
  
  % ====================================================================

  % More reliable implementation of pause
  % java pause is apparently better and requires a value in ms
  %
  % Note:
  %  When using this function, it is not possible to interrupt 
  %  previously executed callacks for example.
  function Pause(val_in_seconds)
   java.lang.Thread.sleep(val_in_seconds*1000);
  end

  % ====================================================================

  % Check inputs
  %  Ensures inputs form a set of property name/value pairs
  function VarChck(var)
   pn = var(1:2:end-1);
   if mod(numel(var), 2)
    throwAsCaller(...
     MException( 'uiobjects:InvalidArgumentListLength', ...
     'Invalid argument list: must be PropName, PropVal pairs' ))
   elseif ~all( cellfun( @ischar, pn ) )
    throwAsCaller(...
     MException('uiobjects:InvalidArgument', ...
     'Invalid argument in list'))
   elseif any(arrayfun(@(n) any(strcmpi(pn(n), pn(n+1:end))), ...
     1:numel(pn)-1))
    throwAsCaller(MException('uiobjects:DuplicateArguments', ...
     'Duplicate property names in argument list'));
   end   
  end % VarChk
  
  % ====================================================================

  % Return property values and property pairs with found pairs removed
  function [PropPairs, varargout] = FindVal(PropPairs, varargin)
   if nargout<2
    varargout = {};
   else
    varargout = cell(nargout-1, 1);
   end

   while ~isempty(PropPairs) && length(PropPairs)<=1 && iscell(PropPairs{1})
    PropPairs = PropPairs{:};
   end

   % Check for empty inputs
   if isempty(PropPairs) || isempty(varargin)
    return;
   end

   uiobjects.Object.VarChck(PropPairs);

   %  Loop over property names to search for
   for ni = 1:nargout-1
    % Loop over property names to search from
    for np = 1:2:length(PropPairs)

     % Save some typing
     p = PropPairs{np};
     v = varargin{ni};

     % Check if start of property names are the same
     if strncmpi(v, p, min(length(v), length(p)))
      % Extract property value
      varargout(ni) = PropPairs(np+1); %#ok<AGROW>

      % Remove property pair from list
      PropPairs(np:np+1) = [];

      % Go to next search for item
      break;
     end % if strncmpi( ...
    end % for np = ...
   end % for ni = ...
  end % function ...
  
  % ====================================================================

  % Return property value from list (no pair removal)
  function PropVal = FindArg(PropPairs, PropName, DefaultValue)
   [~, PropVal] = uiobjects.Object.FindVal(PropPairs, PropName);

   if isempty(PropVal) && exist('DefaultValue', 'var')
    PropVal = DefaultValue;
   end
  end
  
  % ====================================================================

  function [pth, file] = GetClassFolder(ClassName)
   % No input string - create default config file
   STFull = dbstack('-completenames');
   STFile = dbstack;
   
   if exist('ClassName', 'var') && ~isempty(ClassName)
    ind = ExtractStrings({STFull.name}.', ClassName);
   else
    ind = length(STFull);
   end

   pth = regexp(STFull(ind).file, '^.*\\', 'match', 'once');
   file = STFile(ind).file;
  end
  
  % ====================================================================
  
  function match = Compare(str1, str2)

   if nargin>2 && match_case
    fun = @strncmp;
   else
    fun = @strncmp;
   end

   if ismatrix(str1) && ~isvector(str1)
    str1 = mat2cell(str1, ones(size(str1, 1), 1), size(str1, 2));
   end

   if ismatrix(str2) && ~isvector(str2)
    str2 = mat2cell(str2, ones(size(str2, 1), 1), size(str2, 2));
   end

   if iscell(str1)
    match = cell2mat(cellfun(@(str) Compare(str, str2), str1, ...
     'UniformOutput', false));
   elseif iscell(str2)
    match = cell2mat(cellfun(@(str) Compare(str1, str), str2, ...
     'UniformOutput', false));
   else
    match = fun(str1, str2, min(length(str1), length(str2)));
   end % if ...
  end % function ...
  
  % ====================================================================
  
  function val = Round(val, sig)
   sgn = sign(val);
   n = log10(abs(val));
   m = log10(abs(1./val));
   ind0 = (val==0);
   ind1 = (n>0);

   s = floor(n.*ind1 - m.*~(ind1));
   fact = 10.^(sig - s - 1);
   val = sgn.*round(val.*fact)./fact;
   val(ind0) = 0;
  end

 end % methods (Static)
  
end % classdef