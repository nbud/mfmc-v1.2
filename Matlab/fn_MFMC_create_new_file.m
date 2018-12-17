function success = fn_MFMC_create_new_file(fname, template_fname)
%SUMMARY
%   Creates a new MFMC file with nothing in it except a VERSION and
%   TEMPLATE_FILENAME attributes in its root using the specified template
%   file. Also primes the fn_MFMC_utilities function with the necessary
%   template. This function must be called before writing probes, sequences
%   or MFMC frames to a file.
%AUTHOR
%   Paul Wilcox, November 2018
%INPUTS
%   fname - name of MFMC file to create
%   template_fname - name of template filename to use
%OUTPUTS
%   sequence - structured variable containing all the information about
%   specified sequence except the data itself. If no sequence_index was
%   specified, then this will be an array, sequence(1...N_M), containing
%   the information for all sequences in the file
%--------------------------------------------------------------------------

global template_path

success = 0;

%Load template
try
    template = jsondecode(fileread([template_path, filesep, template_fname]));
catch
    fprintf('Failed to read template file.\n');
    return
end

%Prime utilities function
fn_MFMC_utilities([], [], [], template);

%Create the file
try
    fid = H5F.create(fname, 'H5F_ACC_TRUNC', 'H5P_DEFAULT', 'H5P_DEFAULT');
    H5F.close(fid);
catch ME
    % XXX - Plan A: wrap the base exception into another exception
%     msgID = 'MFMC:CreateFileError';
%     msg = 'Failed to create MFMC file.';
%     myException = MException(msgID, msg);
%     myException = addCause(myException, ME);
%     throw(myException);
    
    % XXX - Plan B: print our message and rethrow exception
    fprintf('Failed to create MFMC file.\n');
    rethrow(ME)
end

%Write the version and template_filename attributes to file
root_data.version = template.version;
[~, t, e] = fileparts(template_fname);
root_data.template_filename = [t, e];
% root_data.template_filename = template_fname;
success = fn_MFMC_add_from_matlab_according_to_template(fname, root_data, '');
end

