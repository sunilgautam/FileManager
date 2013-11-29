<%@ WebHandler Language="C#" Class="Uploader" %>

using System;
using System.Web;

public class Uploader : IHttpHandler {

    public void ProcessRequest(HttpContext context)
    {
        try
        {
            HttpPostedFile uploads = context.Request.Files["upload"];
            if (uploads.ContentLength > 0)
            {
                string CKEditorFuncNum = context.Request["CKEditorFuncNum"];

                string ext = System.IO.Path.GetExtension(uploads.FileName).ToLower();
                if (IsValidImageFileExtension(ext))
                {
                    string virtPath = "~/uploads/cms/";
                    string fileName = GetUniqueName(virtPath, "img", ext, context);
                    string url = "/uploads/cms/" + fileName;

                    uploads.SaveAs(context.Server.MapPath(virtPath + fileName));

                    context.Response.Write("<script>window.parent.CKEDITOR.tools.callFunction(" + CKEditorFuncNum + ", \"" + url + "\");</script>");
                }
                else
                {
                    context.Response.Clear();
                    context.Response.Write("<script>window.parent.alert('Please select a valid file.');</script>");
                }
            }
            else
            {
                context.Response.Clear();
                context.Response.Write("<script>window.parent.alert('Please select a valid file.');</script>");
            }
        }
        catch (Exception ex)
        {
            context.Response.Clear();
            context.Response.Write("<script>window.parent.alert('Image not uploaded. "+ex.Message+"');</script>");
        }
    }

    public string GetUniqueName(string path, string initial, string ext, HttpContext context)
    {
        string uniquePart = DateTime.Now.ToFileTime().ToString().Substring(0, 18);
        string filename = string.Format("{0}{1}-{2}{3}", path, initial, uniquePart, ext);
        while (System.IO.File.Exists(context.Server.MapPath(filename)))
        {
            //uniquePart = Guid.NewGuid().ToString().Substring(0, 18);
            uniquePart = DateTime.Now.ToFileTime().ToString().Substring(0, 18);
            filename = string.Format("{0}{1}-{2}{3}", path, initial, uniquePart, ext);
        }

        return string.Format("{0}-{1}{2}", initial, uniquePart, ext);
    }

    public bool IsValidImageFileExtension(string extension)
    {
        return (extension == ".jpg" || extension == ".jpeg" || extension == ".png" || extension == ".bmp" || extension == ".gif");
    }

    public bool IsReusable
    {
        get
        {
            return false;
        }
    }

}