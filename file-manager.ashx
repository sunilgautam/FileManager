<%@ WebHandler Language="C#" Class="file_manager" %>

using System;
using System.Web;
using System.Collections.Generic;
using System.IO;
using FileBrowser;

public class file_manager : IHttpHandler
{
    Dictionary<string, string[]> file_extensions = new Dictionary<string, string[]>()
    {
        {"all", new string[] { "*.*" }},
        {"image", new string[] { "*.jpg", "*.jpeg", "*.png", "*.gif", "*.bmp" }},
        {"docs", new string[] { "*.pdf", "*.doc", "*.docx" }},
        {"spearsheet", new string[] { "*.xls", "*.xlsx" }},
        {"text", new string[] { "*.txt", "*.rtf" }},
        {"structured", new string[] { "*.xml", "*.json" }}
    };
    string[] global_exclude_files = new string[]
                                 {
                                     "thumbs.db"
                                 };
    string[] exclude_rule_files = new string[]
                                 {
                                    
                                 };
    string[] exclude_rule_folder = new string[] 
                                 {
                                    
                                 };
    
    public void ProcessRequest(HttpContext context)
    {
        FBResponse jsonResponse = new FBResponse();

        string type, action, path, filter, search, new_name, new_folder_Name;

        type = (context.Request.Params["type"] == null) ? "all" : context.Request.Params["type"];
        action = (context.Request.Params["action"] == null) ? "browse" : context.Request.Params["action"];
        path = (context.Request.Params["path"] == null) ? "/" : context.Request.Params["path"];
        filter = (context.Request.Params["filter"] == null || context.Request.Params["filter"] == "") ? null : context.Request.Params["filter"];
        search = context.Request.Params["q"];
        new_name = (context.Request.Params["new_name"] == null) ? "" : context.Request.Params["new_name"];
        new_folder_Name = (context.Request.Params["new_folder_Name"] == null) ? "" : context.Request.Params["new_folder_Name"];
        
        string system_abs_path = GetSystemAbsPath(path);
        string relative_path = GetRelativePath(path);

        if (action == "browse")
        {
            DoBrowse(jsonResponse, type, filter, search, system_abs_path, relative_path);
        }
        else if (action == "rename" && context.Request.HttpMethod == "POST")
        {
            string system_abs_new_path = GetSystemAbsPath(new_name);
            string relative_new_path = GetRelativePath(new_name);
            DoRename(jsonResponse, system_abs_path, relative_path, system_abs_new_path, relative_new_path);
        }
        else if (action == "delete" && context.Request.HttpMethod == "POST")
        {
            DoDelete(jsonResponse, system_abs_path, relative_path);
        }
        else if (action == "create_folder" && context.Request.HttpMethod == "POST")
        {
            string system_abs_new_folder_path = GetSystemAbsPath(new_folder_Name);
            string relative_new_folder_path = GetRelativePath(new_folder_Name);
            DoCreate(jsonResponse, system_abs_new_folder_path, relative_new_folder_path);
        }
        else if (action == "search")
        {

        }
        else
        {
            InvalidRequest(jsonResponse);
        }

        SendResponse(context, jsonResponse);
    }
    
    /*************************************************************************************/

    private void DoCreate(FBResponse response, string system_abs_path, string relative_path)
    {
        string target_path = system_abs_path;

        try
        {
            if (Directory.Exists(target_path))
            {
                response.error = "Directory with same name already exists";
            }
            else
            {
                Directory.CreateDirectory(target_path);
            }
        }
        catch (DirectoryNotFoundException dir_not_found)
        {
            response.error = "Specified directory not found";
        }
        catch (FileNotFoundException file_not_found)
        {
            response.error = "Specified file not found";
        }
        catch (UnauthorizedAccessException ua_ex)
        {
            response.error = "The directory contains a read-only file";
        }
        catch (IOException io_ex)
        {
            response.error = "File system error occurred";
        }
        catch (System.Security.SecurityException sec_ex)
        {
            response.error = "Does not have the required permission";
        }
        catch (Exception ex)
        {
            response.error = "Error occurred while fetching directory information";
        }
    }

    private void DoRename(FBResponse response, string system_abs_path, string relative_path, string system_abs_new_path, string relative_new_path)
    {
        string target_path = system_abs_path;
        string target_new_path = system_abs_new_path;

        try
        {
            FileAttributes attr = File.GetAttributes(target_path);
            if ((attr & FileAttributes.Directory) == FileAttributes.Directory)
            {
                // Its a directory
                DirectoryInfo d = new DirectoryInfo(target_path);
                if (Directory.Exists(target_new_path))
                {
                    response.error = "Directory with same name already exists";
                }
                else
                {
                    d.MoveTo(target_new_path);
                }
            }
            else
            {
                // Its a file
                FileInfo f = new FileInfo(target_path);
                if (File.Exists(target_new_path))
                {
                    response.error = "File with same name already exists";
                }
                else
                {
                    f.MoveTo(target_new_path);
                }
            }
        }
        catch (DirectoryNotFoundException dir_not_found)
        {
            response.error = "Specified directory not found";
        }
        catch (FileNotFoundException file_not_found)
        {
            response.error = "Specified file not found";
        }
        catch (UnauthorizedAccessException ua_ex)
        {
            response.error = "The directory contains a read-only file";
        }
        catch (IOException io_ex)
        {
            response.error = "File system error occurred";
        }
        catch (System.Security.SecurityException sec_ex)
        {
            response.error = "Does not have the required permission";
        }
        catch (Exception ex)
        {
            response.error = "Error occurred while fetching directory information";
        }
    }

    private void DoDelete(FBResponse response, string system_abs_path, string relative_path)
    {
        string target_path = system_abs_path;

        try
        {
            FileAttributes attr = File.GetAttributes(target_path);
            if ((attr & FileAttributes.Directory) == FileAttributes.Directory)
            {
                // Its a directory
                DirectoryInfo d = new DirectoryInfo(target_path);
                d.Delete(true);
            }
            else
            {
                // Its a file
                FileInfo f = new FileInfo(target_path);
                f.Delete();
            }
        }
        catch (DirectoryNotFoundException dir_not_found)
        {
            response.error = "Specified directory not found";
        }
        catch (FileNotFoundException file_not_found)
        {
            response.error = "Specified file not found";
        }
        catch (UnauthorizedAccessException ua_ex)
        {
            response.error = "The directory contains a read-only file";
        }
        catch (IOException io_ex)
        {
            response.error = "File system error occurred";
        }
        catch (System.Security.SecurityException sec_ex)
        {
            response.error = "Does not have the required permission";
        }
        catch (Exception ex)
        {
            response.error = "Error occurred while fetching directory information";
        }
    }
    
    private void DoBrowse(FBResponse response, string type, string filter, string search, string system_abs_path, string relative_path)
    {
        string folder_path = system_abs_path;
        //relative_path += "/";

        try
        {
            DirectoryInfo d = new DirectoryInfo(folder_path);
            response.directory.Name = d.Name;
            response.directory.Path = relative_path;

            bool exclude_this = false;
            
            // ***************************************************** //
            // GET FOLDERS
            // ***************************************************** //
            DirectoryInfo[] all_dirs;

            FBDirectory directory;
            if (search == null)
            {
                all_dirs = d.GetDirectories();
            }
            else
            {
                all_dirs = d.GetDirectories(string.Format("*{0}*", search), SearchOption.TopDirectoryOnly);
            }

            if (all_dirs != null && all_dirs.Length > 0)
            {
                foreach (DirectoryInfo dir_info in all_dirs)
                {
                    exclude_this = false;
                    // Exclude folder rule
                    foreach (string exclude_folder in exclude_rule_folder)
                    {
                        if ((relative_path + dir_info.Name).Equals(exclude_folder, StringComparison.OrdinalIgnoreCase))
                        {
                            exclude_this = true;
                            break;
                        }
                    }

                    if (!exclude_this)
                    {
                        directory = new FBDirectory();
                        directory.Name = dir_info.Name;
                        directory.Path = relative_path + dir_info.Name;
                        directory.NoOfFiles = dir_info.GetFiles().Length;
                        directory.NoOfDirectories = dir_info.GetDirectories().Length;
                        response.directory.AddDirectory(directory);
                    }
                }
            }

            // ***************************************************** //
            // GET FILES
            // ***************************************************** //
            string[] file_exts;
            if (filter == null)
            {
                file_extensions.TryGetValue(type, out file_exts);
            }
            else
            {
                file_exts = filter.Split(new char[] { ',' }, StringSplitOptions.RemoveEmptyEntries);
                for (int i = 0; i < file_exts.Length; i++)
                {
                    file_exts[i] = file_exts[i].Trim();
                }
            }

            if (file_exts.Length > 0)
            {
                FileInfo[] all_files;
                FBFile file;
                
                foreach (string ext in file_exts)
                {
                    all_files = null;
                    file = null;
                    
                    if (search == null)
                    {
                        all_files = d.GetFiles(ext);
                    }
                    else
                    {
                        all_files = d.GetFiles(string.Format("*{0}{1}", search, ext));
                    }

                    if (all_files != null && all_files.Length > 0)
                    {
                        foreach (FileInfo file_info in all_files)
                        {
                            exclude_this = false;
                            // Global exclude rule
                            foreach (string exclude_file in global_exclude_files)
                            {
                                if (file_info.Name.Equals(exclude_file, StringComparison.OrdinalIgnoreCase))
                                {
                                    exclude_this = true;
                                    break;
                                }
                            }
                            
                            // Exclude file rule
                            if (!exclude_this)
                            {
                                foreach (string exclude_file in exclude_rule_files)
                                {
                                    if ((relative_path + file_info.Name).Equals(exclude_file, StringComparison.OrdinalIgnoreCase))
                                    {
                                        exclude_this = true;
                                        break;
                                    }
                                }
                            }

                            if (!exclude_this)
                            {
                                file = new FBFile();
                                file.Name = file_info.Name;
                                file.Extension = file_info.Extension.ToLower();
                                file.Size = file_info.Length;
                                file.Path = relative_path + file_info.Name;

                                response.directory.AddFile(file);
                            }
                        }
                    }
                }
            }

            response.directory.NoOfDirectories = response.directory.directories.Count;
            response.directory.NoOfFiles = response.directory.files.Count;
        }
        catch (DirectoryNotFoundException dir_not_found)
        {
            response.error = "Specified directory not found";
        }
        catch (FileNotFoundException file_not_found)
        {
            response.error = "Specified file not found";
        }
        catch (Exception ex)
        {
            response.error = "Error occurred while fetching directory information";
        }
    }

    private string GetRelativePath(string path)
    {
        if (path != "/")
        {
            if (!path.StartsWith("/"))
            {
                path = "/" + path;
            }

            if (!path.EndsWith("/"))
            {
                path = path + "/";
            }
        }

        return path;
    }

    private string GetSystemAbsPath(string path)
    {
        if (path != "/")
        {
            if (!path.StartsWith("/"))
            {
                path = "~/" + path;
            }

            if (path.EndsWith("/"))
            {
                path = path.TrimEnd('/');
            }
        }

        return HttpContext.Current.Server.MapPath(path);
    }

    private void InvalidRequest(FBResponse response)
    {
        response.error = "Invalid request";
    }

    private void SendResponse(HttpContext context, FBResponse response)
    {
        string json = Newtonsoft.Json.JsonConvert.SerializeObject(response);
        context.Response.Write(json);
    }

    public bool IsReusable
    {
        get
        {
            return false;
        }
    }

}