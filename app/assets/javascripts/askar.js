/*jslint browser: true, nomen: true*/
// an object Askar constructs is model with the attributes that is receive
// ex. receive {serie_name: "elements", object_name: "element", object_attributes: ["name", "description", "weight"], actions: ["show", {edit: ["update"]}], values: [{id: 1, name: "element 1", description: "first element", weight: 25}, {id: 2, name: "element 2", description: "second element", weight: 34}], attributes_show_series: ["name", "descripcion"], attributes_show_object: ["id", "name", "description", "weight"], page: 2, total_pages: 4}
var Askar = {
    received: {},
    serie_name: function () {
        'use strict';
        return this.received ? this.received.serie_name : "default_serie_name";
    },
    object_name: function () {
        'use strict';
        return this.received ? this.received.object_name : "default_object_name";
    },
    object_attributes: function () {
        'use strict';
        return this.received ? this.received.object_attributes : "default_object_attributes";
    },
    actions: function () {
        'use strict';
        return this.received ? this.received.actions : "default_actions";
    },
    values: function () {
        'use strict';
        return this.received ? this.received.values : "default_values";
    },
    attributes_show_series: function () {
        'use strict';
        return this.received ? this.received.attributes_show_series : "default_attributes_show_series";
    },
    attributes_show_object: function () {
        'use strict';
        return this.received ? this.received.attributes_show_object : "default_attributes_show_object";
    },
    page: function () {
        'use strict';
        return this.received ? this.received.page : "default_page";
    },
    total_pages: function () {
        'use strict';
        return this.received ? this.received.total_pages : "default_total_pages";
    },
    view_series: function () {
    },
    view_object: function(id){
    },
// ex. receive {serie_name: "elements", object_name: "element", object_attributes: ["name", "description", "weight"], actions: ["show", {edit: ["update"]}], values: [{id: 1, name: "element 1", description: "first element", weight: 25}, {id: 2, name: "element 2", description: "second element", weight: 34}], attributes_show_series: ["name", "descripcion"], attributes_show_object: ["id", "name", "description", "weight"], page: 2, total_pages: 4}

    displayTab: function (type, object_id) {
        'use strict';
        var tab_id, content, tab;
        tab_id = type !== "serie" ? this.object_name() + "_" + object_id : this.serie_name() + "_" + this.page();
        content = type !== "serie" ? this.object_name() + " " + object_id : this.serie_name() + "<br>" + "page " + this.page();

        var tab, tab_width, suffix, class_names, match, action;
        id = id || Askar.urlToId();
        element_id = element_id || "";
        suffix =  Askar.action + (element_id ? "_" + Askar.element.id : "");
        content = content || Askar.controller + "<BR>" + suffix;
        tab =  Askar.createOrActiveNode("tab_", id, "tabs", element_id);
        if (tab !== -1) {
            class_names = tab.className || "";
            tab.className = class_names + " tab";
            tab_width = Askar.controller.length > suffix.length ? (Askar.controller.length + 10) : (suffix.length + 10);
            tab.style.width = tab_width + "px";
            // set the width for ie78
            tab.onclick = function () {
                match = this.id.match(/^tab_([a-z]*)(?:_(\d*))?/);
                id = match ? match[1] : "";
                element_id = match ? match[2] : "";
                action = Askar.extractActionFromId(this.id);
                Askar.executeResponse(id, element_id);
          };
          tab.innerHTML = content;
        }
    },
    displayTabContentShow: function (id, element_id) {
        'use strict';
        var tab_content, i, field, suffix, content, field_raw_id, field_raw, label_field_raw_id, text_field_raw_id;
        id = id || Askar.urlToId();
        element_id = element_id || "_" + Askar.element.id;
        Askar.desactiveChildren("tabs_contents");
        tab_content =  Askar.createOrActiveNode("", id, "tabs_contents", element_id);
        if (tab_content !== -1) {
          tab_content.className += ' tab_content';
          for (i = 0; i < Askar.fields_to_show.length; i += 1) {
            field = Askar.fields_to_show[i];
            suffix = Askar.element ? "_" + Askar.element.id + "_" + field : "_" + field;
            field_raw_id = Askar.urlToId() + suffix;
            label_field_raw_id = Askar.urlToId() + suffix + "_label";
            text_field_raw_id =  Askar.urlToId() + suffix + "_" + field + "_text";
            field_raw = Askar.createDiv(field_raw_id, tab_content.id, "field_raw " + field);
            Askar.createDiv(label_field_raw_id, field_raw_id, "field label " + field, field);
            content = Askar.element ? Askar.element[field] : '';
            Askar.createDiv(text_field_raw_id, field_raw_id, "field text " + field, content);
          }
        }
      },

    displayTabContentList: function (id) {
        'use strict';
        var i, j, element, field, action, element_raw, field_content_div, tab_content;
        id = id || Askar.urlToId();
        tab_content = Askar.createOrActiveNode("", id, "tabs_contents", "");
        if (tab_content !== -1) {
          tab_content.className += ' tab_content';
          for (i = 0; i < Askar.elements.length; i += 1) {
            element = Askar.elements[i];
            element_raw = Askar.createDiv("element_raw_" + element.id, tab_content.id, "element_raw");
            for (j = 0; j < Askar.fields_to_show.length; j += 1) {
              field = Askar.fields_to_show[j];
              field_content_div = Askar.createDiv(Askar.urlToId() + "_" + element.id, element_raw.id, "field " + field, element[field]);
            }
            for (j = 0; j < Askar.actions.length; j += 1) {
              action = Askar.actions[j];
              Askar.buildLinkAction(element, action, element_raw.id);
            }
          }
        }
    },

};
var elements = Object.create(Askar);
elements.received = {serie_name: "elements", object_name: "element", object_attributes: ["name", "description"], actions: ["show", {edit: ["update"]}], values: [{name: "element 1", description: "first element"}, {name: "element 2", description: "second element"}]};
