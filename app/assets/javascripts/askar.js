/*jslint browser: true, nomen: true*/
var Askar = {
  tableIdToUrl: {
    aaaa: 'elements/list',
    aaab: 'element/show'
  },

  tableUrlToId: {
    elements_list: 'aaaa',
    elements_show: 'aaab'
  },

  idToUrl: function (id, element_id) {
    'use strict';
    var url = tableIdToUrl[id] + (element_id ? '/' + element_id : '');
    return ;
  },
  
  urlToId: function (url) {
    'use strict';
    var url_intern = url ? url : Askar.controller + '_' + Askar.action;
    return Askar.tableUrlToId[url_intern];
  },

  readResponse: function (data) {
    'use strict';
    Askar.controller = data.controller;
    Askar.action = data.action;
    Askar.elements = data.elements;
    Askar.fields = data.fields;
    Askar.fields_to_show = data.fields_to_show;
    Askar.element = data.element;
    Askar.actions = data.actions;
    Askar.executeResponse(Askar.action);
  },

  executeResponse: function (action) {
    "use strict";
    Askar.displayTab();
    var actions = {
      'list': function () {return Askar.displayTabContentList(); },
      'show': function () {return Askar.displayTabContentShow(); }
    };
    try {return actions[action](); }
    catch (ignore) { }
  },

  displayTab: function () {
    'use strict';
    var tab_width, suffix = Askar.action === "show" ? "_" + Askar.element.id : "",
      tab = Askar.createOrActiveNode("tab_", suffix, "tabs");
    tab.setAttribute('class', 'tab active');
    tab_width = Askar.controller.length > suffix.length ? Askar.controller.length + 10 : suffix.length + 10;

    // set the width for ie78
    tab.onclick = function () {
      Askar.switchOrCreateTab(tab);
    };
    tab.innerHTML = Askar.controller + "<br>" + Askar.action + suffix;
  },

  switchOrCreateTab: function (tab) {
    console.log(tab);
    //Askar.lauchAction(Askar.element ? Askar.element.id : -1, Askar.action);
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
          Askar.toogleClass(child_nodes[i], /active/, "inactive");
        }
      }
    }
  },

  createOrActiveNode: function (prefix, suffix, parent_id) {
    'use strict';
    var node, class_names, id = prefix + Askar.urlToId() + suffix;
    Askar.desactiveChildren(parent_id);
    node = document.getElementById(id) || this.createDiv(id, parent_id);
    // for ie7-8
    class_names = node.className || "";
    if (/inactive/.test(class_names)) {
      Askar.toogleClass(node, "inactive", "active");
    } else {
      node.className = class_names + " active";
    }
    return node;
  },

  displayTabContentShow: function () {
    'use strict';
    var tab_content, i, field, suffix, content, field_raw_id, field_raw, label_field_raw_id, text_field_raw_id;
    Askar.desactiveChildren("tabs_contents");
    tab_content =  Askar.createOrActiveNode("", "", "tabs_contents");
    tab_content.className += ' tab_content';
    for (i = 0; i < Askar.fields_to_show.length; i += 1) {
      field = Askar.fields_to_show[i];
      suffix = Askar.element ? "_" + Askar.element.id + "_" + field : "_" + field;
      field_raw_id = Askar.urlToId() + suffix;
      label_field_raw_id = Askar.urlToId() + suffix + "_label";
      text_field_raw_id =  Askar.urlToId() + suffix + "_" + field + "_text";
      field_raw = Askar.createDiv(field_raw_id, tab_content.id, "field_raw " + field);
      Askar.createDiv(label_field_raw_id, field_raw_id, "label " + field, field);
      content = element ? Askar.element[field] : '';
      Askar.createDiv(text_field_raw_id, field_raw_id, "text " + field, content);
    }
  },

  displayTabContentList: function () {
    'use strict';
    var i, j, element, field, action, element_raw, field_content_div,
      tab_content = Askar.createOrActiveNode("", "", "tabs_contents");
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

  buildLinkAction: function (element, action, parent_id) {
    'use strict';
    var div_action, link_action;
    div_action = Askar.createDiv("div_link_" + Askar.urlToId() + "_" + element.id, parent_id, "div_link_" + action + " field");
    link_action = Askar.createDiv("link_" + Askar.urlToId(Askar.controller + "_" + action) + "_" + element.id, div_action.id, "link_" + action, action);
    link_action.onclick = function () { Askar.lauchAction(element.id, action); };
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

  lauchAction: function (element_id, action) {
    'use strict';
    var url, jsonresp, csrf_token = Askar.getCsrfToken(), xmlhttp;
    url = element_id === -1 ? Askar.controller + '/' + action : Askar.controller + '/' + action + '/' + element_id;
    xmlhttp = Askar.ajaxRequest();
    xmlhttp.open('POST', Askar.controller + '/' + action + '/' + element_id, true);
    xmlhttp.setRequestHeader('X-CSRF-Token', csrf_token);
    xmlhttp.send();
    xmlhttp.onreadystatechange = function () {
      if (xmlhttp.readyState === 4 && xmlhttp.status === 200) {
        jsonresp = xmlhttp.responseText;
        Askar.readResponse(JSON.parse(jsonresp));
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
  }
};

