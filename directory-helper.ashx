<%@ WebHandler Language="C#" Class="directory_helper" %>

using System;
using System.Web;
using System.IO;
using System.Text;
using System.Collections.Generic;

public class directory_helper : IHttpHandler
{
    string[] exclude_rule_folder = new string[] 
                                 {
                                    
                                 };

    public void ProcessRequest(HttpContext context)
    {
        context.Response.ContentType = "text/plain";
        string path = "/uploads";
        
        string system_abs_path = GetSystemAbsPath(path);
        string relative_path = GetRelativePath(path);

        StringBuilder skeleton = new StringBuilder();
        
        DirectoryInfo d = new DirectoryInfo(system_abs_path);
        skeleton.AppendFormat("<option value\"{1}\">{0}</option>", d.Name, relative_path);

        DirectoryInfo[] all_dirs = d.GetDirectories();
        if (all_dirs != null && all_dirs.Length > 0)
        {
            DoBrowse(system_abs_path, relative_path, all_dirs, skeleton, 1);
        }

        string json = Newtonsoft.Json.JsonConvert.SerializeObject(skeleton);
        context.Response.Write(skeleton.ToString());
    }

    private void DoBrowse(string system_abs_path, string relative_path, DirectoryInfo[] all_dirs, StringBuilder skeleton, int level)
    {
        string folder_path = system_abs_path;
        try
        {
            bool exclude_this = false;
            string padding = string.Empty;
            for (int i = 0; i < level; i++)
            {
                padding += "-- ";
            }

            // ***************************************************** //
            // GET FOLDERS
            // ***************************************************** //
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
                        skeleton.AppendFormat("<option value=\"{1}\">{2}{0}</option>", dir_info.Name, relative_path + dir_info.Name, padding);

                        DirectoryInfo[] inner_dirs = dir_info.GetDirectories();
                        if (inner_dirs != null && inner_dirs.Length > 0)
                        {
                            int curr_level = level;
                            curr_level++;
                            DoBrowse(folder_path + "\\" + dir_info.Name, relative_path + dir_info.Name + "/", inner_dirs, skeleton, curr_level);
                        }
                    }
                }
            }
        }
        catch (DirectoryNotFoundException dir_not_found)
        {
            
        }
        catch (FileNotFoundException file_not_found)
        {
            
        }
        catch (Exception ex)
        {
            
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

    public bool IsReusable
    {
        get
        {
            return false;
        }
    }

}