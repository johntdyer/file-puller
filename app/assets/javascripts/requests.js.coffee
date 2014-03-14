# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://coffeescript.org/
$(document).ready ->
  # http://trentrichardson.com/examples/timepicker/#timezone_examples
  $(".datetime_picker").datetimepicker
    #DateTime.iso8601('2001-02-03T04:05:06+07:00')
    dateFormat: 'yy-mm-dd',
    timeFormat: "HH:mm:sZ",
    separator: 'T',
    timezoneList: [
      {
        value: -300
        label: "Eastern"
      }
      {
        value: -360
        label: "Central"
      }
      {
        value: -420
        label: "Mountain"
      }
      {
        value: -480
        label: "Pacific"
      }
    ]

  return
