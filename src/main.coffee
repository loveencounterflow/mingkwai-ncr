





############################################################################################################
CND                       = require 'cnd'
rpr                       = CND.rpr.bind CND
badge                     = 'MINGKWAI-NCR'
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
NCR                       = require 'ncr'
module.exports            = MKNCR = NCR._copy_library 'xncr'
ISL                       = MKNCR._ISL
u                         = MKNCR.unicode_isl

#-----------------------------------------------------------------------------------------------------------
add_data = ->
  #.........................................................................................................
  # ### CJK-specific data ###
  # add_cjk_tags()
  ### Jizura-specific data ###
  add_jzr_tag()
  add_sims()
  ### Mingkwai-specific data ###
  add_styles()
  #.........................................................................................................
  return null

#-----------------------------------------------------------------------------------------------------------
add_cjk_tags = ->
  throw new Error "currently not used"
  rsg_registry  = require './character-sets-and-ranges'
  ranges        = rsg_registry[ 'names-and-ranges-by-csg' ][ 'u' ]
  for rsg, tag of rsg_registry[ 'tag-by-rsgs' ]
    continue unless ( range = ranges[ rsg ] )?
    lo  = range[ 'first-cid'  ]
    hi  = range[ 'last-cid'   ]
    ISL.add u, { lo, hi, tag, }
  #.........................................................................................................
  return null

#-----------------------------------------------------------------------------------------------------------
add_styles = ->
  mkts_options        = require '../../mingkwai-typesetter/options'
  tex_command_by_rsgs = mkts_options[ 'tex' ][ 'tex-command-by-rsgs' ]
  #.........................................................................................................
  lo          = 0x000000
  hi          = 0x10ffff
  tex         = tex_command_by_rsgs[ 'fallback' ]
  name        = "style:fallback"
  ISL.add u, { name, lo, hi, tex, }
  #.........................................................................................................
  for glyph, style of mkts_options[ 'tex' ][ 'glyph-styles' ]
    glyph       = MKNCR.normalize_glyph glyph
    rsg         = MKNCR.as_rsg          glyph
    cid         = MKNCR.as_cid          glyph
    lo = hi     = cid
    cid_hex     = hex cid
    name        = "glyph-#{cid_hex}"
    name        = "style:#{name}"
    ISL.add u, { name, lo, hi, rsg, style, }
  #.........................................................................................................
  return null

#-----------------------------------------------------------------------------------------------------------
add_jzr_tag = ->
  rsg_registry  = require './character-sets-and-ranges'
  ranges        = rsg_registry[ 'names-and-ranges-by-csg' ][ 'jzr' ]
  # debug '©95520', ranges
  # debug '©95520', rsg_registry[ 'tag-by-rsgs' ]
  for rsg, tag of rsg_registry[ 'tag-by-rsgs' ]
    continue unless ( range = ranges[ rsg ] )?
    debug '©74688', range, rsg, tag
    lo  = range[ 'first-cid'  ]
    hi  = range[ 'last-cid'   ]
    ISL.add u, { lo, hi, tag, }
  #.........................................................................................................
  return null

#-----------------------------------------------------------------------------------------------------------
add_sims = ->
  #.........................................................................................................
  return null


###

#-----------------------------------------------------------------------------------------------------------
show_sample = ->
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
###
