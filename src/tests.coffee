





############################################################################################################
CND                       = require 'cnd'
rpr                       = CND.rpr.bind CND
badge                     = 'MINGKWAI-NCR/tests'
log                       = CND.get_logger 'plain',     badge
info                      = CND.get_logger 'info',      badge
whisper                   = CND.get_logger 'whisper',   badge
alert                     = CND.get_logger 'alert',     badge
debug                     = CND.get_logger 'debug',     badge
warn                      = CND.get_logger 'warn',      badge
help                      = CND.get_logger 'help',      badge
urge                      = CND.get_logger 'urge',      badge
echo                      = CND.echo.bind CND
#...........................................................................................................
test                      = require 'guy-test'
MKNCR                     = require './main'
ISL                       = MKNCR._ISL
u                         = MKNCR.unicode_isl

#===========================================================================================================
# HELPERS
#-----------------------------------------------------------------------------------------------------------
@_prune = ->
  for name, value of @
    continue if name.startsWith '_'
    delete @[ name ] unless name in include
  return null

#-----------------------------------------------------------------------------------------------------------
@_main = ->
  test @, 'timeout': 3000


#===========================================================================================================
# TESTS
#-----------------------------------------------------------------------------------------------------------
@[ "demo" ] = ( T ) ->
  #.........................................................................................................
  for glyph in MKNCR.chrs_from_text "helo äöü你好𢕒𡕴𡕨𠤇𫠠𧑴𨒡《》【】&jzr#xe100;🖹"
    cid = MKNCR.as_cid glyph
    debug glyph, ISL.aggregate u, glyph
    # cid_hex = hex cid
    # # debug glyph, cid_hex, find_id_text u, cid
    # descriptions = ISL.find_entries_with_all_points u, cid
    # urge glyph, cid_hex
    # for description in descriptions
    #   [ type, _, ] = ( description[ 'name' ] ? '???/' ).split ':'
    #   help ( CND.grey type + '/' ) + ( CND.steel 'interval' ) + ': ' + ( CND.yellow "#{hex description[ 'lo' ]}-#{hex description[ 'hi' ]}" )
    #   for key, value of description
    #     continue if key in [ 'lo', 'hi', 'id', ]
    #     help ( CND.grey type + '/' ) + ( CND.steel key ) + ': ' + ( CND.yellow value )
    # # urge glyph, cid_hex, JSON.stringify ISL.find_all_ids    u, cid
    # # info glyph, cid_hex, JSON.stringify ISL.find_any_ids    u, cid
  #.........................................................................................................
  return null


############################################################################################################
unless module.parent?
  # debug '0980', JSON.stringify ( Object.keys @ ), null, '  '
  include = [
    "demo"
    ]
  @_prune()
  @_main()

