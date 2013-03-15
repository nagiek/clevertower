define(function(){

this["JST"] = this["JST"] || {};

this["JST"]["src/js/templates/property/form/_basic.jst"] = function(obj) {
obj || (obj = {});
var __t, __p = '', __e = _.escape;
with (obj) {
__p += '<fieldset>\n  <legend>' +
((__t = ( i18nProperty.form.building )) == null ? '' : __t) +
'</legend>\n  <div class="row">\n    <div id="property-title-group" class="control-group span">\n      <label for="property-title" class="control-label">' +
((__t = ( i18nProperty.fields.title )) == null ? '' : __t) +
'</label>\n      <div class="controls">\n        <input type="text" name="property[title]" id="property-title" class="span4" value="' +
((__t = ( property.title ? property.title : property.get('thoroughfare') )) == null ? '' : __t) +
'">\n      </div>\n    </div>\n    <div class="control-group span">\n      <label for="property-email" class="control-label">' +
((__t = ( i18nProperty.fields.property_type.label )) == null ? '' : __t) +
'</label>\n      <div class="controls">\n        <select name="property[property_type]" id="property-property_type" class="span3" ' +
((__t = ( property.property_type ? 'value="' + property.property_type + '"' : ''  )) == null ? '' : __t) +
'>\n          <option value="">' +
((__t = ( i18nCommon.form.select.select_value )) == null ? '' : __t) +
'</option>\n          <option value="1">' +
((__t = ( i18nProperty.fields.property_type.condo )) == null ? '' : __t) +
'</option>\n          <option value="2">' +
((__t = ( i18nProperty.fields.property_type.apartment )) == null ? '' : __t) +
'</option>\n        </select>\n      </div>\n    </div>\n    <div class="control-group span">\n      <label for="property-year" class="control-label">' +
((__t = ( i18nProperty.fields.year )) == null ? '' : __t) +
'</label>\n      <div class="controls">\n        <input type="number" name="property[year]" id="property-year" class="span1" maxlength="4" ' +
((__t = ( property.description ? 'value="' + property.description + '"' : ''  )) == null ? '' : __t) +
'>\n      </div>\n    </div>\n    <div class="control-group span">\n      <label for="property-mls" class="control-label">' +
((__t = ( i18nProperty.fields.mls )) == null ? '' : __t) +
'</label>\n      <div class="controls">\n        <input type="text" name="property[mls]" id="property-mls" class="span2" ' +
((__t = ( property.description ? 'value="' + property.description + '"' : ''  )) == null ? '' : __t) +
'>\n      </div>\n    </div>\n  </div>\n</fieldset>\n\n<fieldset>\n  <legend>' +
((__t = ( i18nProperty.form.marketing )) == null ? '' : __t) +
'</legend>\n  <div class="row">\n    <div class="control-group span">\n      <label for="property-description" class="control-label">' +
((__t = ( i18nProperty.fields.description )) == null ? '' : __t) +
'</label>\n      <div class="controls">\n        <textarea rows="5" name="property[description]" id="property-description" class="span4">' +
((__t = ( property.description ? property.description : ''  )) == null ? '' : __t) +
'</textarea>\n      </div>\n    </div>\n    <div class="control-group span6">\n      <label for="property-amenities" class="control-label">' +
((__t = ( i18nProperty.form.amenities )) == null ? '' : __t) +
'</label>\n      <div class="controls three-column">\n        <label for="property-air_conditioning" class="checkbox">\n          <input type="checkbox" name="property[air_conditioning]" id="property-air_conditioning" ' +
((__t = ( property.air_conditioning ? checked="checked" : '' )) == null ? '' : __t) +
'>' +
((__t = ( i18nProperty.fields.air_conditioning )) == null ? '' : __t) +
'\n        </label>\n        <label for="property-back_yard" class="checkbox">\n          <input type="checkbox" name="property[back_yard]" id="property-back_yard" ' +
((__t = ( property.back_yard ? checked="checked" : '' )) == null ? '' : __t) +
'>' +
((__t = ( i18nProperty.fields.back_yard )) == null ? '' : __t) +
'\n        </label>\n        <label for="property-balcony" class="checkbox">\n          <input type="checkbox" name="property[balcony]" id="property-balcony" ' +
((__t = ( property.balcony ? checked="checked" : '' )) == null ? '' : __t) +
'>' +
((__t = ( i18nProperty.fields.balcony )) == null ? '' : __t) +
'\n        </label>\n        <label for="property-cats_allowed" class="checkbox">\n          <input type="checkbox" name="property[cats_allowed]" id="property-cats_allowed" ' +
((__t = ( property.cats_allowed ? checked="checked" : '' )) == null ? '' : __t) +
'>' +
((__t = ( i18nProperty.fields.cats_allowed )) == null ? '' : __t) +
'\n        </label>\n        <label for="property-concierge" class="checkbox">\n          <input type="checkbox" name="property[concierge]" id="property-concierge" ' +
((__t = ( property.concierge ? checked="checked" : '' )) == null ? '' : __t) +
'>' +
((__t = ( i18nProperty.fields.concierge )) == null ? '' : __t) +
'\n        </label>\n        <label for="property-dogs_allowed" class="checkbox">\n          <input type="checkbox" name="property[dogs_allowed]" id="property-dogs_allowed" ' +
((__t = ( property.dogs_allowed ? checked="checked" : '' )) == null ? '' : __t) +
'>' +
((__t = ( i18nProperty.fields.dogs_allowed )) == null ? '' : __t) +
'\n        </label>\n        <label for="property-doorman" class="checkbox">\n          <input type="checkbox" name="property[doorman]" id="property-doorman" ' +
((__t = ( property.doorman ? checked="checked" : '' )) == null ? '' : __t) +
'>' +
((__t = ( i18nProperty.fields.doorman )) == null ? '' : __t) +
'\n        </label>\n        <label for="property-elevator" class="checkbox">\n          <input type="checkbox" name="property[elevator]" id="property-elevator" ' +
((__t = ( property.elevator ? checked="checked" : '' )) == null ? '' : __t) +
'>' +
((__t = ( i18nProperty.fields.elevator )) == null ? '' : __t) +
'\n        </label>\n        <label for="property-exposed_brick" class="checkbox">\n          <input type="checkbox" name="property[exposed_brick]" id="property-exposed_brick" ' +
((__t = ( property.exposed_brick ? checked="checked" : '' )) == null ? '' : __t) +
'>' +
((__t = ( i18nProperty.fields.exposed_brick )) == null ? '' : __t) +
'\n        </label>\n        <label for="property-fireplace" class="checkbox">\n          <input type="checkbox" name="property[fireplace]" id="property-fireplace" ' +
((__t = ( property.fireplace ? checked="checked" : '' )) == null ? '' : __t) +
'>' +
((__t = ( i18nProperty.fields.fireplace )) == null ? '' : __t) +
'\n        </label>\n        <label for="property-front_yard" class="checkbox">\n          <input type="checkbox" name="property[front_yard]" id="property-front_yard" ' +
((__t = ( property.front_yard ? checked="checked" : '' )) == null ? '' : __t) +
'>' +
((__t = ( i18nProperty.fields.front_yard )) == null ? '' : __t) +
'\n        </label>\n        <label for="property-gym" class="checkbox">\n          <input type="checkbox" name="property[gym]" id="property-gym" ' +
((__t = ( property.gym ? checked="checked" : '' )) == null ? '' : __t) +
'>' +
((__t = ( i18nProperty.fields.gym )) == null ? '' : __t) +
'\n        </label>\n        <label for="property-laundry" class="checkbox">\n          <input type="checkbox" name="property[laundry]" id="property-laundry" ' +
((__t = ( property.laundry ? checked="checked" : '' )) == null ? '' : __t) +
'>' +
((__t = ( i18nProperty.fields.laundry )) == null ? '' : __t) +
'\n        </label>\n        <label for="property-indoor_parking" class="checkbox">\n          <input type="checkbox" name="property[indoor_parking]" id="property-indoor_parking" ' +
((__t = ( property.indoor_parking ? checked="checked" : '' )) == null ? '' : __t) +
'>' +
((__t = ( i18nProperty.fields.indoor_parking )) == null ? '' : __t) +
'\n        </label>\n        <label for="property-outdoor_parking" class="checkbox">\n          <input type="checkbox" name="property[outdoor_parking]" id="property-outdoor_parking" ' +
((__t = ( property.outdoor_parking ? checked="checked" : '' )) == null ? '' : __t) +
'>' +
((__t = ( i18nProperty.fields.outdoor_parking )) == null ? '' : __t) +
'\n        </label>\n        <label for="property-pool" class="checkbox">\n          <input type="checkbox" name="property[pool]" id="property-pool" ' +
((__t = ( property.pool ? checked="checked" : '' )) == null ? '' : __t) +
'>' +
((__t = ( i18nProperty.fields.pool )) == null ? '' : __t) +
'\n        </label>\n        <label for="property-sauna" class="checkbox">\n          <input type="checkbox" name="property[sauna]" id="property-sauna" ' +
((__t = ( property.sauna ? checked="checked" : '' )) == null ? '' : __t) +
'>' +
((__t = ( i18nProperty.fields.sauna )) == null ? '' : __t) +
'\n        </label>\n        <label for="property-wheelchair" class="checkbox">\n          <input type="checkbox" name="property[wheelchair]" id="property-wheelchair" ' +
((__t = ( property.wheelchair ? checked="checked" : '' )) == null ? '' : __t) +
'>' +
((__t = ( i18nProperty.fields.wheelchair )) == null ? '' : __t) +
'\n        </label>          \n      </div>\n    </div>\n    <div class="control-group span2">\n      <label for="property-included" class="control-label">' +
((__t = ( i18nProperty.form.included )) == null ? '' : __t) +
'</label>\n      <div class="controls">\n        <label for="property-electricity" class="checkbox">\n          <input type="checkbox" name="property[electricity]" id="property-electricity" ' +
((__t = ( property.electricity ? checked="checked" : '' )) == null ? '' : __t) +
'>' +
((__t = ( i18nProperty.fields.electricity )) == null ? '' : __t) +
'\n        </label>\n        <label for="property-furniture" class="checkbox">\n          <input type="checkbox" name="property[furniture]" id="property-furniture" ' +
((__t = ( property.furniture ? checked="checked" : '' )) == null ? '' : __t) +
'>' +
((__t = ( i18nProperty.fields.furniture )) == null ? '' : __t) +
'\n        </label>\n        <label for="property-gas" class="checkbox">\n          <input type="checkbox" name="property[gas]" id="property-gas" ' +
((__t = ( property.gas ? checked="checked" : '' )) == null ? '' : __t) +
'>' +
((__t = ( i18nProperty.fields.gas )) == null ? '' : __t) +
'\n        </label>\n        <label for="property-heat" class="checkbox">\n          <input type="checkbox" name="property[heat]" id="property-heat" ' +
((__t = ( property.heat ? checked="checked" : '' )) == null ? '' : __t) +
'>' +
((__t = ( i18nProperty.fields.heat )) == null ? '' : __t) +
'\n        </label>\n        <label for="property-hot_water" class="checkbox">\n          <input type="checkbox" name="property[hot_water]" id="property-hot_water" ' +
((__t = ( property.hot_water ? checked="checked" : '' )) == null ? '' : __t) +
'>' +
((__t = ( i18nProperty.fields.hot_water )) == null ? '' : __t) +
'\n        </label>\n      </div>\n    </div>\n  </div>\n</fieldset>\n\n<fieldset>\n  <legend>' +
((__t = ( i18nProperty.form.contact )) == null ? '' : __t) +
'</legend>\n  <div class="row">\n    <div class="control-group span">\n      <label for="property-email" class="control-label">' +
((__t = ( i18nProperty.fields.email )) == null ? '' : __t) +
'</label>\n      <div class="controls">\n        <input type="email" name="property[email]" id="property-email" class="span3" ' +
((__t = ( property.email ? 'value="' + property.email + '"' : ''  )) == null ? '' : __t) +
'>\n      </div>\n    </div>\n    <div class="control-group span">\n      <label for="property-phone" class="control-label">' +
((__t = ( i18nProperty.fields.phone )) == null ? '' : __t) +
'</label>\n      <div class="controls">\n        <input type="text" name="property[phone]" id="property-phone" class="span2" ' +
((__t = ( property.phone ? 'value="' + property.phone + '"' : ''  )) == null ? '' : __t) +
'>\n      </div>\n    </div>\n    <div class="control-group span">\n      <label for="property-website" class="control-label">' +
((__t = ( i18nProperty.fields.website )) == null ? '' : __t) +
'</label>\n      <div class="controls">\n        <input type="text" name="property[website]" id="property-website" class="span3" ' +
((__t = ( property.website ? 'value="' + property.website + '"' : ''  )) == null ? '' : __t) +
'>\n      </div>\n    </div>\n  </div>\n</fieldset>';

}
return __p
};

  return this["JST"];
});