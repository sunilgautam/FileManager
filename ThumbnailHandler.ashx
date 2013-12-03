<%@ WebHandler Language="C#" Class="ThumbnailHandler" %>

using System;
using System.Web;

public class ThumbnailHandler : IHttpHandler
{
    private HttpResponse _response;
    public HttpResponse Response
    {
        get { return _response; }
        set { _response = value; }
    }

    private HttpRequest _request;
    public HttpRequest Request
    {
        get { return _request; }
        set { _request = value; }
    }
    
    public void ProcessRequest(HttpContext context)
    {
        Request = context.Request;
        Response = context.Response;
        
        context.Response.Clear();
        context.Response.ContentType = "image/jpeg";
        if (string.IsNullOrEmpty(context.Request.QueryString["src"]))
        {
            context.Response.Clear();
            context.Response.StatusCode = 404;
            context.Response.End();
        }
        else
        {
            string image_path = context.Server.MapPath("~" + Request.QueryString["src"]);
            
            int MAX_HEIGHT = 500;
            int MAX_WIDTH = 500;
            int DEFAULT_WIDTH = 200;

            int height = 0, width = DEFAULT_WIDTH;
            if (!string.IsNullOrEmpty(Request.QueryString["w"]))
            {
                int.TryParse(Request.QueryString["w"], out width);
                if (width > MAX_WIDTH)
                {
                    width = MAX_WIDTH;
                }
            }

            if (!string.IsNullOrEmpty(Request.QueryString["h"]))
            {
                int.TryParse(Request.QueryString["h"], out height);
                if (height > MAX_HEIGHT)
                {
                    height = MAX_HEIGHT;
                }
            }

            SaveUplodedFile(image_path, "jpeg", height, width);
        }
    }

    private void SaveUplodedFile(string image_path, string format, int height, int width)
    {
        System.IO.FileStream stream = null;
        try
        {
            string _settings = "format=" + format + ";crop=auto;scale=canvas;width=" + width;
            if (height > 0)
            {
                _settings += ";height=" + height;
            }

            //string _settings = "format=" + format + ";mode=pad;maxwidth=" + width;
            //if (height > 0)
            //{
            //    _settings += ";maxheight=" + height;
            //}

            ImageResizer.ResizeSettings thumbSettings = new ImageResizer.ResizeSettings(_settings);
            
            stream = new System.IO.FileStream(image_path, System.IO.FileMode.Open, System.IO.FileAccess.Read);

            ImageResizer.ImageJob j = new ImageResizer.ImageJob(stream, HttpContext.Current.Response.OutputStream, thumbSettings);
            j.CreateParentDirectory = false;
            j.Build();
        }
        catch (Exception ex)
        {
            // System.IO.FileNotFoundException fnfex
            // System.IO.IOException ioex            
            
            if (stream != null)
            {
                stream.Flush();
                stream.Close();
            }
        }
    }

    public bool IsReusable
    {
        get
        {
            return false;
        }
    }

}