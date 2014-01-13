using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;
using System.Drawing;
using System.IO;
using System.Text;

public partial class ckHelper_basic_uploader : System.Web.UI.Page
{
    public int MAX_HTML_UPLOAD_SIZE = 2097152;
    string[] exclude_rule_folder = new string[] 
                                 {
                                    
                                 };

    protected void Page_Load(object sender, EventArgs e)
    {
        if (!IsPostBack)
        {
            BindDirectorySkeleton();
        }
    }

    private void BindDirectorySkeleton()
    {
        try
        {
            ListItemCollection items = new ListItemCollection();
            string path = "/uploads";

            string system_abs_path = GetSystemAbsPath(path);
            string relative_path = GetRelativePath(path);

            DirectoryInfo d = new DirectoryInfo(system_abs_path);
            items.Add(new ListItem(d.Name, relative_path));

            DirectoryInfo[] all_dirs = d.GetDirectories();
            if (all_dirs != null && all_dirs.Length > 0)
            {
                DoBrowse(system_abs_path, relative_path, all_dirs, items, 1);
            }

            ddlDirectory.DataSource = items;
            ddlDirectory.DataBind();
        }
        catch (Exception ex)
        {

        }
    }

    private void DoBrowse(string system_abs_path, string relative_path, DirectoryInfo[] all_dirs, ListItemCollection dir_items, int level)
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
                        dir_items.Add(new ListItem(string.Format("{0}{1}", padding, dir_info.Name), relative_path + dir_info.Name));

                        DirectoryInfo[] inner_dirs = dir_info.GetDirectories();
                        if (inner_dirs != null && inner_dirs.Length > 0)
                        {
                            int curr_level = level;
                            curr_level++;
                            DoBrowse(folder_path + "\\" + dir_info.Name, relative_path + dir_info.Name + "/", inner_dirs, dir_items, curr_level);
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

    protected void html_upload_Click(object sender, EventArgs e)
    {
        if (html_uploader.HasFile)
        {
            if (html_uploader.PostedFile.ContentLength <= MAX_HTML_UPLOAD_SIZE)
            {
                string ext = string.Empty;
                string MainImage = string.Empty;
                string VirtualPart = "~" + ddlDirectory.SelectedValue;

                ext = System.IO.Path.GetExtension(html_uploader.FileName).ToLower();

                if (!IsValidFileExtension(ext))
                {
                    ShowError("Invalid file type.");
                    return; // STOP FURTHER PROCESSING
                }

                MainImage = GetUniqueName(VirtualPart, "file", ext, false);
                html_uploader.SaveAs(Server.MapPath(VirtualPart + MainImage + ext));
                ShowSuccess("File uploaded successfully");
            }
            else
            {
                ShowError("Selected file is more than permitted size limit");
            }
        }
        else
        {
            ShowError("Please select a file");
        }
    }

    public bool IsValidFileExtension(string extension)
    {
        //return (extension == ".jpg" || extension == ".jpeg" || extension == ".png" || extension == ".bmp");
        return true;
    }

    public string GetUniqueName(string path, string initial, string ext, bool returnExtension)
    {
        string uniquePart = DateTime.Now.ToFileTime().ToString().Substring(0, 18);
        string filename = string.Format("{0}{1}-{2}{3}", path, initial, uniquePart, ext);
        while (System.IO.File.Exists(Server.MapPath(filename)))
        {
            uniquePart = DateTime.Now.ToFileTime().ToString().Substring(0, 18);
            filename = string.Format("{0}{1}-{2}{3}", path, initial, uniquePart, ext);
        }
        if (returnExtension)
        {
            return string.Format("{0}-{1}{2}", initial, uniquePart, ext);
        }
        else
        {
            return string.Format("{0}-{1}", initial, uniquePart);
        }
    }

    public void ShowSuccess(string msg)
    {
        lblUploadMessage.Text = msg;
        lblUploadMessage.ForeColor = Color.Green;
    }

    public void ShowError(string msg)
    {
        lblUploadMessage.Text = msg;
        lblUploadMessage.ForeColor = Color.Red;
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
}