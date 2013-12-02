/*jslint browser: true, nomen: true*/
/*global $, jQuery*/
var Lascar = {
  readResponse: function (data) {
    'use strict';
    console.log(data);
    Lascar.controller = data.controller;
    Lascar.action = data.action;
    Lascar.elements = data.elements;
    Lascar.fields = data.fields;
    Lascar.fields_to_show = data.fields_to_show;
    Lascar.element = data.element;
    Lascar.actions = data.actions;
    Lascar.executeResponse(Lascar.action);
  },
  executeResponse: function (action) {
    "use strict";
    Lascar.displayTab();
    var actions = {
      'list': function () {return Lascar.displayTabContentList(); },
      'show': function () {return Lascar.displayTabContentShow(); }
    };
    try {return actions[action](); }
    catch (err) {return false; }
  },

  displayTab: function () {
    'use strict';
    var tab_width, suffix = Lascar.action === "show" ? "_" + Lascar.element.id : "",
      tab = Lascar.createOrActiveNode("tab_", suffix, "tabs");
    tab.setAttribute('class', 'tab active');
    tab_width = Lascar.controller.length > suffix.length ? Lascar.controller.length + 10 : suffix.length + 10;
    // set the width for ie78
    tab.innerHTML = Lascar.controller + "<br>" + Lascar.action + suffix;
  },

  createDiv: function (id_name, parent_id, class_name, content) {
    'use strict';
    var text_node, new_div = document.createElement('div'), div_parent = document.getElementById(parent_id);
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

  toogleClass: function (element, old_class, new_class) {
    'use strict';
    element.className = element.className.replace(old_class, new_class);
  },

  desactiveChildren: function (parent_id) {
    'use strict';
    var i, child_nodes = document.getElementById(parent_id).children;
    if (child_nodes) {
      for (i = 0; i < child_nodes.length; i += 1) {
        if (!/inactive/.test(child_nodes[i].className)) {
          Lascar.toogleClass(child_nodes[i], /active/, "inactive");
        }
      }
    }
  },

  createOrActiveNode: function (prefix, suffix, parent_id) {
    'use strict';
    var node, class_names, id = prefix + Lascar.controller + "_" + Lascar.action + suffix;
    Lascar.desactiveChildren(parent_id);
    node = document.getElementById(id) || this.createDiv(id, parent_id);
    // for ie7-8
    class_names = node.className || "";
    if (/inactive/.test(class_names)) {
      Lascar.toogleClass(node, "inactive", "active");
    } else {
      node.className = class_names + " active";
    }
    return node;
  },

  displayTabContentShow: function () {
    'use strict';
    var tab_content, i, field, field_raw_id, field_raw, label_field_raw_id, text_field_raw_id;
    Lascar.desactiveChildren("tabs_contents");
    tab_content =  Lascar.createOrActiveNode("", "", "tabs_contents");
    tab_content.className += ' tab_content';
    for (i = 0; i < Lascar.fields_to_show.length; i += 1) {
      field = Lascar.fields_to_show[i];
      field_raw_id = Lascar.controller + "_" + Lascar.action + "_" + Lascar.element.id + "_" + field;
      label_field_raw_id = Lascar.controller + "_" + Lascar.action + "_" + Lascar.element.id + "_" + field + "_label";
      text_field_raw_id =  Lascar.controller + "_" + Lascar.action + "_" + Lascar.element.id + "_" + field + "_text";
      field_raw = Lascar.createDiv(field_raw_id, tab_content.id, "field_raw " + field);
      Lascar.createDiv(label_field_raw_id, field_raw_id, "label " + field, field);
      Lascar.createDiv(text_field_raw_id, field_raw_id, "text " + field, Lascar.element[field]);
    }
  },

  displayTabContentList: function () {
    'use strict';
    var i, j, element, field, action, element_raw, field_content_div, link_action,
      tab_content = Lascar.createOrActiveNode("", "", "tabs_contents");
    tab_content.className += ' tab_content';
    for (i = 0; i < Lascar.elements.length; i += 1) {
      element = Lascar.elements[i];
      element_raw = Lascar.createDiv("element_raw_" + element.id, tab_content.id, "element_raw");
      for (j = 0; j < Lascar.fields_to_show.length; j += 1) {
        field = Lascar.fields_to_show[j];
        field_content_div = Lascar.createDiv(Lascar.controller + "_" + Lascar.action + "_" + element.id, element_raw.id, "field " + field, element[field]);
      }
      for (j = 0; j < Lascar.actions.length; j += 1) {
        action = Lascar.actions[j];
        Lascar.buildLinkAction(element, action, element_raw.id);
      }
    }
  },

  buildLinkAction: function (element, action, parent_id) {
    'use strict';
    var div_action, link_action;
    div_action = Lascar.createDiv("div_link_" + Lascar.controller + "_" + action + "_" + element.id, parent_id, "div_link_" + action + " field");
    link_action = Lascar.createDiv("link_" + Lascar.controller + "_" + action + "_" + element.id, div_action.id, "link_" + action, action);
    link_action.onclick = function () { Lascar.lauchAction(element.id, action); };
  },

  getCsrfToken: function () {
    'use strict';
    var i, csrf_token, array_meta_tag = document.getElementsByTagName('meta');
    for (i = 0; i < array_meta_tag.length; i += 1) {
      if (array_meta_tag[i].getAttribute('name') === "csrf-token") {
        return array_meta_tag[i].getAttribute('content');
      }
    }
  },

  lauchAction: function (element_id, action) {
    'use strict';
    var jsonresp, csrf_token = Lascar.getCsrfToken(),
      xmlhttp = Lascar.ajaxRequest();
    xmlhttp.onreadystatechange = function () {
      if (xmlhttp.readyState == 4 && xmlhttp.status == 200) {
        jsonresp = xmlhttp.responseText;
        Lascar.readResponse(JSON.parse(jsonresp));
      }
    }
    xmlhttp.open('POST', Lascar.controller + '/' + action + '/' + element_id, true);
    xmlhttp.setRequestHeader('X-CSRF-Token', csrf_token);
    xmlhttp.send();
  },

  ajaxRequest: function () {
    'use strict';
    var activexmodes=["Msxml2.XMLHTTP", "Microsoft.XMLHTTP"]
    if (window.ActiveXObject){ 
     for (var i=0; i<activexmodes.length; i++){
      try{
       return new ActiveXObject(activexmodes[i])
      }
      catch(e){
      }
     }
    } else if (window.XMLHttpRequest) {
     return new XMLHttpRequest();
    } else {
     return false
   }
  }
}



