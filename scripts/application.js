/// <reference path="jquery-1.8.3-vsdoc.js" />
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
        dir_helper_path: "/ckHelper/directory-helper.ashx",
        base_type: "all",
        base_layout: layouts.grid,
        base_domain: null,
        onfileclick: function(name, ext, size, rel_path, abs_path) {
            debug(name + ' - ' + ext +' - '+ size +' - '+ rel_path +' - '+ abs_path);
        },
        up_url: 'upload.ashx',
        up_flash_swf_url: 'scripts/Moxie.swf',
        up_silverlight_xap_url: 'scripts/Moxie.xap',
        up_file_data_name: 'async-upload',
        up_chunk_size: '1mb',
        up_filters: {
            max_file_size: '2000mb'
        },
        up_unique_names: true
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
                search_cancel: null,
                toggle_layout_button: null,
                detail_modal: null,
                message_container: null,
                up_drag_drop_area: null,
                up_file_list_container: null,
                up_browse_button: null,
                up_container: null,
                up_error: null,
                directory_select: null,
                directory_refresh: null
             },
        item_template: {
            grid: null,
            list: null,
            empty: null,
            folder_detail: null,
            file_detail: null,
            _delete: null,
            rename: null,
            upload_list: null
        },
        uploader: null,
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
            self.elem.search_cancel = $("#search-cancel");
            self.elem.toggle_layout_button = $("#toggle-layout");
            self.elem.detail_modal = $("#detail-modal");
            self.elem.message_container = $("#manager-message-wrapper");
            self.elem.up_container = $("#plupload-upload-ui");
            self.elem.up_drag_drop_area = $("#drag-drop-area");
            self.elem.up_browse_button = $("#plupload-browse-button");
            self.elem.up_file_list_container = $("#plupload-file-list");
            self.elem.up_error = $("#plupload-upload-error");
            self.elem.directory_select = $("#upload-directory");
            self.elem.directory_refresh = $("#btn-upload-refresh");

            // Compile template
            Handlebars.registerHelper('get_image_for_item', function(obj) {
                if (obj.Extension == '.jpg' || obj.Extension == '.jpeg' || obj.Extension == '.png' || obj.Extension == '.gif' || obj.Extension == '.bmp'){
                    //ThumbnailHandler.ashx?src=uploads/sliders/Kavita_Bharitya_Large.jpg&w=200&h=200
                    return 'ThumbnailHandler.ashx?src='+obj.Path+'&w=140&h=100';
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
            Handlebars.registerHelper('get_total_item', function(total1, total2) {
                return (total1 + total2);
            });
            Handlebars.registerHelper('get_bytes_to_size', function(size) {
                return bytesToSize(size);
            });

            var source_grid = $("#manager-item-grid-template").html();
            var source_list = $("#manager-item-list-template").html();
            var source_blank = $("#manager-item-no-item").html();
            var source_folder = $("#folder-details-template").html();
            var source_file = $("#file-details-template").html();
            var source_delete = $("#alert-delete-template").html();
            var source_rename = $("#alert-rename-template").html();
            var source_upload_list = $("#up-list-template").html();
            self.item_template.grid = Handlebars.compile(source_grid);
            self.item_template.list = Handlebars.compile(source_list);
            self.item_template.empty = Handlebars.compile(source_blank);
            self.item_template.folder_detail = Handlebars.compile(source_folder);
            self.item_template.file_detail = Handlebars.compile(source_file);
            self.item_template._delete = Handlebars.compile(source_delete);
            self.item_template.rename = Handlebars.compile(source_rename);
            self.item_template.upload_list = Handlebars.compile(source_upload_list);

            // Bind events
            self.elem.back_button.click(function(e) {
                self.go_back();
            });

            self.elem.refresh_button.click(function(e) {
                self.refresh();
            });

            self.elem.create_button.click(function(e) {
                var new_folder_name = self.elem.create_textbox.val();
                if(new_folder_name.replace(/\s/g,"") == "") {
                    self.show_auto_message("Please enter a folder name");
                } else {
                    var new_folder_path = self.current.path + '/' + new_folder_name;
                    self.do_create_folder(new_folder_path);
                }
            });

            self.elem.search_button.click(function(e) {
                var search_term = self.elem.search_textbox.val();
                if(search_term.replace(/\s/g,"") == "") {
                    self.show_auto_message("Please enter a search term");
                } else {
                    self.current.search = search_term;
                    self.browse();
                    self.set_controls_state();
                }
            });
            self.elem.search_cancel.click(function(e) {
                self.elem.search_textbox.val('');
                self.current.search = '';
                self.browse();
                self.set_controls_state();
            });

            self.elem.toggle_layout_button.click(function(e) {
                e.preventDefault();
                self.current.layout = (self.current.layout == layouts.grid) ? layouts.list : layouts.grid;
                $.cookie('fm_layout', self.current.layout, { expires: 1 });
                self.browse();
                self.set_controls_state();
            });

            //
            self.elem.container.on("click", ".lib-folder", function(e) {
                e.preventDefault();

                self.current.path = this.rel;
                self.browse();
                self.set_controls_state();
            });
            self.elem.container.on("click", ".img-thumbs", function(e) {
                e.preventDefault();

                if (self.options.onfileclick) {
                    var info_elem = $(this);
                    self.options.onfileclick(info_elem.data("name"), info_elem.data("ext"), info_elem.data("size"), info_elem.data("path"), self.options.base_domain + info_elem.data("path"));
                }
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

            self.elem.directory_refresh.click(function(e) {
                self.build_dir_skeleton();
            });

            // Set item tooltip
            self.elem.container.tooltip({selector: ".tooltiper"});

            // load files and folders
            self.current.path = $.cookie('fm_path') || self.options.base_path;
            self.current.type = self.options.base_type;
            self.current.filter = $.cookie('fm_filter') || "";
            self.current.search = $.cookie('fm_search') || "";
            self.current.layout = $.cookie('fm_layout') || self.options.base_layout;
            self.browse();
            self.set_controls_state();

            // load upload direcory skeleton
            self.build_dir_skeleton();
            self.build_uploader();

            // tab hash navigation
            if (location.hash !== '') $('a[href="' + location.hash + '"]').tab('show');
            $('a[data-toggle="tab"]').on('click', function (e) {
                location.hash = $(e.target).attr('href').substr(1);
            });
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

            if (self.current.search == "") {
                self.elem.search_cancel.hide();
            } else {
                self.elem.search_cancel.show();
                self.elem.back_button.attr('disabled', 'disabled');
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

                        if (self.current.search == "") {
                            $.cookie('fm_search', '', { expires: 1 });
                        } else {
                            $.cookie('fm_search', self.current.path, { expires: 1 });
                        }
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
                        self.show_auto_message("Successfully deleted");
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
                        self.show_auto_message("Successfully renamed");
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
        },
        do_create_folder: function(path) {
            var self = this;
            debug(path);
            
            $.ajax({
                url: self.options.manager_path,
                data: {
                        new_folder_Name: path,
                        action: "create_folder"
                },
                type: "POST",
                cache: false,
                dataType: "json",
                success: function(data){
                    if (data.error == "success") {
                        self.show_auto_message("Folder created successfully");
                        self.refresh();
                        self.elem.create_textbox.val('');
                        self.build_dir_skeleton();
                    } else {
                        self.show_auto_message(data.error);
                    }
                },
                error: function(jqXHR, textStatus, errorThrown){
                    self.show_auto_message("Error occurred.");
                }
            });
        },
        build_dir_skeleton: function() {
            var self = this;
            
            $.ajax({
                url: self.options.dir_helper_path,
                data: {
                        new_folder_Name: self.options.base_path,
                        action: "get_skeleton"
                },
                cache: false,
                dataType: "html",
                success: function(data){
                    self.elem.directory_select.html(data);
                },
                error: function(jqXHR, textStatus, errorThrown){
                    self.show_auto_message("Error occurred.");
                }
            });
        },
        build_uploader: function() {
            var self = this;
            
            self.elem.up_drag_drop_area
            .on("dragover", function () { self.elem.up_drag_drop_area.addClass("drag-over") })
            .on("dragleave", function () { self.elem.up_drag_drop_area.removeClass("drag-over") })
            .on("drop", function () { self.elem.up_drag_drop_area.removeClass("drag-over") });
            
            self.uploader = new plupload.Uploader({
                browse_button: self.elem.up_browse_button[0],    // Browse button
                container: self.elem.up_container[0],            // Element which will contain plupload stucture
                drop_element: self.elem.up_drag_drop_area[0],    // Drop element
                url: self.options.up_url,
                flash_swf_url: self.options.up_flash_swf_url,
                silverlight_xap_url: self.options.up_silverlight_xap_url,
                file_data_name: self.options.up_file_data_name,
                chunk_size: self.options.up_chunk_size,
                filters: self.options.up_filters,
                unique_names: self.options.up_unique_names,
                init: {
                    FilesAdded: function (up, files) {
                        plupload.each(files, function (file) {
                            self.elem.up_file_list_container.append(self.item_template.upload_list(file));
                        });
                        self.uploader.settings.multipart_params = {path: self.elem.directory_select.val()};
                        self.uploader.refresh();
                        self.uploader.start();
                    },
                    FileUploaded: function (up, file, response) {
                        $("#" + file.id)
                            .find(".progress-text")
                            .text("Done")
                            .parent()
                            .prevAll(".entry:first")[0].href = jQuery.parseJSON(response.response).result;
                    },
                    UploadProgress: function (up, file) {
                        $("#" + file.id).find(".bar").css({ width: file.percent + "%" }).next().text(file.percent + "%");
                    },
                    UploadComplete: function (up, file) {
                        self.refresh();
                    },
                    Error: function (up, err) {
                        self.elem.up_error.html("Error #" + err.code + ": " + err.message);
                    }
                }
            });

            self.uploader.init();
        }
    };

    window.$app = $app;
})(window);

$(function(){
    window.$app.init({
        onfileclick: function(name){
            debug('NAME => ' + name);
        }
    });
});