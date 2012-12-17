# encoding: utf-8
APPNAME = 'icare'
AVAILABLE_LOCALES = Hash[{
  :"en-US" => 'English (US)',
  :"it-IT" => 'Italiano'
}.sort_by{ |code, native_name| native_name }]
