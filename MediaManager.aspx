<%@ Page Language="C#" AutoEventWireup="true" CodeFile="MediaManager.aspx.cs" Inherits="ckHelper_MediaManager" %>

<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">

<html xmlns="http://www.w3.org/1999/xhtml">
<head runat="server">
    <title>Media Manager</title>
    <link href="bootstrap/css/bootstrap.min.css" rel="stylesheet" type="text/css" />
    <link href="styles/uploader.css" rel="stylesheet" type="text/css" />
    <link href="styles/application.css" rel="stylesheet" type="text/css" />
    <script src="scripts/jquery-1.8.3.min.js" type="text/javascript"></script>
    <script src="bootstrap/js/bootstrap.min.js" type="text/javascript"></script>
    <script src="scripts/handlebars-v1.1.2.js" type="text/javascript"></script>
    <script src="scripts/jquery.cookie.js" type="text/javascript"></script>
    <script src="scripts/plupload.full.min.js" type="text/javascript"></script>
    <script src="scripts/application.js" type="text/javascript"></script>
    <script id="up-list-template" type="text/x-handlebars-template">
        <div id="{{id}}" class="file-list-item">
            <a href="javascript:void(0)" target="_blank" class="entry">{{name}}({{size}})</a>
            <div class="progress progress-striped active">
                <div class="bar" style="width: 0;">&nbsp;</div>
                <div class="progress-text">Processing ...</div>
            </div>
        </div>
    </script>
    <script id="alert-rename-template" type="text/x-handlebars-template">
        <div class="modal-header">
            <h4>Rename</h4>
        </div>
        <div class="modal-body">
            <p>Rename <span class="text-error">{{Name}}</span> to : <input id="new-name-input" name="new-name-input" type="text" value="{{Extension}}" /></p>
        </div>
        <div class="modal-footer">
            <image id="rename-progress" style="display: none; margin-right: 10px;" src="images/loader2.gif" />
            <a href="#" class="btn" data-dismiss="modal" aria-hidden="true">Cancel</a>
            <a id="rename-handle" href="#" class="btn btn-danger" data-target-item="{{Target}}" data-target-path="{{Path}}" data-effected="{{Effected}}">&nbsp;Done&nbsp;</a>
        </div>
    </script>
    <script id="alert-delete-template" type="text/x-handlebars-template">
        <div class="modal-header">
            <h4>Delete</h4>
        </div>
        <div class="modal-body">
            <p>Do you want to delete <span class="text-error">{{Name}}</span> ?</p>
        </div>
        <div class="modal-footer">
            <image id="delete-progress" style="display: none; margin-right: 10px;" src="images/loader2.gif" />
            <a href="#" class="btn" data-dismiss="modal" aria-hidden="true">&nbsp;&nbsp;No&nbsp;&nbsp;</a>
            <a id="delete-handle" href="#" class="btn btn-danger" data-target-item="{{Target}}" data-effected="{{Effected}}">&nbsp;Yes&nbsp;</a>
        </div>
    </script>
    <script id="folder-details-template" type="text/x-handlebars-template">
        <div class="detail-wrapper">
            <div class="modal-header">
                <h4>Details</h4>
            </div>
            <div class="form-horizontal" style="margin-top: 20px;">
                <div class="input-prepend">
                    <span class="add-on w-95">Name</span>
                    <input class="w-500" type="text" disabled value="{{Name}}" />
                </div>
                <div class="input-prepend">
                    <span class="add-on w-95">Relative path</span>
                    <input class="w-500" type="text" disabled value="{{RelPath}}" />
                </div>
                <div class="input-prepend">
                    <span class="add-on w-95">Absolute path</span>
                    <input class="w-500" type="text" disabled value="{{AbsPath}}" />
                </div>
            </div>
        </div>
        <div class="modal-footer">
            <button class="btn" data-dismiss="modal" aria-hidden="true">Close</button>
        </div>
    </script>
    <script id="file-details-template" type="text/x-handlebars-template">
        <div class="detail-wrapper">
            <div class="modal-header">
                <h4>Details</h4>
            </div>
            <div class="form-horizontal" style="margin-top: 20px;">
                <div class="input-prepend">
                    <span class="add-on w-95">Name</span>
                    <input class="w-500" type="text" disabled value="{{Name}}" />
                </div>
                <div class="input-prepend">
                    <span class="add-on w-95">Size</span>
                    <input class="w-500" type="text" disabled value="{{Size}}" />
                </div>
                <div class="input-prepend">
                    <span class="add-on w-95">Relative path</span>
                    <input class="w-500" type="text" disabled value="{{RelPath}}" />
                </div>
                <div class="input-prepend">
                    <span class="add-on w-95">Absolute path</span>
                    <input class="w-500" type="text" disabled value="{{AbsPath}}" />
                </div>
            </div>
        </div>
        <div class="modal-footer">
            <button class="btn" data-dismiss="modal" aria-hidden="true">Close</button>
        </div>
    </script>
    <script id="manager-item-no-item" type="text/x-handlebars-template">
        <div class="no-item"> No item here </div>
    </script>
    <script id="manager-item-grid-template" type="text/x-handlebars-template">
        {{#each directory.directories}}
        <div class="item" id="dir-{{@index}}">
            <a class="lib-folder tooltiper" data-placement="bottom" href="#" rel="{{this.Path}}" title="{{this.Name}}">
                <img src="images/folder.png" class="img-polaroid">
            </a>
            <div class="controls">
                <a href="#" class="pull-left btn rename-folder" data-effected="#dir-{{@index}}" data-name="{{this.Name}}" data-path="{{this.Path}}" data-ext="" title="Rename"><i class="icon-pencil"></i></a>
                <a href="#" class="btn info-folder" data-name="{{this.Name}}" data-path="{{this.Path}}" title="View details"><i class="icon-info-sign"></i></a>
                <a href="#" class="pull-right btn delete-folder" data-effected="#dir-{{@index}}" data-name="{{this.Name}}" data-path="{{this.Path}}" title="Delete"><i class="icon-trash"></i></a>
                <div class="clearfix"></div>
            </div>
        </div>
        {{/each}}
        {{#each directory.files}}
        <div class="item" id="file-{{@index}}">
            <a class="img-thumbs tooltiper" data-placement="bottom" href="#" data-name="{{this.Name}}" data-path="{{this.Path}}" data-size="{{this.Size}}" data-ext="{{this.Extension}}" title="{{this.Name}}">
                <img src="{{get_image_for_item this}}" class="img-polaroid">
            </a>
            <div class="controls">
                <a href="#" class="pull-left btn rename-file" data-effected="#file-{{@index}}" data-name="{{this.Name}}" data-path="{{this.Path}}" data-ext="{{this.Extension}}" title="Rename"><i class="icon-pencil"></i></a>
                <a href="#" class="btn info-file" data-name="{{this.Name}}" data-path="{{this.Path}}" data-size="{{this.Size}}" title="View details"><i class="icon-info-sign"></i></a>
                <a href="#" class="pull-right btn delete-file" data-effected="#file-{{@index}}" data-name="{{this.Name}}" data-path="{{this.Path}}" title="Delete"><i class="icon-trash"></i></a>
                <div class="clearfix"></div>
            </div>
        </div>
        {{/each}}
        <div class="clearfix"></div>
    </script>
    <script id="manager-item-list-template" type="text/x-handlebars-template">
        <table class="table">
	        <tbody>
                {{#each directory.directories}}
                <tr class="item" id="dir-{{@index}}">
			        <td>
				        <i class="icon-folder-open"></i>&nbsp;
				        <a class="lib-folder lib-folder-list" data-placement="bottom" href="#" rel="{{this.Path}}" title="{{this.Name}}">
                            {{this.Name}}
                        </a>
			        </td>
			        <td width="20%">
				        {{get_total_item this.NoOfDirectories this.NoOfFiles}} Items
			        </td>
			        <td width="15%">
				        <a href="#" class="btn rename-folder" data-effected="#dir-{{@index}}" data-name="{{this.Name}}" data-path="{{this.Path}}" data-ext="" title="Rename"><i class="icon-pencil"></i></a>
                        <a href="#" class="btn info-folder" data-name="{{this.Name}}" data-path="{{this.Path}}" title="View details"><i class="icon-info-sign"></i></a>
                        <a href="#" class="btn delete-folder" data-effected="#dir-{{@index}}" data-name="{{this.Name}}" data-path="{{this.Path}}" title="Delete"><i class="icon-trash"></i></a>
			        </td>
		        </tr>
                {{/each}}
                {{#each directory.files}}
                <tr class="item" id="file-{{@index}}">
			        <td>
				        <i class="icon-picture"></i>&nbsp;
                        <a class="img-thumbs img-thumbs-list" data-placement="bottom" href="#" data-name="{{this.Name}}" data-path="{{this.Path}}" data-size="{{this.Size}}" data-ext="{{this.Extension}}" title="{{this.Name}}">
                            {{this.Name}}
                        </a>
			        </td>
			        <td width="20%">
				        {{get_bytes_to_size this.Size}}
			        </td>
			        <td width="15%">
				        <a href="#" class="btn rename-file" data-effected="#file-{{@index}}" data-name="{{this.Name}}" data-path="{{this.Path}}" data-ext="{{this.Extension}}" title="Rename"><i class="icon-pencil"></i></a>
                        <a href="#" class="btn info-file" data-name="{{this.Name}}" data-path="{{this.Path}}" data-size="{{this.Size}}" title="View details"><i class="icon-info-sign"></i></a>
                        <a href="#" class="btn delete-file" data-effected="#file-{{@index}}" data-name="{{this.Name}}" data-path="{{this.Path}}" title="Delete"><i class="icon-trash"></i></a>
			        </td>
		        </tr>
                {{/each}}
            </tbody>
        </table>
        <div class="clearfix"></div>
    </script>
</head>
<body>
    <form id="form1" runat="server">
        <div class="container-fluid">
            <div class="row-fluid">
                <div class="span12">
                    &nbsp;
                </div>
                <div class="tabbable tabs-left">
                    <ul class="nav nav-tabs">
                        <li class="active"><a href="#file-manager" data-toggle="tab">File Manager</a></li>
                        <li><a href="#upload-manager" data-toggle="tab">Upload Manager</a></li>
                    </ul>
                    <div class="tab-content">
                        <div class="tab-pane active" id="file-manager">
                            <div>
                                <div class="pull-left" style="padding-left: 11px;">
                                    <button class="btn" id="btn-go-back" type="button">
                                        <i class="icon-hand-left"></i> Back
                                    </button>
                                    &nbsp;&nbsp;&nbsp;
                                    <button id="btn-refresh" title="refresh" class="btn" type="button">
                                        &nbsp;<i class="icon-refresh"></i>&nbsp;
                                    </button>
                                </div>
                                <div class="pull-right" style="padding-right: 12px;">
                                    <div class="input-append" style="position: relative;">
                                        <input type="text" class="span8" id="txt-search" placeholder="Search" />
                                        <i class="icon-remove" id="search-cancel"></i>
                                        <button id="btn-search" class="btn" type="button">
                                            &nbsp;<i class="icon-search"></i>&nbsp;
                                        </button>
                                    </div>
                                </div>
                                <div class="pull-right" style="padding-right: 12px;">
                                    <span id="new-folder-msg"></span>
                                    <div class="input-append">
                                        <input type="text" class="span8" id="txt-create-folder" placeholder="Create folder here" />
                                        <button id="btn-create-folder" class="btn" type="button">
                                            &nbsp;<i class="icon-plus"></i>&nbsp;
                                        </button>
                                    </div>
                                </div>
                                <div class="clear"></div>
							</div>
                            <div class="seperator-msg">
                                <div id="manager-message-wrapper" class="manager-message-wrapper" style="display: none;">
                                </div>
                            </div>
                            <div class="seperator-2">
                                <p class="pull-left muted"style="padding-left: 12px;">You are here <i class="icon-hand-right"></i></p>
								<p class="pull-left muted" id="lbl-path" style="padding-left: 12px;"></p>

								<p style="padding-right: 40px;" class="pull-right transparent">
                                    <a id="toggle-layout" href="#" title="Toggle List Views/Grid Views">
                                        <i class="icon-th-list"></i>
                                    </a>
                                </p>
								<div style="clear: both;"></div>
							</div>
                            <div class="manager-item" id="manager-item-wrapper">
                            </div>
                            <div id="detail-modal" style="width: 702px;" class="modal hide fade" tabindex="-1" role="dialog" aria-hidden="true">
                            </div>
                        </div>
                        <div class="tab-pane" id="upload-manager">
                            <div>
                                <select id="upload-directory">
                                </select>
                                <button id="btn-upload-refresh" title="refresh" class="btn" type="button" style="vertical-align: top;">
                                    &nbsp;<i class="icon-refresh"></i>&nbsp;
                                </button>
                            </div>
                            <div id="plupload-upload-ui">
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
                                    <a id="upload-go-to-html" href="basic-uploader.aspx">basic uploader</a> 
                                    instead.
                                </p>
                                <p id="plupload-upload-error" style="display: none;">&nbsp;</p>
                                <div id="plupload-file-list">
                                    
                                </div>
                            </div>
                        </div>
                    </div>
                </div>
            </div>
        </div>
    </form>
</body>
</html>
