/*jslint browser: true, nomen: true*/
// crockford good part ch1
// define new method
// Number.method('integer', function ( ) {
//     return Math[this < 0 ? 'ceil' : 'floor'](this);
// };
// document.writeln((-10 / 3).integer( ));

Function.prototype.method = function (name, func) {
    if (!this.prototype[name]) {
        this.prototype[name] = func;
        return this;
    }
};
// crockford gp ch3
//create an object directly from an other object
if (typeof Object.create !== 'function') {
     Object.create = function (o) {
         var F = function () {};
         F.prototype = o;
         return new F();
     };
};
var Tools = {
    //zacas childNodes for ie8- count the white space between elements as element
    getChildren: function (node) {
        var i, len, array = [], childs = node.childNodes;
        for (i = 0; i < childs.length; i += 1) {
            if (childs[i].nodeType == 1){
                array.push(childs[i]);
            }
        }
        return array;
    },

    toogleClass: function (element, old_class, new_class) {
       'use strict';
       element.className = element.className.replace(old_class, new_class);
     },

    createDiv: function (id_name, parent_id, class_name, content) {
        'use strict';
        var text_node, new_div = document.createElement('div'), div_parent = document.querySelector(parent_id);
        new_div.setAttribute('id', id_name);
        if (class_name) {
            new_div.setAttribute('class', class_name);
        }
        if (parent_id && parent_id !== "" && div_parent) {
            div_parent.appendChild(new_div);
        }
        if (content && div_parent) {
            text_node = document.createTextNode(content);
            new_div.appendChild(text_node);
        }
        return new_div;
    },

    desactiveChildren: function (parent_id) {
        'use strict';
        var i, child_nodes = Tools.getChildren(document.querySelector(parent_id));
        if (child_nodes) {
            for (i = 0; i < child_nodes.length; i += 1) {
                if (!/inactive/.test(child_nodes[i].className)) {
                    Tools.toogleClass(child_nodes[i], /active/, "inactive");
                }
            }
        }
    },

    createOrActiveNode: function (prefix, id, parent_id, element_id){
        'use strict';
        var node, class_names;
        element_id = element_id ? "_" + element_id : "";
        Tools.desactiveChildren(parent_id);
        node = document.querySelector(prefix + id + element_id);
        if (!node) {
            node = this.createDiv(prefix + id + element_id, parent_id);
            class_names = node.className || "";
            if (/inactive/.test(class_names)) {
                Tools.toogleClass(node, "inactive", "active");
            } else {
                node.className = class_names + " active";
            }
            return node;
        } else {
            Tools.toogleClass(node, "inactive", "active");
            return -1;
        }
    },

    lauchAction: function (url, method) {
        'use strict';
        var jsonresp, csrf_token = Askar.getCsrfToken(), xmlhttp;
        method = method || 'GET';
        xmlhttp = Askar.ajaxRequest();
        xmlhttp.open(method, url, true);
        xmlhttp.setRequestHeader('X-CSRF-Token', csrf_token);
        xmlhttp.send();
        xmlhttp.onreadystatechange = function () {
            if (xmlhttp.readyState === 4 && xmlhttp.status === 200) {
                jsonresp = xmlhttp.responseText;
                Tool.readResponse(Askar.parseJson(jsonresp));
            }
        };
    },

    ajaxRequest: function () {
        'use strict';
        var i, activexmodes = ["Msxml2.XMLHTTP", "Microsoft.XMLHTTP"];
        if (window.ActiveXObject) {
            for (i = 0; i < activexmodes.length; i += 1) {
                try {
                    return new ActiveXObject(activexmodes[i]);
                }
                catch (ignore) { }
            }
        } else if (window.XMLHttpRequest) {
            return new XMLHttpRequest();
        } else {
            return false;
        }
    },

    parseJson: function (jsonString) {
        try {
            return JSON.parse(jsonString);
        } catch (ex) {
            return eval('(' + jsonString + ')');
        }
    },

    getElementById: function (string) {
        if (typeof(document.querySelector) === "ifunction") {
            return document.querySelector(string);
        } else {
            return document.getElementById(string.replace(/^#/, ""));
        }
    },

    bindEvent: function (element, eventName, eventHandler) {
        if (typeof(element["addEventListener"] === "function")) {
            element.addEventListener(eventName, eventHandler, false);
        } else {
            element.attachEvent('on'+eventName, eventHandler);
        }
    }

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
        },

    // ex. receive {serieName: "elements", objectName: "element", objectAttributes: ["name", "description", "weight"], actions: ["show", {edit: ["update"]}], values: [{id: 1, name: "element 1", description: "first element", weight: 25}, {id: 2, name: "element 2", description: "second element", weight: 34}], attributesShowSeries: ["name", "descripcion"], attributesShowObject: ["id", "name", "description", "weight"], page: 2, totalPages: 4}

    showSeries (page, totalInPage) {
        // verify if serie was update in the server else update serie
        // verify if page exists and uptodate else create or update
        // verify if tab exists else create
        // display page
    },

    isSerieUpToDate () {
        // verify in the server if this.upToDate
    }

}
