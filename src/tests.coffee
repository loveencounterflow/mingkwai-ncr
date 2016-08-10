





############################################################################################################
CND                       = require 'cnd'
rpr                       = CND.rpr.bind CND
badge                     = 'NCR-UNICODE-CACHE-WRITER/tests'
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
{ step }                  = require 'coffeenode-suspend'
#...........................................................................................................
test                      = require 'guy-test'




#-----------------------------------------------------------------------------------------------------------
@[ "(v2) create derivatives of NCR (3)" ] = ( T ) ->
  ISL           = require 'interskiplist'
  #.........................................................................................................
  ### General data ###
  # @_Unicode_demo_add_base       u
  # @_Unicode_demo_add_planes     u
  # @_Unicode_demo_add_areas      u
  # @_Unicode_demo_add_blocks     u
  u = ISL.copy require './unicode-isl'
  #.........................................................................................................
  ### CJK-specific data ###
  @_Unicode_demo_add_cjk_tags       u
  ### Jizura-specific data ###
  @_Unicode_demo_add_jzr_tag        u
  @_Unicode_demo_add_sims           u
  ### Mingkwai-specific data ###
  @_Unicode_demo_add_styles         u
  ISL.add u, { lo: 0x0, hi: 0x10ffff, tag: 'foo bar', }
  #.........................................................................................................
  reducers = { name: 'skip', tex: 'list', style: 'list', type: 'skip', }
  for glyph in Array.from '《A↻\ue000鿕\u9fd6'
    cid       = glyph.codePointAt 0
    cid_hex   = hex cid
    { plane
      area
      block
      rsg
      tag
      tex
      style } = ISL.aggregate u, cid, reducers
    rsg      ?= 'u-???'
    tag       = tag.join ', '
    urge cid_hex, ( CND.lime rpr glyph ), ( CND.gold "#{plane} / #{area} / #{block} / #{rsg}" ), ( CND.white tag )
  #.........................................................................................................
  return null

#-----------------------------------------------------------------------------------------------------------
@_Unicode_demo_show_sample = ( isl ) ->
  XNCR = require './xncr'
  #.........................................................................................................
  # is_cjk_rsg    = (   rsg ) -> rsg in mkts_options[ 'tex' ][ 'cjk-rsgs' ]
  # is_cjk_glyph  = ( glyph ) -> is_cjk_rsg XNCR.as_rsg glyph
  #.........................................................................................................
  for glyph in XNCR.chrs_from_text "helo äöü你好𢕒𡕴𡕨𠤇𫠠𧑴𨒡《》【】&jzr#xe100;🖹"
    cid     = XNCR.as_cid glyph
    cid_hex = hex cid
    # debug glyph, cid_hex, find_id_text u, cid
    descriptions = ISL.find_entries_with_all_points u, cid
    urge glyph, cid_hex
    for description in descriptions
      [ type, _, ] = ( description[ 'name' ] ? '???/' ).split ':'
      help ( CND.grey type + '/' ) + ( CND.steel 'interval' ) + ': ' + ( CND.yellow "#{hex description[ 'lo' ]}-#{hex description[ 'hi' ]}" )
      for key, value of description
        continue if key in [ 'lo', 'hi', 'id', ]
        help ( CND.grey type + '/' ) + ( CND.steel key ) + ': ' + ( CND.yellow value )
    # urge glyph, cid_hex, JSON.stringify ISL.find_all_ids    u, cid
    # info glyph, cid_hex, JSON.stringify ISL.find_any_ids    u, cid
  #.........................................................................................................
  return null


#-----------------------------------------------------------------------------------------------------------
@_Unicode_demo_add_styles = ( isl ) ->
  ISL                 = require 'interskiplist'
  XNCR                = require './xncr'
  mkts_options        = require '../../mingkwai-typesetter/options'
  tex_command_by_rsgs = mkts_options[ 'tex' ][ 'tex-command-by-rsgs' ]
  #.........................................................................................................
  lo          = 0x000000
  hi          = 0x10ffff
  tex         = tex_command_by_rsgs[ 'fallback' ]
  name        = "style:fallback"
  ISL.add isl, { name, lo, hi, tex, }
  #.........................................................................................................
  for glyph, style of mkts_options[ 'tex' ][ 'glyph-styles' ]
    glyph       = XNCR.normalize_glyph  glyph
    rsg         = XNCR.as_rsg           glyph
    cid         = XNCR.as_cid           glyph
    lo = hi     = cid
    cid_hex     = hex cid
    name        = "glyph-#{cid_hex}"
    name        = "style:#{name}"
    ISL.add isl, { name, lo, hi, rsg, style, }
  #.........................................................................................................
  return isl

#-----------------------------------------------------------------------------------------------------------
@_Unicode_demo_add_cjk_tags = ( isl ) ->
  ISL = require 'interskiplist'
  rsg_registry  = require './character-sets-and-ranges'
  ranges        = rsg_registry[ 'names-and-ranges-by-csg' ][ 'u' ]
  for rsg, tag of rsg_registry[ 'tag-by-rsgs' ]
    continue unless ( range = ranges[ rsg ] )?
    lo  = range[ 'first-cid'  ]
    hi  = range[ 'last-cid'   ]
    ISL.add isl, { lo, hi, tag, }
  #.........................................................................................................
  return isl

#-----------------------------------------------------------------------------------------------------------
@_Unicode_demo_add_jzr_tag = ( isl ) ->
  ISL = require 'interskiplist'
  rsg_registry  = require './character-sets-and-ranges'
  ranges        = rsg_registry[ 'names-and-ranges-by-csg' ][ 'jzr' ]
  # debug '©95520', ranges
  # debug '©95520', rsg_registry[ 'tag-by-rsgs' ]
  for rsg, tag of rsg_registry[ 'tag-by-rsgs' ]
    continue unless ( range = ranges[ rsg ] )?
    debug '©74688', range, rsg, tag
    lo  = range[ 'first-cid'  ]
    hi  = range[ 'last-cid'   ]
    ISL.add isl, { lo, hi, tag, }
  #.........................................................................................................
  return isl

#-----------------------------------------------------------------------------------------------------------
@_Unicode_demo_add_sims = ( isl ) ->
  ISL                 = require 'interskiplist'
  #.........................................................................................................
  return isl
