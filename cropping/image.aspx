<%@ Page Language="C#" AutoEventWireup="true" CodeFile="image.aspx.cs" Inherits="cropping_image" %>

<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">

<html xmlns="http://www.w3.org/1999/xhtml">
<head runat="server">
    <title></title>
    <link href="styles/imgareaselect-default.css" rel="stylesheet" type="text/css" />
    <script src="scripts/jquery-1.8.3.min.js" type="text/javascript"></script>
    <%--<script src="scripts/jquery.imgareaselect.min.js" type="text/javascript"></script>--%>
    <script src="scripts/jquery.imgareaselect.pack.js" type="text/javascript"></script>
    <script type="text/javascript">
        function preview(img, selection) {
            set_selection(selection.x1, selection.y1, selection.x2, selection.y2, selection.width, selection.height);
        }

        function set_selection(x1, y1, x2, y2, width, height) {
            $('#crop_x1').val(x1);
            $('#crop_y1').val(y1);
            $('#crop_x2').val(x2);
            $('#crop_y2').val(y2);
            $('#crop_w').val(width);
            $('#crop_h').val(height);
        }

        function validate_selection() {
            var x1 = $('#crop_x1').val();
            var y1 = $('#crop_y1').val();
            var x2 = $('#crop_x2').val();
            var y2 = $('#crop_y2').val();
            var w = $('#crop_w').val();
            var h = $('#crop_h').val();
            if (x1 == "" || y1 == "" || x2 == "" || y2 == "" || w == "" || h == "") {
                alert("You must make a selection first");
                return false;
            } else {
                return true;
            }
        }

        $(document).ready(function () {
            var elem_selector = $('#<%= big_image.ClientID %>');

            elem_selector.load(function () {
                var target_width = 100,
                target_height = 100,
                xinit = target_width,
                yinit = target_height,
                ratio = xinit / yinit,
                ximg = elem_selector.width(),
                yimg = elem_selector.height();

                if (yimg < yinit || ximg < xinit) {
                    if (ximg / yimg > ratio) {
                        yinit = yimg;
                        xinit = yinit * ratio;
                    } else {
                        xinit = ximg;
                        yinit = xinit / ratio;
                    }
                }
                console.log(xinit);
                console.log(yinit);

                elem_selector.imgAreaSelect({
                    handles: true,
                    keys: true,
                    show: true,
                    x1: 0,
                    y1: 0,
                    x2: xinit,
                    y2: yinit,
                    aspectRatio: xinit + ':' + yinit,
                    minHeight: target_height,
                    minWidth: target_width,
                    onInit: set_selection(0, 0, xinit, yinit, xinit, yinit),
                    onSelectChange: preview
                });
            });
        });
    </script>
</head>
<body>
    <form id="form1" runat="server">
    <div>
        <asp:Image ID="big_image" runat="server" ImageUrl="~/ckHelper/cropping/working/uploaded.jpg" />
        <asp:Image ID="done_image" runat="server" />
        <asp:Button ID="btnCrop" Text="Crop" runat="server" OnClientClick="return validate_selection();" onclick="btnCrop_Click" />
        <asp:HiddenField ID="crop_image" runat="server" Value="~/ckHelper/cropping/working/uploaded.jpg" />
        <asp:HiddenField ID="crop_x1" runat="server" />
        <asp:HiddenField ID="crop_y1" runat="server" />
        <asp:HiddenField ID="crop_x2" runat="server" />
        <asp:HiddenField ID="crop_y2" runat="server" />
        <asp:HiddenField ID="crop_w" runat="server" />
        <asp:HiddenField ID="crop_h" runat="server" />
    </div>
    </form>
</body>
</html>
