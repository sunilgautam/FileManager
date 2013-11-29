<%@ Page Language="C#" AutoEventWireup="true" CodeFile="index.aspx.cs" Inherits="filebrowser_index" %>

<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">

<html xmlns="http://www.w3.org/1999/xhtml">
<head id="Head1" runat="server">
    <title></title>
    <style type="text/css">
        .panel-1
        {
            border: solid 1px #333;
            padding-top: 5px;
            padding-left: 5px;
        }
        
        .panel-1 ul
        {
            margin: 0px;
            padding: 0px;
            list-style-type: none;
        }
        
        .panel-1 ul li
        {
            float: left;
        }
        
        .panel-1 ul li a
        {
            display: block;
            border: solid 1px #afafaf;
            text-decoration: none;
            padding: 5px;
            margin-right: 5px;
            margin-bottom: 5px;
        }
        
        .panel-1 ul li a:hover
        {
            border: solid 1px #222;
        }
        
        .panel-1 ul li a img
        {
            display: block;
            height: 200px;
            width: 200px;
        }
        
        .panel-1 ul li a span
        {
            display: block;
            color: #333;
        }
    </style>
    <script src="scripts/jquery-1.8.3.min.js" type="text/javascript"></script>
    <script src="bootstrap/js/bootstrap.min.js" type="text/javascript"></script>
    <script src="scripts/application.js" type="text/javascript"></script>
    <script type="text/javascript">
        $(document).ready(function () {
            getList();

            $("#display-list li a").live("click", function (event) {
                event.preventDefault();
                var targetCKEditor = '<%= Request.QueryString["CKEditor"] %>';
                var targetCKFunction = '<%= Request.QueryString["CKEditorFuncNum"] %>';
                var $elem = $(this);
                //window.parent.CKEDITOR.tools.callFunction(targetCKFunction, $elem.attr("href"));
                window.opener.CKEDITOR.tools.callFunction(targetCKFunction, $elem.attr("href"));
                window.close();
            });
        });

        function getList() {
            $.ajax({
                type: "GET",
                url: "browser.ashx",
                cache: false,
                dataType: "json",
                data: "type=image&action=browse",
                success: function (response) {
                    if (response.error == "success") {
                        buildGUI(response.directory);
                    } else {
                        alert("Error occurred");
                    }
                }
            });
        }

        function buildGUI(directory) {
            var dirName = directory.Name;
            var dirPath = directory.Path;
            var $list = $("#display-list");
            var items = "";
            // FILES
            for (var i = 0; i < directory.files.length; i++) {
                items += '<li><a href="' + directory.files[i].Path + '"><img src="' + directory.files[i].Path + '" alt="" /><span>' + directory.files[i].Name + '</span></a></li>';
            }
            $list.html(items);

            // FOLDERS
            for (var i = 0; i < directory.directories.length; i++) {
                //console.log(directory.directories[i]);
            }
        }

        function insertImage() {
            alert('hello');
        }
    </script>
</head>
<body>
    <form id="form1" runat="server">
    <div class="panel-1">
        <ul id="display-list">
            <li>
                Loading ...
            </li>
        </ul>
        <div style="clear: both;"></div>
    </div>
    </form>
</body>
</html>
