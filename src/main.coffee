

############################################################################################################
PATH                      = require 'path'
FS                        = require 'fs'
#...........................................................................................................
CND                       = require 'cnd'
rpr                       = CND.rpr
badge                     = 'MINGKWAI-NCR'
log                       = CND.get_logger 'plain',     badge
debug                     = CND.get_logger 'debug',     badge
info                      = CND.get_logger 'info',      badge
urge                      = CND.get_logger 'urge',      badge
warn                      = CND.get_logger 'warn',      badge
help                      = CND.get_logger 'help',      badge
echo                      = CND.echo.bind CND
#...........................................................................................................
D                         = require 'pipedreams'
{ $
  $async }                = D
{ step }                  = require 'coffeenode-suspend'
#...........................................................................................................
NCR                       = require 'ncr'
module.exports            = MKNCR = NCR._copy_library 'xncr'
ISL                       = MKNCR._ISL
u                         = MKNCR.unicode_isl

#===========================================================================================================
# NEW API METHODS
#-----------------------------------------------------------------------------------------------------------
MKNCR.is_inner_glyph       = ( glyph     ) -> ( @as_csg glyph ) in [ 'u', 'jzr', ]
# MKNCR.chr_from_cid_and_csg = ( cid, csg  ) -> CHR.as_chr cid, { csg: csg }
# MKNCR.cid_range_from_rsg   = ( rsg       ) -> CHR.cid_range_from_rsg rsg
# MKNCR.html_from_text       = ( glyph     ) -> CHR.html_from_text   glyph, settings

#-----------------------------------------------------------------------------------------------------------
MKNCR.jzr_as_uchr = ( glyph ) ->
  return @as_uchr glyph if ( @as_csg glyph ) is 'jzr'
  return glyph

#-----------------------------------------------------------------------------------------------------------
MKNCR.normalize = ( glyph ) ->
  throw new Error "XNCHR.normalize is deprecated"
  rsg = @as_rsg glyph
  cid = @as_cid glyph
  csg = if rsg is 'u-pua' then 'jzr' else 'u'
  return @chr_from_cid_and_csg cid, csg

#-----------------------------------------------------------------------------------------------------------
MKNCR.normalize_to_xncr = ( glyph ) ->
  throw new Error "do we need this method?"
  cid = @as_cid glyph
  csg = if ( @as_rsg glyph ) is 'u-pua' then 'jzr' else @as_csg glyph
  return @chr_from_cid_and_csg cid, csg

#-----------------------------------------------------------------------------------------------------------
MKNCR.normalize_to_pua = ( glyph ) ->
  throw new Error "do we need this method?"
  cid = @as_cid glyph
  csg = @as_csg glyph
  csg = 'u' if csg is 'jzr'
  return @chr_from_cid_and_csg cid, csg


#===========================================================================================================
# NEW DATA
#-----------------------------------------------------------------------------------------------------------
do =>
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
    fallback:  'skip'
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
  ### TAINT experimental ###
  aggregate = ISL.aggregate.use u, recipe, memoize: yes
  #.........................................................................................................
  do =>
    cache = {}
    MKNCR.describe = ( P... ) ->
      ### TAINT what about gaiji? ###
      id          = JSON.stringify P
      return R if ( R = cache[ id ] )?
      A           = @analyze P...
      R           = aggregate A[ 'cid' ]
      R[ key ]    = value for key, value of A
      cache[ id ] = R
      return R
  #.........................................................................................................
  return null


#===========================================================================================================
#
#-----------------------------------------------------------------------------------------------------------
new_state = ->
  R                           = {}
  R.paths                     = {}
  R.paths.cache               = PATH.resolve __dirname, '../data/isl-entries.json'
  R.paths.mkts_options        = PATH.resolve __dirname, '../../mingkwai-typesetter/lib/options.js'
  R.paths.jizura_datasources  = PATH.resolve __dirname, '../../../jizura-datasources/data/flat-files/'
  R.paths.sims                = PATH.resolve R.paths.jizura_datasources, 'shape/shape-similarity-identity.txt'
  R.collector                 = []
  return R


#===========================================================================================================
#
#-----------------------------------------------------------------------------------------------------------
read_cache = ( handler = null ) ->
  help "reading cache"
  warn "cache may be stale; check with mingkwai file-date-checker"
  S = new_state()
  ISL.add u, entry for entry in require S.paths.cache
  handler null, S if handler?
  return null


#===========================================================================================================
#
#-----------------------------------------------------------------------------------------------------------
rewrite_cache = ( handler = null ) ->
  help "rewriting cache"
  S = new_state()
  #.........................................................................................................
  step ( resume ) ->
    yield populate_isl_with_tex_formats  S, resume
    yield populate_isl_with_sims         S, resume
    yield populate_isl_with_extra_data   S, resume
    FS.writeFileSync S.paths.cache, JSON.stringify S.collector, null, '  '
    ISL.add u, entry for entry in S.collector
    #.......................................................................................................
    handler null, S if handler?
  #.........................................................................................................
  return null

#-----------------------------------------------------------------------------------------------------------
populate_isl_with_tex_formats = ( S, handler ) ->
  #.........................................................................................................
  mkts_options              = require S.paths.mkts_options
  tex_command_by_rsgs       = mkts_options[ 'tex' ][ 'tex-command-by-rsgs' ]
  glyph_styles              = mkts_options[ 'tex' ][ 'glyph-styles'        ]
  cjk_rsgs                  = mkts_options[ 'tex' ][ 'cjk-rsgs'            ]
  #.........................................................................................................
  fallback_command          = block_style_as_tex tex_command_by_rsgs[ 'fallback' ] ? 'mktsRsgFb'
  S.collector.push { lo: 0x000000, hi: 0x10ffff, tex: { block: fallback_command, }, }
  #.........................................................................................................
  for rsg, block_command of tex_command_by_rsgs
    continue if rsg is 'fallback'
    for entry in ISL.find_entries u, 'rsg', rsg
      ### Note: must push new entries to collector, cannot recycle existing ones here ###
      # target            = entry[ 'tex' ] ?= {}
      # target[ 'block' ] = block_style_as_tex block_command
      { lo, hi, tex, }  = entry
      tex              ?= {}
      tex[ 'block' ]    = block_style_as_tex block_command # unless block_command is 'latin'
      S.collector.push { lo, hi, tex, }
  #.........................................................................................................
  ### TAINT must resolve (X)NCRs ###
  for glyph, glyph_style of glyph_styles
    cid             = MKNCR.as_cid glyph
    glyph_style_tex = glyph_style_as_tex glyph, glyph_style
    S.collector.push { lo: cid, hi: cid, tex: { codepoint: glyph_style_tex, }, }
  #.........................................................................................................
  for rsg in cjk_rsgs
    for entry in ISL.find_entries u, 'rsg', rsg
      ### Note: must push new entries to collector, cannot recycle existing ones here ###
      { lo, hi, }  = entry
      S.collector.push { lo, hi, tag: [ 'cjk', ], }
  #.........................................................................................................
  handler null, S

#-----------------------------------------------------------------------------------------------------------
populate_isl_with_extra_data = ( S, handler ) ->
  for chr in Array.from '\x20\n\r\t'
    lo = hi = MKNCR.as_cid chr
    S.collector.push { lo, hi, tag: [ 'ascii-whitespace' ] }
  #.........................................................................................................
  handler null, S

#-----------------------------------------------------------------------------------------------------------
populate_isl_with_sims = ( S, handler ) ->
  #.........................................................................................................
  $add_intervals = =>
    return $ ( record ) =>
      { source_glyph
        target_glyph  } = record
      # debug '3334', record
      source_cid        = MKNCR.as_cid record[ 'source_glyph' ]
      target_cid        = MKNCR.as_cid record[ 'target_glyph' ]
      otag              = record[ 'tag' ]
      mtag              = "sim/target/#{otag}"
      ctag              = "sim sim/has-target sim/is-source sim/has-target/#{otag} sim/is-source/#{otag} sim/#{otag}"
      # sim               = { "#{otag}": { target: target_glyph, }, }
      S.collector.push { lo: source_cid, hi: source_cid, "#{mtag}": target_glyph, tag: ctag, }
      mtag              = "sim/source/#{otag}"
      ctag              = "sim sim/has-source sim/is-target sim/has-source/#{otag} sim/is-target/#{otag} sim/#{otag}"
      # sim               = { "#{otag}": { source: source_glyph, }, }
      S.collector.push { lo: target_cid, hi: target_cid, "#{mtag}": source_glyph, tag: ctag, }
      return null
  #.........................................................................................................
  $collect_tags = =>
    tags = new Set
    return $ 'null', ( record ) =>
      if record? then tags.add record[ 'tag' ]
      else debug '3334', tags
      return null
  #.........................................................................................................
  SIMS            = require '../../jizura-db-feeder/lib/feed-sims'
  JZRDBF_U        = require '../../jizura-db-feeder/lib/utilities'
  S1              = JZRDBF_U.new_state()
  S1.db           = null
  input           = SIMS.new_sim_readstream S1, filter: yes
  #.........................................................................................................
  input
    .pipe $add_intervals()
    .pipe $ 'finish', -> handler null, S
  #.........................................................................................................
  return null

#-----------------------------------------------------------------------------------------------------------
block_style_as_tex = ( block_style ) -> "\\#{block_style}{}"

#-----------------------------------------------------------------------------------------------------------
glyph_style_as_tex = ( glyph, glyph_style ) ->
  ### NOTE this code replaces parts of `tex-writer-typofix._style_chr` ###
  #.........................................................................................................
  ### TAINT using `prPushRaise` here in place of `tfPushRaise` because it gives better
  results ###
  use_tfpushraise = no
  #.........................................................................................................
  R         = []
  R.push "{"
  # R.push "\\cn" if is_cjk
  rpl_push  = glyph_style[ 'push'   ] ? null
  rpl_raise = glyph_style[ 'raise'  ] ? null
  rpl_chr   = glyph_style[ 'glyph'  ] ? glyph
  rpl_cmd   = glyph_style[ 'cmd'    ] ? null
  # rpl_cmd   = glyph_style[ 'cmd'    ] ? rsg_command
  # rpl_cmd   = null if rpl_cmd is 'cn'
  #.........................................................................................................
  if use_tfpushraise
    if      rpl_push? and rpl_raise?  then R.push "\\prPushRaise{#{rpl_push}}{#{rpl_raise}}{"
    else if rpl_push?                 then R.push "\\prPush{#{rpl_push}}{"
    else if               rpl_raise?  then R.push "\\prRaise{#{rpl_raise}}{"
  #.........................................................................................................
  else
    if      rpl_push? and rpl_raise?  then R.push "\\tfPushRaise{#{rpl_push}}{#{rpl_raise}}"
    else if rpl_push?                 then R.push "\\tfPush{#{rpl_push}}"
    else if               rpl_raise?  then R.push "\\tfRaise{#{rpl_raise}}"
  #.........................................................................................................
  if rpl_cmd?                       then R.push "\\#{rpl_cmd}{}"
  R.push rpl_chr
  R.push "}" if use_tfpushraise and ( rpl_push? or rpl_raise? )
  R.push "}"
  R = R.join ''
  return R

#===========================================================================================================
#
#-----------------------------------------------------------------------------------------------------------
main = ->
  return read_cache() if module.parent?
  rewrite_cache()
main()

  # S                   = new_state()
  # must_rewrite_cache  = no
  # #.........................................................................................................
  # if must_rewrite_cache
  #   if module.parent? and not handler?
  #     cache_path = PATH.relative process.cwd(), S.paths.cache
  #     warn "cache file"
  #     warn "#{cache_path}"
  #     warn "is out of date"
  #     urge "run the command"
  #     urge CND.white "node #{PATH.relative process.cwd(), __filename}"
  #     urge "to rebuild #{cache_path}"
  #     # throw new Error "cache #{S.paths.cache} out of date"
  #   else
  #     rewrite_cache S, handler
  # else
  #   handler ?= ( error ) -> throw error if error?
  #   read_cache S, handler
  # #.........................................................................................................
  # return null



# ############################################################################################################
# if module.parent?
#   ### If this module is `require`d from another module, run `populate_isl` *without* callback. This will
#   succeed if cache is present and up to date; it will fail with a helpful message otherwise. ###
#   populate_isl()
#   # populate_isl ( error, S ) ->
#   #   throw error if error?
#   #   return null
# else
#   ### If this module is run as a script, rebuild the cache when necessary: ###
#   populate_isl ( error, S ) ->
#     throw error if error?
#     help "#{S.paths.cache}"
#     help "is up to date"
#     return null






