

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
MKNCR.jzr_as_xncr = ( glyph ) ->
  nfo = @analyze glyph
  return glyph unless ( nfo.rsg is 'u-pua' ) or ( nfo.csg is 'jzr' )
  return @as_chr nfo.cid, { csg: 'jzr', }

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
      sim:  'list'
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
      id                    = JSON.stringify P
      return R if ( R = cache[ id ] )?
      #.....................................................................................................
      nfo                   = @analyze P...
      { csg, rsg, }         = nfo
      #.....................................................................................................
      if csg is 'u' then  R = aggregate nfo[ 'cid' ]
      else                R = {}
      #.....................................................................................................
      R[ key ]              = value for key, value of nfo
      #.....................................................................................................
      ### Instead of doing proper multi-characterset treatment,
      consider all Private Use Area CPs and all non-Unicode CPs as being CJK: ###
      if ( rsg is 'u-pua' ) or ( csg isnt 'u' )
        tag = R[ 'tag' ] ? []
        tag.push 'assigned'   unless 'assigned'   in tag
        tag.push 'cjk'        unless 'cjk'        in tag
        tag.push 'ideograph'  unless 'ideograph'  in tag
        R[ 'tag' ] = ( t for t in tag when t isnt 'pua' )
        if rsg is 'u-pua'
          R[ 'rsg'    ] = 'jzr'
          R[ 'csg'    ] = 'jzr'
          R[ 'fncr'   ] = R[ 'fncr'   ].replace 'u-pua-', 'jzr-'
          R[ 'sfncr'  ] = R[ 'sfncr'  ].replace 'u-',     'jzr-'
          R[ 'xncr'   ] = R[ 'xncr'   ].replace '&#x',    '&jzr#x'
          R[ 'chr'    ] = R[ 'xncr'   ]
        if R[ 'csg' ] is 'jzr' and not R[ 'tex' ]?
          R[ 'tex' ] = ( @describe R[ 'cid' ] )[ 'tex' ]
      #.....................................................................................................
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
  # R.paths.jizura_datasources  = PATH.resolve __dirname, '../../../jizura-datasources/data/flat-files/'
  # R.paths.sims                = PATH.resolve R.paths.jizura_datasources, 'shape/shape-similarity-identity.txt'
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
    # yield populate_isl_with_sims         S, resume
    yield populate_isl_with_extra_data   S, resume
    # debug '44743', S
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
    continue unless glyph_style?
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
  ###
    target glyph          source glyph
    favored               disfavored
    `sim/has-source`
    `sim/is-target`
                          `sim/is-source`
                          `sim/has-target`
  ###
  PS                        = require 'pipestreams'
  { $
    $async }                = PS
  #.........................................................................................................
  $add_intervals = =>
    return $ 'null', ( phrase, send ) =>
      unless phrase?
        return handler null, S
      send phrase
      [ target_glyph
        otag
        source_glyph ]  = phrase
      return unless ( MKNCR.is_inner_glyph target_glyph )
      return unless ( MKNCR.is_inner_glyph source_glyph )
      source_cid        = MKNCR.as_cid source_glyph
      target_cid        = MKNCR.as_cid target_glyph
      otag              = otag.replace /^sim\//, ''
      mtag              = "sim/target/#{otag}"
      ctag              = "sim sim/has-target sim/is-source sim/has-target/#{otag} sim/is-source/#{otag} sim/#{otag}"
      # sim               = { "#{otag}": { target: target_glyph, }, }
      S.collector.push { lo: source_cid, hi: source_cid, sim: mtag, "#{mtag}": target_glyph, tag: ctag, }
      mtag              = "sim/source/#{otag}"
      ctag              = "sim sim/has-source sim/is-target sim/has-source/#{otag} sim/is-target/#{otag} sim/#{otag}"
      # sim               = { "#{otag}": { source: source_glyph, }, }
      S.collector.push { lo: target_cid, hi: target_cid, sim: mtag, "#{mtag}": source_glyph, tag: ctag, }
      return null
  #.........................................................................................................
  $collect_tags = =>
    tags = new Set()
    return $ 'null', ( record ) =>
      if record? then tags.add record[ 'tag' ]
      else debug '3334', tags
      return null
  #.........................................................................................................
  SIMS            = require '../../mojikura/lib/read-sims'
  # JZRDBF_U        = require '../../jizura-db-feeder/lib/utilities'
  # S1              = JZRDBF_U.new_state()
  # S1.db           = null
  source          = SIMS.new_readstream()
  # source          = SIMS.new_readstream null, gaiji: no
  #.........................................................................................................
  pipeline        = []
  pipeline.push source
  pipeline.push $add_intervals()
  # pipeline.push PS.$show()
  pipeline.push PS.$drain()
  PS.pull pipeline...
  #.........................................................................................................
  return null

#-----------------------------------------------------------------------------------------------------------
block_style_as_tex = ( block_style ) -> "\\#{block_style}{}"

#-----------------------------------------------------------------------------------------------------------
glyph_style_as_tex = ( glyph, glyph_style ) ->
  ### NOTE this code replaces parts of `tex-writer-typofix._style_chr` ###
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
  if      rpl_push? and rpl_raise?  then R.push "\\mktstfPushRaise{#{rpl_push}}{#{rpl_raise}}"
  else if rpl_push?                 then R.push "\\mktstfPush{#{rpl_push}}"
  else if               rpl_raise?  then R.push "\\mktstfRaise{#{rpl_raise}}"
  #.........................................................................................................
  if rpl_cmd?                       then R.push "\\#{rpl_cmd}{}"
  R.push rpl_chr
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


