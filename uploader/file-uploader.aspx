<%@ Page Language="C#" AutoEventWireup="true" CodeFile="file-uploader.aspx.cs" Inherits="ckHelper_uploader_file_uploader" %>

<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">

<html xmlns="http://www.w3.org/1999/xhtml">
<head runat="server">
    <title>Media uploader</title>
    <link href="styles/uploader.css" rel="stylesheet" type="text/css" />
    <script src="scripts/jquery-1.8.3.min.js" type="text/javascript"></script>
    <script src="scripts/plupload.full.min.js" type="text/javascript"></script>
    <script type="text/javascript">
        $(function () {
            var drag_drop_area = $("#drag-drop-area"),
                file_list_container = $("#plupload-file-list");

            drag_drop_area
            .on("dragover", function () { drag_drop_area.addClass("drag-over") })
            .on("dragleave", function () { drag_drop_area.removeClass("drag-over") })
            .on("drop", function () { drag_drop_area.removeClass("drag-over") });

            var uploader = new plupload.Uploader({
                browse_button: 'plupload-browse-button',    // Browse button
                container: 'plupload-upload-ui',            // Element which will contain plupload stucture
                drop_element: "drag-drop-area",           // Drop element
                url: 'upload.ashx',
                flash_swf_url: 'scripts/Moxie.swf',
                silverlight_xap_url: 'scripts/Moxie.xap',
                file_data_name: "async-upload",
                chunk_size: '1mb',
                filters: {
                    max_file_size: '2000mb'
                    //mime_types: [
                    //  { title: "Image files", extensions: "jpg,gif,png" },
                    //  { title: "Zip files", extensions: "zip" }
                    //]
                },
                unique_names: true,
                init: {
                    FilesAdded: function (up, files) {
                        plupload.each(files, function (file) {
                            file_list_container.append('<div id="' + file.id + '" class="file-list-item"><a href="javascript:void(0)" target="_blank" class="entry">' + file.name + ' (' + plupload.formatSize(file.size) + ')' + '</a><div class="progress"><div class="progressbar" style="width: 0;">&nbsp;</div><div class="progress-text">Queued</div></div></div>');
                        });
                        uploader.refresh();
                        uploader.start();
                    },
                    FileUploaded: function (up, file, response) {
                        $("#" + file.id)
                            .find(".progress-text")
                            .text("Done")
                            .parent()
                            .prevAll(".entry:first")[0].href = jQuery.parseJSON(response.response).result;
                    },
                    UploadProgress: function (up, file) {
                        $("#" + file.id).find(".progressbar").css({ width: file.percent + "%" }).next().text(file.percent + "%");
                    },
                    Error: function (up, err) {
                        $("#plupload-upload-error").html("Error #" + err.code + ": " + err.message);
                    }
                }
            });

            uploader.init();
        });
    </script>
</head>
<body>
    <form id="form1" runat="server">
        <div id="plupload-upload-ui" style="display: <%= IsBrowserUploader == true ? "none" : "block" %>">
            <div id="drag-drop-area">
                <div class="drag-drop-inside">
                    <p class="drag-drop-info">Drop files here</p>
                    <p>or</p>
                    <p class="drag-drop-buttons">
                        <input id="plupload-browse-button" class="upload-button" type="button" value="Select Files" />
                    </p>
                </div>
            </div>
            <p>
                Max file size 2GB
            </p>
            <p>
                You are using the advance uploader. Problems? Try the 
                <a id="upload-go-to-html" href="file-uploader.aspx?browser-uploader=1">basic uploader</a> 
                instead.
            </p>
            <p id="plupload-upload-error" style="display: none;">&nbsp;</p>
            <div id="plupload-file-list">
            </div>
        </div>

        <div id="html-upload-ui" style="display: <%= IsBrowserUploader == true ? "block" : "none" %>">
            <p id="async-upload-wrap">
                <label>Upload</label>
                <asp:FileUpload ID="html_uploader" runat="server" CssClass="upload-file" />
                <asp:Button id="html_upload" CssClass="upload-button" Text="Upload" runat="server" OnClick="html_upload_Click" />
                <asp:Label ID="lblUploadMessage" runat="server" />
            </p>
            <div class="clear"></div>
            <p>
                Max file size 2MB
            </p>
            <p>
                You are using basic uploader. <a id="upload-go-to-plupload" href="file-uploader.aspx">Switch to advance uploader</a>.
            </p>
        </div>
    </form>
</body>
</html>