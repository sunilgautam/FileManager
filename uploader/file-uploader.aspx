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
            //            $("#upload-go-to-plupload").click(function (e) {
            //                e.preventDefault();
            //                $("#html-upload-ui").hide();
            //                $("#plupload-upload-ui").show();
            //            });

            //            $("#upload-go-to-html").click(function (e) {
            //                e.preventDefault();
            //                $("#html-upload-ui").show();
            //                $("#plupload-upload-ui").hide();
            //            });

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
                    //                    mime_types: [
                    //                        { title: "Image files", extensions: "jpg,gif,png" },
                    //                        { title: "Zip files", extensions: "zip" }
                    //                    ]
                },
                unique_names: true,
                init: {
                    PostInit: function () {
                        //console.log('PostInit');
                    },
                    FilesAdded: function (up, files) {
                        console.log('FilesAdded');
                        plupload.each(files, function (file) {
                            //document.getElementById('filelist').innerHTML += '<div id="' + file.id + '">' + file.name + ' (' + plupload.formatSize(file.size) + ') <b></b></div>';
                            file_list_container.append('<div id="' + file.id + '" class="file-list-item"><a href="#">' + file.name + ' (' + plupload.formatSize(file.size) + ')' + '</a><a href="#" class="cancel">Cancel</a><div class="progress"><div class="progressbar" style="width: 0;">&nbsp;</div><div class="progress-text">Queued</div></div></div>');
                        });
                        uploader.refresh();
                        uploader.start();
                    },
                    FileUploaded: function (up, file, response) {
                        console.log("File uploaded, File: " + file.name + ", Response: " + response.response);
                        console.log("Result: " + response.response["result"]);
                        $("#" + file.id).find("a:first")[0].href = jQuery.parseJSON(response.response).result;
                    },
                    UploadProgress: function (up, file) {
                        console.log('UploadProgress');
                        //document.getElementById(file.id).getElementsByTagName('b')[0].innerHTML = '<span>' + file.percent + "%</span>";
                        $("#" + file.id).find(".progressbar").css({ width: file.percent + "%" }).next().text(file.percent + "%");
                    },
                    Error: function (up, err) {
                        console.log('Error');
                        //document.getElementById('console').innerHTML += "\nError #" + err.code + ": " + err.message;
                    },
                    UploadFile: function () {
                        console.log('UploadFile');
                    },
                    BeforeUpload: function () {
                        console.log('BeforeUpload init');
                    },
                    QueueChanged: function () {
                        console.log('QueueChanged');
                    },
                    ChunkUploaded: function () {
                        console.log('ChunkUploaded');
                    },
                    UploadComplete: function () {
                        console.log('UploadComplete');
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
                        <input id="plupload-browse-button" class="upload-button" type="button" value="Select Files" class="button" />
                    </p>
                </div>
            </div>
            <p>
                You are using the multi-file uploader. Problems? Try the 
                <a id="upload-go-to-html" href="file-uploader.aspx?browser-uploader=1">browser uploader</a> 
                instead.
            </p>
            <div id="plupload-file-list">
            </div>
        </div>

        <div id="html-upload-ui" style="display: <%= IsBrowserUploader == true ? "block" : "none" %>">
            <p id="async-upload-wrap">
                <label>Upload</label>
                <input type="file" name="async-upload" class="upload-file" id="async-upload" />
                <input type="submit" name="html-upload" id="html-upload" class="upload-button" value="Upload"  />
            </p>
            <div class="clear"></div>
            <p>
                You are using the browser&#8217;s built-in file uploader. The WordPress uploader includes multiple file selection and drag and drop capability. 
                <a id="upload-go-to-plupload" href="file-uploader.aspx">Switch to the multi-file uploader</a>.
            </p>
        </div>
    </form>
</body>
</html>
