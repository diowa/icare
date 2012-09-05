"use strict"

$ ->
  $(".reference-rating").on "click", ->
    $("#incoming_reference_outgoing_reference_attributes_rating").val $(this).data("rating")
