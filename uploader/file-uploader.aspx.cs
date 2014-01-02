using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;
using System.Drawing;

public partial class ckHelper_uploader_file_uploader : System.Web.UI.Page
{
    public bool IsBrowserUploader { get; set; }
    public int MAX_HTML_UPLOAD_SIZE = 2097152;

    protected void Page_Load(object sender, EventArgs e)
    {
        if (string.IsNullOrEmpty(Request.QueryString["browser-uploader"]) || Request.QueryString["browser-uploader"] == "0")
        {
            IsBrowserUploader = false;
        }
        else
        {
            IsBrowserUploader = true;
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
                string VirtualPart = "~/uploads/plupload/";

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
}