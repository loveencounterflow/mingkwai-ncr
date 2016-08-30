





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
{ step }                  = require 'coffeenode-suspend'
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
  # for glyph in MKNCR.chrs_from_text "helo äöü你好𢕒𡕴𡕨𠤇𫠠𧑴𨒡《》【】&jzr#xe100;🖹"
  for glyph in MKNCR.chrs_from_text "《🖹"
    cid = MKNCR.as_cid glyph
    debug glyph, ISL.aggregate u, cid
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

#-----------------------------------------------------------------------------------------------------------
@[ "aggregate" ] = ( T ) ->
  u         = MKNCR.unicode_isl
  ISL       = MKNCR._ISL
  probes_and_matchers = [
    ["q",{"tag":["assigned"],"rsg":"u-latn"}]
    ["里",{"tag":["assigned","cjk","ideograph","sim","sim/has-source","sim/is-target","sim/has-source/global","sim/is-target/global","sim/global"],"rsg":"u-cjk"}]
    ["䊷",{"tag":["assigned","cjk","ideograph"],"rsg":"u-cjk-xa"}]
    ["《",{"tag":["assigned","cjk","punctuation"],"rsg":"u-cjk-sym"}]
    ["🖹",{"tag":["assigned"]}]
    ["🛷",{"tag":["unassigned"]}]
    [887,{"tag":["assigned"],"rsg":"u-grek"}]
    [888,{"tag":["unassigned"],"rsg":"u-grek"}]
    [889,{"tag":["unassigned"],"rsg":"u-grek"}]
    [890,{"tag":["assigned"],"rsg":"u-grek"}]
    ]
  recipe  = { fallback: 'skip', fields: { 'tag': 'tag', 'rsg': 'assign', }, }
  for [ probe, matcher, ] in probes_and_matchers
    result = ISL.aggregate u, probe, recipe
    debug '32771', JSON.stringify [ probe, result, ]
    T.eq result, matcher
  #.........................................................................................................
  return null

#-----------------------------------------------------------------------------------------------------------
@[ "SIMs, TeX formats" ] = ( T ) ->
  #.........................................................................................................
  sim_tags = [
    'sim/source/global'
    'sim/source/components'
    'sim/source/components/search'
    'sim/source/false-identity'
    'sim/target/global'
    'sim/target/components'
    'sim/target/components/search'
    'sim/target/false-identity'
    ]
  #.........................................................................................................
  recipe =
    fallback: 'skip'
    fields:
      tag:  'tag'
      rsg:  'assign'
      # sim:  ( values, context ) ->
      #   ### TAINT should be a standard reducer ###
      #   debug '7701', values
      #   R = {}
      #   for value in values
      #     for name, sub_value of value
      #       R[ name ] = sub_value
      #   return R
      tex:  ( values, context ) ->
        ### TAINT should be a standard reducer ###
        R = {}
        for value in values
          for name, sub_value of value
            R[ name ] = sub_value
        return R
  #.........................................................................................................
  recipe[ 'fields' ][ sim_tag ] = 'list' for sim_tag in sim_tags
  #.........................................................................................................
  # text  = '([Xqf]) ([里䊷䊷里]) ([Xqf])'
  # text  = 'q里䊷f'
  # text = '釒'
  # text = '龵⿸釒金𤴔丨亅㐅乂'
  probes_and_matchers = [
    ["龵",{"tag":["assigned","cjk","ideograph"],"rsg":"u-cjk","tex":{"block":"\\cn","codepoint":"{\\tfRaise{-0.1}\\cnxBabel{}龵}"}}]
    ["⿸",{"tag":["assigned","cjk","idl"],"rsg":"u-cjk-idc","tex":{"codepoint":"{\\tfRaise{-0.2}\\cnxJzr{}}"}}]
    ["釒",{"tag":["assigned","cjk","ideograph","sim","sim/has-target","sim/is-source","sim/has-target/components","sim/is-source/components","sim/components"],"rsg":"u-cjk","sim/target/components":["金"],"tex":{"block":"\\cn","codepoint":"{\\tfPush{0.4}釒}"}}]
    ["金",{"tag":["assigned","cjk","ideograph","sim/has-source/global","sim/is-target/global","sim/global","sim","sim/has-source","sim/is-target","sim/has-source/components","sim/is-target/components","sim/components"],"rsg":"u-cjk","sim/source/global":["金","⾦"],"sim/source/components":["釒"],"tex":{"block":"\\cn"}}]
    ["𤴔",{"tag":["assigned","cjk","ideograph","sim","sim/has-source","sim/is-target","sim/has-source/global","sim/is-target/global","sim/global"],"rsg":"u-cjk-xb","sim/source/global":["⺪"],"tex":{"block":"\\cnxb","codepoint":"{\\cnxBabel{}𤴔}"}}]
    ["丨",{"tag":["assigned","cjk","ideograph","sim/has-source/global","sim/is-target/global","sim/global","sim","sim/has-source","sim/is-target","sim/has-source/components/search","sim/is-target/components/search","sim/components/search"],"rsg":"u-cjk","sim/source/global":["〡","⼁","㇑"],"sim/source/components/search":["亅"],"tex":{"block":"\\cn"}}]
    ["亅",{"tag":["assigned","cjk","ideograph","sim/has-source","sim/is-target","sim/has-source/global","sim/is-target/global","sim/global","sim","sim/has-target","sim/is-source","sim/has-target/components/search","sim/is-source/components/search","sim/components/search"],"rsg":"u-cjk","sim/source/global":["⼅","㇚"],"sim/target/components/search":["丨"],"tex":{"block":"\\cn"}}]
    ["㐅",{"tag":["assigned","cjk","ideograph","sim/has-source","sim/is-target","sim/has-source/global","sim/is-target/global","sim/global","sim","sim/has-target","sim/is-source","sim/has-target/components","sim/is-source/components","sim/components"],"rsg":"u-cjk-xa","sim/source/global":["〤"],"sim/target/components":["乂"],"tex":{"block":"\\cnxa"}}]
    ["乂",{"tag":["assigned","cjk","ideograph","sim","sim/has-source","sim/is-target","sim/has-source/components","sim/is-target/components","sim/components"],"rsg":"u-cjk","sim/source/components":["㐅","乄"],"tex":{"block":"\\cn"}}]
    ]
  for [ probe, matcher, ] in probes_and_matchers
    description = ISL.aggregate u, probe, recipe
    T.eq description, matcher
    # help '28107', matcher
    # warn '28107', description
    # debug '40223', JSON.stringify [ probe, description, ]; continue
    info probe
    urge '  tag:', ( description[ 'tag' ] ? [ '-/-' ] ).join ', '
    urge '  rsg:', description[ 'rsg' ]
    for sim_tag in sim_tags
      continue unless ( value = description[ sim_tag ] )?
      urge "  #{sim_tag}:", value
    urge '  blk:', description[ 'tex' ]?[ 'block'     ] ? '-/-'
    urge '  cp: ', description[ 'tex' ]?[ 'codepoint' ] ? '-/-'
  #.........................................................................................................
  return null

#-----------------------------------------------------------------------------------------------------------
demo_2 = ->
  #.........................................................................................................
  # tag = 'sim/is-target/global'
  tags = [
    'global'
    'components'
    'components/search'
    'false-identity'
    ]
  for tag in tags
    echo tag
    search_tag  = "sim/is-target/#{tag}"
    entry_tag   = "sim/source/#{tag}"
    for entry in MKNCR._ISL.find_entries u, 'tag', search_tag
      ### Silently assuming that all relevant entries represent single-character intervals ###
      target_glyph_info = MKNCR.analyze ( cid = entry[ 'lo' ] )
      target_glyph      = target_glyph_info[ 'uchr' ]
      target_fncr       = target_glyph_info[ 'fncr' ]
      source_glyph      = entry[ entry_tag ]
      source_glyph_info = MKNCR.analyze source_glyph
      source_fncr       = source_glyph_info[ 'fncr' ]
      echo target_fncr, target_glyph, '<-', source_fncr, source_glyph
  #.........................................................................................................
  return null


############################################################################################################
unless module.parent?
  # debug '0980', JSON.stringify ( Object.keys @ ), null, '  '
  include = [
    # "demo"
    "aggregate"
    "SIMs, TeX formats"
    ]
  @_prune()
  @_main()

