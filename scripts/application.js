﻿/// <reference path="jquery-1.8.3-vsdoc.js" />
if (typeof console == "undefined") {
    window.console = {
        log: function (obj) {

        },
        info: function (obj) {
            
        },
        debug: function (obj) {

        },
        error: function (obj) {

        },
        warn: function (obj) {

        }
    };
}

function debug(obj) {
    console.log(obj);
}

function bytesToSize(bytes) {
    var sizes = ['Bytes', 'KB', 'MB', 'GB', 'TB'];
    if (bytes == 0) return 'n/a';
    var i = parseInt(Math.floor(Math.log(bytes) / Math.log(1024)));
    if (i == 0) return bytes + ' ' + sizes[i];
    return (bytes / Math.pow(1024, i)).toFixed(1) + ' ' + sizes[i];
};

(function (window, undefined) {
    layouts = {
        grid: "grid_layout",
        list: "list_layout"
    };
    default_options = {
        base_path: "/uploads",
        manager_path: "/ckHelper/file-manager.ashx",
        base_type: "all",
        base_layout: layouts.grid,
        base_domain: null
    };
    
    var $app = {
        options: {},
        current: {
                path: null,
                type: null,
                search: null,
                filter: null,
                layout: null
        },
        elem: {
                container: null,
                back_button: null,
                path_label: null,
                refresh_button: null,
                create_textbox: null,
                create_button: null,
                search_textbox: null,
                search_button: null,
                toggle_layout_button: null,
                detail_modal: null,
                message_container: null
             },
        item_template: {
            grid: null,
            list: null,
            empty: null,
            folder_detail: null,
            file_detail: null,
            _delete: null,
            rename: null
        },
        timer: null,
        init: function (opt) {
            var self = this;
            self.options = $.extend({}, default_options, opt);
            // Set domain name
            if (!self.options.base_domain) {
                self.options.base_domain = window.location.protocol + '//' + window.location.host;
            }

            // Cache elements
            self.elem.container = $("#manager-item-wrapper");
            self.elem.back_button = $("#btn-go-back");
            self.elem.path_label = $("#lbl-path");
            self.elem.refresh_button = $("#btn-refresh");
            self.elem.create_textbox = $("#txt-create-folder");
            self.elem.create_button = $("#btn-create-folder");
            self.elem.search_textbox = $("#txt-search");
            self.elem.search_button = $("#btn-search");
            self.elem.toggle_layout_button = $("#toggle-layout");
            self.elem.detail_modal = $("#detail-modal");
            self.elem.message_container = $("#manager-message-wrapper");

            // Compile template
            Handlebars.registerHelper('get_image_for_item', function(obj) {
                if (obj.Extension == '.jpg' || obj.Extension == '.jpeg' || obj.Extension == '.png' || obj.Extension == '.gif' || obj.Extension == '.bmp'){
                    return obj.Path;
                } else if (obj.Extension == '.pdf') {
                    return 'images/file-pdf.jpg';
                } else if (obj.Extension == '.doc' || obj.Extension == '.docx') {
                    return 'images/file-doc.jpg';
                } else if (obj.Extension == '.xls' || obj.Extension == '.xlsx') {
                    return 'images/file-speadsheet.jpg';
                } else if (obj.Extension == '.txt') {
                    return 'images/file-text.jpg';
                } else {
                    return 'images/file.jpg';
                }
                return object;
            });

            var source_grid = $("#manager-item-grid-template").html();
            var source_list = $("#manager-item-list-template").html();
            var source_blank = $("#manager-item-no-item").html();
            var source_folder = $("#folder-details-template").html();
            var source_file = $("#file-details-template").html();
            var source_delete = $("#alert-delete-template").html();
            var source_rename = $("#alert-rename-template").html();
            self.item_template.grid = Handlebars.compile(source_grid);
            self.item_template.list = Handlebars.compile(source_list);
            self.item_template.empty = Handlebars.compile(source_blank);
            self.item_template.folder_detail = Handlebars.compile(source_folder);
            self.item_template.file_detail = Handlebars.compile(source_file);
            self.item_template._delete = Handlebars.compile(source_delete);
            self.item_template.rename = Handlebars.compile(source_rename);

            // Bind events
            self.elem.back_button.click(function(e) {
                self.go_back();
            });

            self.elem.refresh_button.click(function(e) {
                self.refresh();
            });

            self.elem.create_button.click(function(e) {
                
            });

            self.elem.search_button.click(function(e) {
                
            });

            self.elem.toggle_layout_button.click(function(e) {
                
            });

            //
            self.elem.container.on("click", ".lib-folder", function(e) {
                e.preventDefault();

                self.current.path = this.rel;
                self.browse();
                self.set_controls_state();
            });

            self.elem.container.on("click", ".rename-folder,.rename-file", function(e) {
                e.preventDefault();

                var info_elem = $(this);
                var path_segments = info_elem.data("path").split('/');
                var item_path;
                if (path_segments.length > 0) {
                    item_path = path_segments.splice(0, path_segments.length - 1).join('/');
                    var item_details = {Name: info_elem.data("name"), Target: info_elem.data("path"), Effected: info_elem.data("effected"), Path: item_path, Extension: info_elem.data("ext")};
                    self.elem.detail_modal.html(self.item_template.rename(item_details)).modal();
                }
            });
            self.elem.detail_modal.on("click", "#rename-handle", function(e) {
                e.preventDefault();

                var ren_elem = $(this);
                ren_elem.prev().prev("img").show();
                var entered_name = $("#new-name-input").val();
                if(entered_name.replace(/\s/g,"") == "") {
                    self.elem.detail_modal.modal('hide');
                    self.show_auto_message("Please enter new name");
                } else {
                    var new_path = ren_elem.data("target-path") + '/' + $("#new-name-input").val();
                    self.do_rename(ren_elem.data("target-item"), new_path, ren_elem.data("effected"));
                }
            });

            self.elem.container.on("click", ".info-folder", function(e) {
                e.preventDefault();

                var info_elem = $(this);
                var folder_details = {Name: info_elem.data("name"), RelPath: info_elem.data("path"), AbsPath: self.options.base_domain + info_elem.data("path")};

                self.elem.detail_modal.html(self.item_template.folder_detail(folder_details)).modal();
            });
            self.elem.container.on("click", ".delete-folder,.delete-file", function(e) {
                e.preventDefault();

                var info_elem = $(this);
                var item_details = {Name: info_elem.data("name"), Target: info_elem.data("path"), Effected: info_elem.data("effected")};
                self.elem.detail_modal.html(self.item_template._delete(item_details)).modal();
            });

            self.elem.detail_modal.on("click", "#delete-handle", function(e) {
                e.preventDefault();

                var del_elem = $(this);
                del_elem.prev().prev("img").show();
                self.do_delete(del_elem.data("target-item"), del_elem.data("effected"));
            });

            self.elem.container.on("click", ".info-file", function(e) {
                e.preventDefault();

                var info_elem = $(this);
                var file_details = {Name: info_elem.data("name"), Size: bytesToSize(info_elem.data("size")), RelPath: info_elem.data("path"), AbsPath: self.options.base_domain + info_elem.data("path")};
                
                self.elem.detail_modal.html(self.item_template.file_detail(file_details)).modal();
            });

            // Set item tooltip
            self.elem.container.tooltip({selector: ".lib-folder,.img-thumbs"});

            // load files and folders
            self.current.path = $.cookie('fm_path') || self.options.base_path;
            self.current.type = self.options.base_type;
            self.current.filter = "";
            self.current.search = "";
            self.current.layout = self.options.base_layout;
            self.set_controls_state();
            self.browse();
        },
        show_loading: function() {
            var self = this;
            self.elem.container.html('<div class="ajax-loading"></div>');
        },
        hide_loading: function() {
            var self = this;
            self.elem.container.html('<div></div>');
        },
        show_auto_message: function(msg, timeout) {
            var self = this;
            clearTimeout(self.timer);
            self.elem.message_container.html(msg).show();
            self.timer = setTimeout(self.hide_message, timeout || 2000);
        },
        hide_message: function() {
            $app.elem.message_container.hide().empty();
        },
        go_back: function() {
            var self = this;
            if (self.current.path == self.options.base_path) {
                // Can not go back
                debug('Can not go back');
            } else {
                var path_segments = $app.current.path.split('/');
                if (path_segments.length > 0) {
                    self.current.path = path_segments.splice(0, path_segments.length - 1).join('/');
                    self.browse();
                    self.set_controls_state();
                }
            }
        },
        set_controls_state: function() {
            var self = this;

            // Back button
            if (self.current.path == self.options.base_path) {
                self.elem.back_button.attr('disabled', 'disabled');
            } else {
                self.elem.back_button.removeAttr('disabled');
            }

            // Current location
            self.elem.path_label.text(self.current.path);

            // Tooltip
            //self.elem.container.find(".lib-folder").tooltip();
        },
        refresh: function() {
            var self = this;
            self.browse();
            self.set_controls_state();
        },
        render: function(data) {
            var self = this;
            //debug('-------------- '+ JSON.stringify(data));
            
            //var html = self.item_template(data);
            //debug(html);
            if (data.directory.directories.length == 0 && data.directory.files.length == 0) {
                self.render_empty();
            } else {
                if (self.current.layout == layouts.grid) {
                    self.elem.container.html(self.item_template.grid(data));
                } else if (self.current.layout == layouts.list) {
                    self.elem.container.html(self.item_template.list(data));
                }
            }
        },
        render_empty: function() {
            var self = this;
            self.elem.container.html(self.item_template.empty());
        },
        browse: function () {
            var self = this;
            self.show_loading();
            $.ajax({
                url: self.options.manager_path,
                data: {
                        path: self.current.path,
                        action: "browse",
                        type: self.current.type,
                        filter: self.current.filter,
                        q: self.current.search
                },
                cache: false,
                dataType: "json",
                success: function(data){
                    if (data.error == "success") {
                        $.cookie('fm_path', self.current.path, { expires: 1 });
                        self.render(data);
                    } else {
                        self.show_auto_message(data.error);
                        self.hide_loading();
                    }
                },
                error: function(jqXHR, textStatus, errorThrown){
                    self.show_auto_message("Error occurred.");
                    self.hide_loading();
                }
            });
        },
        rename: function () {
            
        },
        do_delete: function(path, effected) {
            var self = this;
            debug(path);

            $.ajax({
                url: self.options.manager_path,
                data: {
                        path: path,
                        action: "delete"
                },
                type: "POST",
                cache: false,
                dataType: "json",
                success: function(data){
                    if (data.error == "success") {
                        self.elem.detail_modal.modal('hide');
                        $(effected).hide("slow").remove();
                    } else {
                        self.show_auto_message(data.error);
                        self.elem.detail_modal.modal('hide');
                    }
                },
                error: function(jqXHR, textStatus, errorThrown){
                    self.show_auto_message("Error occurred.");
                    self.elem.detail_modal.modal('hide');
                }
            });
        },
        do_rename: function(path, new_path, effected) {
            var self = this;
            debug(path);
            debug(new_path);
            
            $.ajax({
                url: self.options.manager_path,
                data: {
                        path: path,
                        new_name: new_path,
                        action: "rename"
                },
                type: "POST",
                cache: false,
                dataType: "json",
                success: function(data){
                    if (data.error == "success") {
                        self.refresh();
                        self.elem.detail_modal.modal('hide');
                        // $(effected).find(".lib-folder,.img-thumbs").attr({"title": new_name, "rel": new_path});
                    } else {
                        self.show_auto_message(data.error);
                        self.elem.detail_modal.modal('hide');
                    }
                },
                error: function(jqXHR, textStatus, errorThrown){
                    self.show_auto_message("Error occurred.");
                    self.elem.detail_modal.modal('hide');
                }
            });
        }
    };

    window.$app = $app;
})(window);

$(function(){
    window.$app.init({});
});