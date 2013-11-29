<%@ WebHandler Language="C#" Class="browser" %>

using System;
using System.Web;
using System.Collections.Generic;
using System.IO;
using FileBrowser;

public class browser : IHttpHandler, System.Web.SessionState.IRequiresSessionState
{
    public void ProcessRequest(HttpContext context)
    {
        string fileType, action;
        string dirVertualPath = "~/uploads/cms/";
        string dirName = "cms";
        FBResponse jsonResponse = new FBResponse();

        if (context.Request.QueryString["type"] != null && context.Request.QueryString["type"] != string.Empty)
        {
            if (context.Request.QueryString["action"] != null && context.Request.QueryString["action"] != string.Empty)
            {
                fileType = context.Request.QueryString["type"];
                action = context.Request.QueryString["action"];

                if (action.ToLower() == "browse" && fileType.ToLower() == "image")
                {
                    string dirAbsolutPath = context.Server.MapPath(dirVertualPath);
                    string dirPath = VirtualPathUtility.ToAbsolute(dirVertualPath);

                    jsonResponse.directory.Name = dirName;
                    jsonResponse.directory.Path = dirPath;
                    BrowseImagesInFolder(jsonResponse, dirPath, dirAbsolutPath);
                }
            }
            else
            {
                InvalidRequest(jsonResponse);
            }
        }
        else
        {
            InvalidRequest(jsonResponse);
        }

        SendResponse(context, jsonResponse);
    }

    private void InvalidRequest(FBResponse response)
    {
        response.error = "invalid request";
    }

    private void BrowseImagesInFolder(FBResponse response, string dir, string dirAbsolute)
    {
        string folderPath = dirAbsolute;
        string folder = dir;
        string[] fileExts = new string[] { "*.jpg", "*.jpeg", "*.png", "*.gif", "*.bmp" };

        System.IO.DirectoryInfo d = new DirectoryInfo(folderPath);

        // GET FILES
        foreach (string ext in fileExts)
        {
            //IEnumerable<FileInfo> allFiles = d.EnumerateFiles(ext);
            FileInfo[] allFiles = d.GetFiles(ext);
            foreach (FileInfo fInfo in allFiles)
            {
                FBFile file = new FBFile();
                file.Name = fInfo.Name;
                file.Path = folder + fInfo.Name;
                response.directory.files.Add(file);
            }
        }

        // GET FOLDERS
        DirectoryInfo[] allDirs = d.GetDirectories();
        foreach (DirectoryInfo dInfo in allDirs)
        {
            FBDirectory dirctory = new FBDirectory();
            dirctory.Name = dInfo.Name;
            dirctory.Path = folder + dInfo.Name;
            response.directory.directories.Add(dirctory);
        }
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