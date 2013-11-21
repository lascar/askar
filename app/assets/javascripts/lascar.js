/*jslint browser: true, nomen: true*/
/*global $, jQuery*/
// http://jsperf.com/jquery-vs-createelement
// depiste of that we use a mixt with jquery for compatibility in browsers
var Lascar = {
  displayTab: function (action, element_name) {
    'use strict';
    Lascar.desactiveTabs();
    var tab = $("<div id='tab_" + action + "_" + element_name + "' class='tab active'></div>");
    tab.html(action + "<br>" + element_name);
    $("#tabs").append(tab);
  },

  desactiveTabs: function () {
    $(".tab").removeClass("active");
    $(".tab_content").removeClass("active").addClass("inactive");
  },

  displayTabContentList: function (element_name, fields, fields_to_show, elements) {
    'use strict';
    var tab_content = $("<div id='tab_content_" + element_name + "' class='tab_content active'></div>");
    var element_raw, field_content_div, link_action;
    $.each(elements, function (index, element) {
      element_raw = Lascar.rawBuild(element.id);
      $.each(fields_to_show, function (index, field) {
        field_content_div = Lascar.fieldBuild(element_name, element, field);
        element_raw.append(field_content_div);
      });
      $.each(Lascar.actions, function (index, action) {
        link_action = Lascar.buildLinkAction(element_name, action, element);
        element_raw.append(link_action);
      });
      tab_content.append(element_raw);
      $("#tabs_contents").append(tab_content);
    });
  },

  fieldBuild: function (element_name, element, field) {
    'use strict';
    var field_content_div = $("<div id='" + element_name + "_" + element.id + "_ " + field + "'></div>");
    field_content_div.addClass("field " + field);
    field_content_div.text(element[field]);
    return field_content_div;
  },

  rawBuild: function (id) {
    'use strict';
    var element_raw = $("<div id='element_raw_" + id + "'></div>");
    element_raw.addClass("element_raw");
    return element_raw;
  },

  buildLinkAction: function (element_name, action, element) {
    'use strict';
    var div_action, link_action;
    div_action = $("<div id='" + element_name + "_" + element.id + "_" + action + "'></div>");
    div_action.addClass("div_link_" + element_name + "_" + action + " field");
    link_action = $("<a id='link_" + element_name + "_" + element.id + "_" + action + "'>" + action + "</a>");
    link_action.addClass("link_" + element_name + "_" + action);
    link_action.on('click', function () { Lascar.lauchAction(element_name, action, element.id); });
    div_action.append(link_action);
    return div_action;
  },

  lauchAction: function (element_name, action, element_id) {
    'use strict';
    $.ajax({
      url: "/home/" + action + "/" + element_name + "/" + element_id,
      type: "POST",
      dataType: 'script'
    });
  }
}
