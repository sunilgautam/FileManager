<%@ WebHandler Language="C#" Class="upload" %>

using System;
using System.Web;
using System.IO;

public class upload : IHttpHandler, System.Web.SessionState.IRequiresSessionState
{
    protected HttpContext Context;
    protected HttpResponse Response;
    protected HttpRequest Request;

    // Settings
    private string target_dir = null;
    private string target_dir_virtual = null;
    private string temp_file_ext = ".part";
    private string default_file_ext = ".file";
    private bool cleanup_target_dir = true;
    private int max_file_age = 5 * 60;
    private int max_execution_time = 5 * 60;
    
    public void ProcessRequest(HttpContext context)
    {
        string path;

        path = (context.Request.Params["path"] == null) ? "/" : context.Request.Params["path"];

        target_dir_virtual = GetAppRelativePath(path);
        
        string file_name, file_path, new_file_name, new_file_path, file_ext;
        int chunk, chunks;
        HttpPostedFile uploaded_file = null;
        
        Context = context;
        Request = context.Request;
        Response = context.Response;
        
        context.Response.AddHeader("Expires", "Tue, 01 Jan 1980 01:00:00 GMT");
        context.Response.AddHeader("Last-Modified", DateTime.UtcNow.ToString("ddd, d MMM yyyy H:m:s") + " GMT");
        context.Response.AddHeader("Cache-Control", "no-store, no-cache, must-revalidate");
        context.Response.AddHeader("Cache-Control", "post-check=0, pre-check=0");
        context.Response.AddHeader("Pragma", "no-cache");
        context.Response.ContentType = "application/json";

        if (string.IsNullOrEmpty(Request["name"]))
        {
            SendJsonRpcError("101", "Invalid request detected");
            return;
        }
        
        // CHECK IS FILE UPLOADED ?
        if (Request.Files.Count == 0)
        {
            SendJsonRpcError("101", "No data sent");
        }

        // TO ENABLE CROSS-ORIGIN RESOURCE SHARING
        /*context.Response.AddHeader("Access-Control-Allow-Origin","*");*/ 
        
        Context.Server.ScriptTimeout = max_execution_time;

        target_dir = Context.Server.MapPath(target_dir_virtual);
        
        // CREATE TARGET DIR IF NOT EXISTS
        if (!Directory.Exists(target_dir))
        {
            Directory.CreateDirectory(target_dir);
        }

        // GET FILE NAME FOR FILE
        file_name = Request["name"];
        file_name = Path.GetFileName(file_name);

        file_path = target_dir + "/" + file_name;

        // CHECK IS CHUNKING ENABLED ?
        chunk = string.IsNullOrEmpty(Request["chunk"]) ? 0 : int.Parse(Request["chunk"]);
        chunks = string.IsNullOrEmpty(Request["chunks"]) ? 0 : int.Parse(Request["chunks"]);

        uploaded_file = Request.Files["async-upload"];

        // REMOVE OLD TEMP FILES OLDER THAN MAX FILE AGE THREASEHOLD
        if (cleanup_target_dir)
        {
            DirectoryInfo dir = new DirectoryInfo(target_dir);

            FileInfo[] all_files = dir.GetFiles(string.Format("*{0}", temp_file_ext));
            DateTime file_age_threasehold = DateTime.Now.AddSeconds(-1.0 * max_file_age);
            foreach (FileInfo file_info in all_files)
            {
                if (file_info.LastWriteTime < file_age_threasehold)
                {
                    file_info.Delete();
                }
            }
        }

        try
        {
            //  CREATE NEW STREAM OR APPEND TO EXISTING STREAM IN CASE OF CHUNKING
            using (Stream file_stream = new FileStream(string.Format("{0}{1}", file_path, temp_file_ext), (chunk == 0) ? FileMode.CreateNew : FileMode.Append))
            {
                byte[] buffer = new byte[4096];
                int read;
                while ((read = uploaded_file.InputStream.Read(buffer, 0, buffer.Length)) > 0)
                {
                    file_stream.Write(buffer, 0, read);
                }

                file_stream.Close();

                // IF ALL CHUNKS OR COMPLETE FILE IS UPLOADED THEN STRIP TEMPORARY EXTENSION
                if ((chunks == 0) || (chunk == chunks - 1))
                {
                    file_ext = Path.GetExtension(file_name).ToLower();
                    file_ext = string.IsNullOrEmpty(file_ext) ? default_file_ext : file_ext;
                    new_file_name = GetUniqueFileName(target_dir, "file", file_ext);

                    new_file_path = target_dir + "/" + new_file_name;

                    File.Move(string.Format("{0}{1}", file_path, temp_file_ext), new_file_path);

                    SendJsonRpcNotification(VirtualPathUtility.ToAbsolute(target_dir_virtual + "/" + new_file_name));
                    Response.End();
                }

                // SEND JSON RPC NOTIFICATION
                SendJsonRpcNotification("null");
            }
        }
        catch(Exception ex)
        {
            
        }
        finally
        {
            
        }
    }

    public string GetUniqueFileName(string path, string initial, string ext)
    {
        return GetUniqueFileName(path, initial, ext, true);
    }

    public string GetUniqueFileName(string path, string initial, string ext, bool return_extension)
    {
        string unique_part = DateTime.Now.ToFileTime().ToString().Substring(0, 18);
        string file_name = string.Format("{0}/{1}-{2}{3}", path, initial, unique_part, ext);
        while (System.IO.File.Exists(file_name))
        {
            unique_part = DateTime.Now.ToFileTime().ToString().Substring(0, 18);
            file_name = string.Format("{0}/{1}-{2}{3}", path, initial, unique_part, ext);
        }
        if (return_extension)
        {
            return string.Format("{0}-{1}{2}", initial, unique_part, ext);
        }
        else
        {
            return string.Format("{0}-{1}", initial, unique_part);
        }
    }

    public void SendJsonRpcNotification(string message)
    {
        Response.Write("{\"jsonrpc\" : \"2.0\", \"result\" : \"" + message + "\", \"id\" : \"id\"}");
    }

    public void SendJsonRpcError(string error_code, string message)
    {
        Response.Write("{\"jsonrpc\" : \"2.0\", \"error\" : {\"code\": " + error_code + ", \"message\": \"" + message + "\"}, \"id\" : \"id\"}");
    }

    private string GetAppRelativePath(string path)
    {
        if (path != "/")
        {
            if (path.StartsWith("/"))
            {
                path = "~" + path;
            }
            else
            {
                path = "~/" + path;
            }

            if (path.EndsWith("/"))
            {
                path = path.TrimEnd('/');
            }
        }
        else
        {
            path = "~/" + path;
        }

        return path;
    }

    public bool IsReusable
    {
        get
        {
            return false;
        }
    }
}