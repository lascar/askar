/*jslint browser: true, nomen: true*/
/*global $, jQuery*/
// http://jsperf.com/jquery-vs-createelement
// depiste of that we use a mixt with jquery for compatibility in browsers
var Lascar = {
  displayTab: function () {
    'use strict';
    Lascar.desactiveTabs();
    var tab = $("<div id='tab_" + Lascar.controller + "_" + Lascar.action + "_" + Lascar.element_name + "'></div>");
    tab.addClass('tab active');
    tab.html(Lascar.controller + "<br>" + Lascar.action + "<br>" + Lascar.element_name);
    $("#tabs").append(tab);
  },

  desactiveTabs: function () {
    'use strict';
    $(".tab").removeClass("active");
    $(".tab_content").removeClass("active").addClass("inactive");
  },

  displayTabContent: function () {
    'use strict';
    var tab_content = $("<div id='tab_content_" + Lascar.controller + "_" + Lascar.action + "_" + Lascar.element_name + "' class='tab_content active'></div>");
    var element_raw, field_content_div, link_action;
    $.each(Lascar.elements, function (index, element) {
      element_raw = Lascar.rawBuild(element.id);
      $.each(Lascar.fields_to_show, function (index, field) {
        field_content_div = Lascar.fieldBuild(element, field);
        element_raw.append(field_content_div);
      });
      $.each(Lascar.actions, function (index, action) {
        link_action = Lascar.buildLinkAction(element, action);
        element_raw.append(link_action);
      });
      tab_content.append(element_raw);
      $("#tabs_contents").append(tab_content);
    });
  },

  fieldBuild: function (element, field) {
    'use strict';
    var field_content_div = $("<div id='" + Lascar.controller + "_" + element.id + "_ " + field + "'></div>");
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

  buildLinkAction: function (element, action) {
    'use strict';
    var div_action, link_action;
    div_action = $("<div id='div_link_" + Lascar.controller + "_" + action + "_" + element.id + "'></div>");
    div_action.addClass("div_link_" + action + " field");
    link_action = $("<a id='link_" + Lascar.controller + "_" + action + "_" + element.id + "'>" + action + "</a>");
    link_action.addClass("link_" + action);
    link_action.on('click', function () { Lascar.lauchAction(element.id, action); });
    div_action.append(link_action);
    return div_action;
  },

  lauchAction: function (element_id, action) {
    'use strict';
    $.ajax({
      url: Lascar.controller + "/" + action + "/" + element_id,
      type: "POST",
      dataType: 'script'
    });
  }
}

