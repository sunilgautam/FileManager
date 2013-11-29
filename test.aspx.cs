using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;

public partial class ckHelper_test : System.Web.UI.Page
{
    protected void Page_Load(object sender, EventArgs e)
    {
        string[] paths = new string[] { "/", "/uploads", "/uploads/", "/uploads/test.jpg"};
        foreach (string path in paths)
        {
            Response.Write(string.Format("{0} => {1}<br />", path, Server.MapPath("~/" + path)));
        }
    }
}