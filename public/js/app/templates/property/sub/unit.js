define(function(){

this["JST"] = this["JST"] || {};

this["JST"]["src/js/templates/property/sub/unit.jst"] = function(obj) {
obj || (obj = {});
var __t, __p = '', __e = _.escape;
with (obj) {
__p += 'tr class="{cycle(\'even\', \'odd\')}"\n  td.views-field.views-field-cond-title.active\n    = link_to unit.title, unit\n    - if unit.occupied?\n      |  | \n      = link_to t("general.classes.lease"), [@property, unit.active_lease]\n  td.views-field.views-field-field-confirmed\n    = raw unit_status(unit)\n  td.views-field.views-field-field-date-1\n    - if unit.occupied?\n      - if unit.active_lease.end_date\n        span.date-display-single content="{unit.active_lease.end_date}" datatype="xsd:dateTime" property="dc:date"\n          = l unit.active_lease.end_date, format: :short\n    -# - if unit.next_lease_id\n    -#   = link_to property_lease_path([property, unit.next_lease_id], "next")\n  td.views-field.views-field-field-rent\n    - if unit.occupied?\n      = unit.active_lease.rent\n  td.views-field.views-field-add-tenants.btn-toolbar\n    .btn-group\n      = link_to new_property_lease_path(@property, unit: unit.id), \n      :"data-original-title" => t("unit.actions.add_lease"),\n      class: "btn btn-mini", \n      rel: "tooltip" do\n        i.icon-plus\n    - if unit.occupied?\n      .btn-group\n        = link_to add_tenants_to_lease_path(@property, unit.active_lease),\n          :"data-original-title" => t("lease.actions.add_tenants"),\n          class: "btn btn-mini", \n          rel: "tooltip" do\n          i.icon-user\n      .btn-group\n        = link_to extend_property_lease_path(@property, unit.active_lease), \n          :"data-original-title" => t("lease.actions.extend"),\n          class: "btn btn-mini",\n          rel: "tooltip" do\n          i.icon-repeat';

}
return __p
};

  return this["JST"];
});