/*jslint browser: true, nomen: true*/
var Askar = {
  idUrlAction: function (orden, valor) {
    var idUrl = {
      aaaa: 'elements/list',
      aaab: 'elements/show'
    };
    var idAction = {
      aaaa: 'list',
      aaab: 'show'
    };
    var idToUrl = function (valor) {
      return idUrl[valor];
    };
    var idToAction = function (valor) {
      return idAction[valor];
    };
    var urlToId = function (valor) {
      for (var key in idUrl) {
        if (idUrl[key] === valor) {
          return key;
        }
      };
    };
    var translate = {
      'idToUrl' : function () { return idToUrl(valor) },
      'idToAction' : function () { return idToAction(valor) },
      'urlToId' : function () { return urlToId(valor) }
    }  
    try { return translate[orden](); }
    catch(err) {return false; }
  },

  idToUrl: function (id, element_id) {
    'use strict';
    var suffix = element_id ? '/' + element_id : '';
    var url = Askar.idUrlAction("idToUrl", id);
    return url + suffix;
  },
  
  urlToId: function (url) {
    'use strict';
    var url_intern = url ? url : Askar.controller + '/' + Askar.action;
    return Askar.idUrlAction("urlToId", url_intern);
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
    Askar.id = Askar.urlToId(Askar.controller + "/" + Askar.action);
    Askar.element_id = Askar.element ? Askar.element.id : "";
    Askar.executeResponse(Askar.id, Askar.element_id);
  },

  extractActionFromId: function (id) {
    var url = Askar.idToUrl(id.replace(/(?:^tab_)?([a-z]{4})(:?_\d*)?/, "$1"));
    return url ? url.replace(/^\w*\/(w*)/, "$1") : "";
  },
 
  executeResponse: function (id, element_id) {
    "use strict";
    var action = Askar.extractActionFromId(id);
    Askar.displayTab(id, element_id);
    var actions = {
      'list': function () {return Askar.displayTabContentList(id); },
      'show': function () {return Askar.displayTabContentShow(id, element_id); }
    };
    try {return actions[action](); }
    catch (ignore) { }
  },

  displayTab: function (id, element_id, content) {
    'use strict';
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
    var i, child_nodes = Tools.getChildren(document.getElementById(parent_id));
    if (child_nodes) {
      for (i = 0; i < child_nodes.length; i += 1) {
        if (!/inactive/.test(child_nodes[i].className)) {
          Askar.toogleClass(child_nodes[i], /active/, "inactive");
        }
      }
    }
  },

  createOrActiveNode: function (prefix, id, parent_id, element_id){
    'use strict';
    var node, class_names;
    element_id = element_id ? "_" + element_id : "";
    Askar.desactiveChildren(parent_id);
    node = document.getElementById(prefix + id + element_id);
    if (!node) {
       node = this.createDiv(prefix + id + element_id, parent_id);
      class_names = node.className || "";
      if (/inactive/.test(class_names)) {
        Askar.toogleClass(node, "inactive", "active");
      } else {
        node.className = class_names + " active";
      }
      return node;
    } else {
      Askar.toogleClass(node, "inactive", "active");
      return -1;
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

  buildLinkAction: function (element, action, parent_id) {
    'use strict';
    var div_action, link_action, id, url, action_name = action.replace(/[a-z_]*\/([a-z]*)/, "$1");
    id = Askar.urlToId(action);
    div_action = Askar.createDiv("div_link_" + Askar.urlToId(action) + "_" + element.id, parent_id, "div_link_" + action_name + " field");
    link_action = Askar.createDiv("link_" + Askar.urlToId(action) + "_" + element.id, div_action.id, "link_" + action_name, action_name);
    url = Askar.idToUrl(id, element.id);
    link_action.onclick = function () { Askar.lauchAction(url); };
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

  lauchAction: function (url) {
    'use strict';
    var jsonresp, csrf_token = Askar.getCsrfToken(), xmlhttp;
    //url = element_id === -1 ? Askar.controller + '/' + action : Askar.controller + '/' + action + '/' + element_id;
    xmlhttp = Askar.ajaxRequest();
    xmlhttp.open('POST', url, true);
    xmlhttp.setRequestHeader('X-CSRF-Token', csrf_token);
    xmlhttp.send();
    xmlhttp.onreadystatechange = function () {
      if (xmlhttp.readyState === 4 && xmlhttp.status === 200) {
        jsonresp = xmlhttp.responseText;
        Askar.readResponse(Askar.parseJson(jsonresp));
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
      if (Askar.detectBrowser()) {
          return eval('(' + jsonString + ')');
      }
      else {
          return JSON.parse(jsonString);
      }
  },

  detectBrowser: function () {
    var ua =navigator.userAgent, re = /MSIE ([\d])/, match = ua.match(re);
    if (match && match[1] <= 8) {
      return true;
    } else {
      return false;
    }
  }

};

