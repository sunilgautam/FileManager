using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;

public partial class cropping_image : System.Web.UI.Page
{
    protected void Page_Load(object sender, EventArgs e)
    {

    }

    protected void btnCrop_Click(object sender, EventArgs e)
    {
        string unique_part = DateTime.Now.ToFileTime().ToString().Substring(0, 18);
        string target = string.Format("~/ckHelper/cropping/done/img-{0}.jpeg", unique_part);
        CropImage(int.Parse(crop_x1.Value), int.Parse(crop_y1.Value), int.Parse(crop_x2.Value), int.Parse(crop_y2.Value), 100, 100, Server.MapPath(crop_image.Value), Server.MapPath(target));
        done_image.ImageUrl = target;
    }

    protected void CropImage(int x1, int y1, int x2, int y2, int width, int height, string source, string target)
    {
        string _settings = string.Format("format=jpeg;crop=({0},{1},{2},{3});maxwidth={4}&maxheight={5}", x1, y1, x2, y2, width, height);
        ImageResizer.ResizeSettings thumbSettings = new ImageResizer.ResizeSettings(_settings);

        ImageResizer.ImageJob j = new ImageResizer.ImageJob(source, target, thumbSettings);
        j.CreateParentDirectory = false;
        j.Build();
    }
}