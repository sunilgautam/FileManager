using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;

public partial class ckHelper_uploader_file_uploader : System.Web.UI.Page
{
    public bool IsBrowserUploader { get; set; }
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
}