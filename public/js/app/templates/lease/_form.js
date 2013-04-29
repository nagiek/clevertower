define(function(){

this["JST"] = this["JST"] || {};

this["JST"]["src/js/templates/lease/_form.jst"] = function(obj) {
obj || (obj = {});
var __t, __p = '', __e = _.escape, __j = Array.prototype.join;
function print() { __p += __j.call(arguments, '') }
with (obj) {
__p += '<fieldset>\n  <legend>' +
((__t = ( i18nCommon.form.info )) == null ? '' : __t) +
'</legend>\n  <div class="row">\n    <div class="unit-group control-group span4">\n      <label for="lease-unit" class="control-label">' +
((__t = ( i18nCommon.classes.Unit )) == null ? '' : __t) +
' <span class="required">*</span></label>\n      <div class="controls">\n        ' +
((__t = ( JST["src/js/templates/helper/field/unit.jst"]({required: true, i18nUnit: i18nUnit, i18nCommon: i18nCommon}) )) == null ? '' : __t) +
'\n      </div>\n    </div>\n    <div class="date-group control-group span">\n      <label for="lease-dates" class="control-label">' +
((__t = ( i18nLease.form.dates )) == null ? '' : __t) +
' <span class="required">*</span></label>\n      <div class="controls">\n        <input type="text" class="span2 start-date datepicker" name="lease[start_date]" maxlength="12" value="' +
((__t = ( dates.start )) == null ? '' : __t) +
'" data-date="' +
((__t = ( dates.start )) == null ? '' : __t) +
'" data-date-format="' +
((__t = ( i18nCommon.dates.datepicker_format )) == null ? '' : __t) +
'"  />\n        <input type="text" class="span2 end-date datepicker"   name="lease[end_date]"   maxlength="12" value="' +
((__t = ( dates.end )) == null ? '' : __t) +
'" data-date="' +
((__t = ( dates.end )) == null ? '' : __t) +
'"   data-date-format="' +
((__t = ( i18nCommon.dates.datepicker_format )) == null ? '' : __t) +
'"  />\n        <div class="help-inline align-top">\n          <ul class="unstyled">\n            <li><small><a href="#" class="starting-this-month">' +
((__t = ( i18nLease.dates.starting_this_month )) == null ? '' : __t) +
'</a></small></li>\n            <li><small><a href="#" class="starting-next-month">' +
((__t = ( i18nLease.dates.starting_next_month )) == null ? '' : __t) +
'</a></small></li>\n            <li><small><a href="#" class="july-to-june">' +
((__t = ( i18nLease.dates.july_to_june )) == null ? '' : __t) +
'</a></small></li>\n          </ul>\n        </div>\n      </div>\n    </div>\n  </div>\n</fieldset>\n\n';
 if (isNew) { ;
__p += '\n  <fieldset>\n    <legend>' +
((__t = ( i18nLease.form.tenants )) == null ? '' : __t) +
'</legend>\n    ' +
((__t = ( JST["src/js/templates/helper/field/tenant.jst"]({emails: emails, i18nCommon: i18nCommon, label: false}) )) == null ? '' : __t) +
'\n  </fieldset>\n';
 } ;
__p += '\n\n<div class="row">\n  <fieldset class="span4">\n    <legend>' +
((__t = ( i18nLease.form.rent )) == null ? '' : __t) +
'</legend>\n    <div class="row">\n      <div class="control-group span">\n        <label for="lease-rent" class="control-label">' +
((__t = ( i18nLease.fields.rent )) == null ? '' : __t) +
'</label>\n        <div class="controls">\n          <div class="input-prepend">\n            <span class="field-prefix add-on">$</span>\n            <input type="number" class="span1" name="lease[rent]" id="lease-rent" maxlength="12" value="' +
((__t = ( lease.rent )) == null ? '' : __t) +
'" />\n          </div>\n        </div>\n      </div>\n      <div class="span2">\n        <label for="lease-first_month_paid" class="checkbox">\n          <input type="checkbox" name="lease[first_month_paid]" id="lease-first_month_paid" value="1" ' +
((__t = ( lease.first_month_paid ? checked="checked" : '' )) == null ? '' : __t) +
'>' +
((__t = ( i18nLease.rent.first_month_paid )) == null ? '' : __t) +
'\n        </label>\n        <label for="lease-last_month_paid" class="checkbox">\n          <input type="checkbox" name="lease[last_month_paid]" id="lease-last_month_paid" value="1" ' +
((__t = ( lease.last_month_paid ? checked="checked" : '' )) == null ? '' : __t) +
'>' +
((__t = ( i18nLease.rent.last_month_paid )) == null ? '' : __t) +
'\n        </label>\n        <label for="lease-checks_received" class="checkbox">\n          <input type="checkbox" name="lease[checks_received]" id="lease-checks_received" value="1" ' +
((__t = ( lease.checks_received ? checked="checked" : '' )) == null ? '' : __t) +
'>' +
((__t = ( i18nLease.rent.checks_received )) == null ? '' : __t) +
'\n        </label>\n      </div>\n    </div>\n  </fieldset>\n\n  <fieldset class="span3">\n    <legend>' +
((__t = ( i18nLease.form.deposit )) == null ? '' : __t) +
'</legend>\n    <div class="row">\n      <div class="control-group span">\n        <label for="lease-security_deposit" class="control-label">' +
((__t = ( i18nLease.fields.security_deposit )) == null ? '' : __t) +
'</label>\n        <div class="controls">\n          <div class="input-prepend">\n            <span class="field-prefix add-on">$</span>\n            <input type="number" class="span1" name="lease[security_deposit]" id="lease-security_deposit" maxlength="12" value="' +
((__t = ( lease.security_deposit )) == null ? '' : __t) +
'" />\n          </div>\n        </div>\n      </div>\n      <div class="control-group span1">\n        <label for="lease-keys" class="control-label">' +
((__t = ( i18nLease.fields.keys )) == null ? '' : __t) +
'</label>\n        <div class="controls">\n          <input type="number" class="span1" name="lease[keys]" id="lease-keys" maxlength="12" value="' +
((__t = ( lease.keys )) == null ? '' : __t) +
'" />\n        </div>\n      </div>\n    </div>\n  </fieldset>\n\n  <fieldset class="span5">\n    <legend>' +
((__t = ( i18nLease.form.parking )) == null ? '' : __t) +
'</legend>\n    <div class="row">\n      <div class="control-group span">\n        <label for="lease-parking_fee" class="control-label">' +
((__t = ( i18nLease.fields.parking_fee )) == null ? '' : __t) +
'</label>\n        <div class="controls">\n          <div class="input-prepend">\n            <span class="field-prefix add-on">$</span>\n            <input type="number" class="span1" name="lease[parking_fee]" id="lease-parking_fee" maxlength="12" value="' +
((__t = ( lease.parking_fee )) == null ? '' : __t) +
'" />\n          </div>\n        </div>\n      </div>\n      <div class="control-group span1">\n        <label for="lease-parking_space" class="control-label">' +
((__t = ( i18nLease.fields.parking_space )) == null ? '' : __t) +
'</label>\n        <div class="controls">\n          <input type="text" class="span1" name="lease[parking_space]" id="lease-parking_space" maxlength="12" value="' +
((__t = ( lease.parking_space )) == null ? '' : __t) +
'" />\n        </div>\n      </div>\n      <div class="control-group span1">\n        <label for="lease-garage_remotes" class="control-label">' +
((__t = ( i18nLease.fields.garage_remotes )) == null ? '' : __t) +
'</label>\n        <div class="controls">\n          <input type="number" class="span1" name="lease[garage_remotes]" id="lease-garage_remotes" maxlength="12" value="' +
((__t = ( lease.garage_remotes )) == null ? '' : __t) +
'"/>\n        </div>\n      </div>\n    </div>\n  </fieldset>\n</div>';

}
return __p
};

  return this["JST"];
});