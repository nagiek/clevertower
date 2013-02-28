(function() {

  Parse.Cloud.define("hello", function(request, response) {
    return response.success("Hello world!");
  });

  Parse.Cloud.beforeSave("Address", function(request, response) {
    if (!(request.object.get("lat") !== 0 && request.object.get("lng") !== 0)) {
      return response.error('invalid_address');
    } else if (!(request.object.get("thoroughfare") !== '' && request.object.get("locality") !== '' && request.object.get("administrative_area_level_1") !== '' && request.object.get("country") !== '' && request.object.get("postal_code") !== '')) {
      return response.error('insufficient_data');
    } else {
      new Parse.Query("Address").equalTo("lat", request.object.get("lat")).equalTo("lng", request.object.get("lng")).find({
        success: function(results) {
          return request.object.set("id", results[0].get("id"));
        }
      });
      return response.success();
    }
  });

  Parse.Cloud.beforeSave("Property", function(request, response) {
    if (request.object.get("title") == null) {
      return response.error('title_missing');
    }
    new Parse.Query("Property").equalTo("userId", request.object.get("user")).equalTo("addressId", request.object.get("id")).find({
      success: function(results) {
        return response.error('taken_by_user');
      }
    });
    new Parse.Query("Property").equalTo("networkId", request.object.get("network")).equalTo("addressId", request.object.get("id")).find({
      success: function(results) {
        return response.error('taken_by_network');
      }
    });
    return response.success();
  });

}).call(this);
