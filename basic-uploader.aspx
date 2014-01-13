<%@ Page Language="C#" AutoEventWireup="true" CodeFile="basic-uploader.aspx.cs" Inherits="ckHelper_basic_uploader" %>

<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">
<head runat="server">
    <title>Basic Uploader</title>
    <link href="bootstrap/css/bootstrap.min.css" rel="stylesheet" type="text/css" />
    <link href="styles/uploader.css" rel="stylesheet" type="text/css" />
    <link href="styles/application.css" rel="stylesheet" type="text/css" />
    <script src="scripts/jquery-1.8.3.min.js" type="text/javascript"></script>
    <script src="bootstrap/js/bootstrap.min.js" type="text/javascript"></script>
</head>
<body>
    <form id="form1" runat="server">
    <div class="container">
        <div class="row">
            <div class="span3">&nbsp;</div>
            <div class="span6">
                <legend>Upload</legend>

                <asp:DropDownList ID="ddlDirectory" DataTextField="Text" DataValueField="Value" runat="server">
                </asp:DropDownList>

                <asp:FileUpload ID="html_uploader" runat="server" CssClass="upload-file" style="height: auto;" />
                <asp:Button id="html_upload" CssClass="upload-button" Text="Upload" runat="server" OnClick="html_upload_Click" />
                <asp:Label ID="lblUploadMessage" runat="server" style="display: block;" />
                <div class="clear"></div>
                <p>
                    Max file size 2MB
                </p>
                <p>
                    You are using basic uploader. <a id="upload-go-to-plupload" href="MediaManager.aspx#upload-manager">Switch to advance uploader</a>.
                </p>
            </div>
            <div class="span3">&nbsp;</div>
        </div>
    </div>
    </form>
</body>
</html>
