<%@ Page Language="C#" AutoEventWireup="true" CodeFile="default_way.aspx.cs" Inherits="ckHelper_uploader_default_way" %>

<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">

<html xmlns="http://www.w3.org/1999/xhtml">
<head runat="server">
    <title></title>
</head>
<body>
    <form id="form1" runat="server">
    <div>
        <asp:FileUpload ID="uploader" runat="server" />
        <asp:Button ID="btnUpload" Text="Upload" runat="server" onclick="btnUpload_Click" />
    </div>
    </form>
</body>
</html>
