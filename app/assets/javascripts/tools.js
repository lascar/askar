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
      }

   }
}
