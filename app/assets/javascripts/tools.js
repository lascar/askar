/*jslint browser: true, nomen: true*/
// crockford good part ch1
// define new method
// Number.method('integer', function ( ) {
//     return Math[this < 0 ? 'ceil' : 'floor'](this);
// };
// document.writeln((-10 / 3).integer( ));

Function.prototype.method = function (name, func) {
    'use strict';
    if (!this.prototype[name]) {
        this.prototype[name] = func;
        return this;
    }
};
// crockford gp ch3
//create an object directly from an other object
if (typeof Object.create !== 'function') {
    Object.create = function (o) {
        'use strict';
        var F = function () { return; };
        F.prototype = o;
        return new F();
    };
};
var Tools = {
    //zacas childNodes for ie8- count the white space between elements as element
    getChildren: function (node) {
        'use strict';
        var i, array = [], childs = node.childNodes;
        for (i = 0; i < childs.length; i += 1) {
            if (childs[i].nodeType === 1) {
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

    createOrActiveNode: function (prefix, id, parent_id, element_id) {
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
        }
        Tools.toogleClass(node, "inactive", "active");
        return -1;
    },

    lauchAction: function (url, whatNext, method, data) {
        'use strict';
        var jsonresp, csrf_token = Tools.getCsrfToken(), xmlhttp;
        method = method || 'GET';
        xmlhttp = Tools.ajaxRequest();
        xmlhttp.open(method, url, true);
        xmlhttp.setRequestHeader('X-CSRF-Token', csrf_token);
        if (method === 'GET') {
            xmlhttp.send();
        } else {
            xmlhttp.send(data);
        }
        xmlhttp.onreadystatechange = function () {
            if (xmlhttp.readyState === 4 && xmlhttp.status === 200) {
                jsonresp = xmlhttp.responseText;
                return this.whatNext(whatNext, Tools.whatNext(jsonresp));
            }
        };
    },

    getCsrfToken: function () {
        'use strict';
        var i, array_meta_tag = document.getElementsByTagName('meta');
        for (i = 0; i < array_meta_tag.length; i += 1) {
            if (array_meta_tag[i].getAttribute('name') === "csrf-token") {
                return array_meta_tag[i].getAttribute('content');
            }
        }
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
        'use strict';
        try {
            return JSON.parse(jsonString);
        } catch (ex) {
            return eval('(' + jsonString + ')');
        }
    },

    getElementById: function (string) {
        'use strict';
        if (typeof (document.querySelector) === "ifunction") {
            return document.querySelector(string);
        }
        return document.getElementById(string.replace(/^#/, ""));
    },

    bindEvent: function (element, eventName, eventHandler) {
        'use strict';
        if (typeof (element.addEventListener === "function")) {
            element.addEventListener(eventName, eventHandler, false);
        } else {
            element.attachEvent('on' + eventName, eventHandler);
        }
    },

    displayTab: function (type, object_id) {
        'use strict';
        var tab_id, content, tab, id, element_id, tab_width, suffix, class_names, match, action;
        tab_id = type !== "serie" ? this.object_name() + "_" + object_id : this.serie_name() + "_" + this.page();
        content = type !== "serie" ? this.object_name() + " " + object_id : this.serie_name() + "<br>" + "page " + this.page();
        id = id || Tools.urlToId();
        element_id = element_id || "";
        suffix =  Tools.action + (element_id ? "_" + Tools.element.id : "");
        content = content || Tools.controller + "<BR>" + suffix;
        tab =  Tools.createOrActiveNode("tab_", id, "tabs", element_id);
        if (tab !== -1) {
            class_names = tab.className || "";
            tab.className = class_names + " tab";
            tab_width = Tools.controller.length > suffix.length ? (Tools.controller.length + 10) : (suffix.length + 10);
            tab.style.width = tab_width + "px";
            // set the width for ie78
            tab.onclick = function () {
                match = this.id.match(/^tab_([a-z]*)(?:_(\d*))?/);
                id = match ? match[1] : "";
                element_id = match ? match[2] : "";
                action = Tools.extractActionFromId(this.id);
                Tools.executeResponse(id, element_id);
            };
            tab.innerHTML = content;
        }
    },
    
    displayTabContentShow: function (id, element_id) {
        'use strict';
        var tab_content, i, field, suffix, content, field_raw_id, field_raw, label_field_raw_id, text_field_raw_id;
        id = id || Tools.urlToId();
        element_id = element_id || "_" + Tools.element.id;
        Tools.desactiveChildren("tabs_contents");
        tab_content =  Tools.createOrActiveNode("", id, "tabs_contents", element_id);
        if (tab_content !== -1) {
            tab_content.className += ' tab_content';
            for (i = 0; i < Tools.fields_to_show.length; i += 1) {
                field = Tools.fields_to_show[i];
                suffix = Tools.element ? "_" + Tools.element.id + "_" + field : "_" + field;
                field_raw_id = Tools.urlToId() + suffix;
                label_field_raw_id = Tools.urlToId() + suffix + "_label";
                text_field_raw_id =  Tools.urlToId() + suffix + "_" + field + "_text";
                field_raw = Tools.createDiv(field_raw_id, tab_content.id, "field_raw " + field);
                Tools.createDiv(label_field_raw_id, field_raw_id, "field label " + field, field);
                content = Tools.element ? Tools.element[field] : '';
                Tools.createDiv(text_field_raw_id, field_raw_id, "field text " + field, content);
            }
        }
    },

    displayTabContentList: function (id) {
        'use strict';
        var i, j, element, field, action, element_raw, field_content_div, tab_content;
        id = id || Tools.urlToId();
        tab_content = Tools.createOrActiveNode("", id, "tabs_contents", "");
        if (tab_content !== -1) {
            tab_content.className += ' tab_content';
            for (i = 0; i < Tools.elements.length; i += 1) {
                element = Tools.elements[i];
                element_raw = Tools.createDiv("element_raw_" + element.id, tab_content.id, "element_raw");
                for (j = 0; j < Tools.fields_to_show.length; j += 1) {
                    field = Tools.fields_to_show[j];
                    field_content_div = Tools.createDiv(Tools.urlToId() + "_" + element.id, element_raw.id, "field " + field, element[field]);
                }
                for (j = 0; j < Tools.actions.length; j += 1) {
                    action = Tools.actions[j];
                    Tools.buildLinkAction(element, action, element_raw.id);
                }
            }
        }
    }
}
