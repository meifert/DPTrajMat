function mypathset(fname,fcn)
%
% function mypathset(fname,fcn)
% 
% This function includes (or removes) the named folder 
% and its subdirectories in the matlab path. The folder is 
% specified in fname and fcn is 'add' or 'rm' to add or remove
% the folder and subdirectories from the path.
%
% Example mypathset('c:\My Documents\mymatlab','add') 
% This command adds the folder c:\My Documents\mymatlab and all
% of its subdirectories to matlab path. The command
% mypathset('c:\My Documents\mymatlab','rm') removes the
% folder c:\My Documents\mymatlab and all of its
% subdirectories from the matlab path. 
% 
% Edit log started May 1 by Michael Burke

if strcmp(fcn,'add'),
   addpath(fname);
elseif strcmp(fcn,'rm'),
   rmpath(fname);
else
   return
end

   
dname = dir(fname);
for i = length(dname):-1:1,
   if ~((dname(i).isdir == 0) | strcmp('.',dname(i).name) | strcmp('..',dname(i).name) | strcmp('sfprj',dname(i).name)),
      padd=strcat(fname,filesep,dname(i).name);
      mypathset(padd,fcn);
   end
end

      
   
