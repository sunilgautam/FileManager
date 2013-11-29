﻿<%@ Page Language="C#" AutoEventWireup="true" CodeFile="MediaManager.aspx.cs" Inherits="ckHelper_MediaManager" %>

<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">

<html xmlns="http://www.w3.org/1999/xhtml">
<head runat="server">
    <title>Media Manager</title>
    <link href="bootstrap/css/bootstrap.min.css" rel="stylesheet" type="text/css" />
    <link href="styles/application.css" rel="stylesheet" type="text/css" />
    <script src="scripts/jquery-1.8.3.min.js" type="text/javascript"></script>
    <script src="bootstrap/js/bootstrap.min.js" type="text/javascript"></script>
    <script src="scripts/handlebars-v1.1.2.js" type="text/javascript"></script>
    <script src="scripts/jquery.cookie.js" type="text/javascript"></script>
    <script src="scripts/application.js" type="text/javascript"></script>
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
            <a class="lib-folder" data-placement="bottom" href="#" rel="{{this.Path}}" title="{{this.Name}}">
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
            <a class="img-thumbs" data-placement="bottom" href="#" rel="{{this.Path}}" title="{{this.Name}}">
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
        {{#each directory.directories}}
        <div class="item">
            <a class="lib-folder" href="#" rel="{{this.Path}}" title="{{this.Name}}">
                <img src="images/folder.png" class="img-polaroid">
            </a>
            <div class="controls">
                <a href="" class="pull-left rename-folder" title="Rename" rel="{{this.Name}}"><i class="icon-pencil"></i></a>
                <a href="" class="pull-right delete-folder" rel="{{this.Path}}" title="Delete"><i class="icon-trash"></i></a>
                <div class="clearfix"></div>
            </div>
        </div>
        {{/each}}
        {{#each directory.files}}
        <div class="item">
            <a href="" class="img-thumbs" rel="{{this.Path}}" title="{{this.Name}}">
                <img src="{{get_image_for_item this}}" class="img-polaroid">
            </a>
            <div class="controls">
                <a href="" class="pull-left rename-file" title="Rename" rel="{{this.Name}}"><i class="icon-pencil"></i></a>
                <a href="" class="pull-right delete-file" rel="{{this.Path}}" title="Delete"><i class="icon-trash"></i></a>
                <div class="clearfix"></div>
            </div>
        </div>
        {{/each}}
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
                                    <div class="input-append">
                                        <input type="text" class="span8" id="txt-search" placeholder="Search" />
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
                                    <a id="toggle-layout" href="" title="Toggle List/Grid Views">
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
                    </div>
                </div>
            </div>
        </div>
    </form>
</body>
</html>